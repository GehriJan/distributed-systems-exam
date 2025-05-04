
#!/bin/bash

# Usage: ./install_ha.sh <role> <own_ip>
# Example: ./install_ha.sh master 192.168.0.11

# Input validation
ROLE=$1
OWN_IP=$2

if [[ -z "$ROLE" || -z "$OWN_IP" ]]; then
    echo "Usage: $0 <role> <own_ip>"
    echo "Example: $0 master 192.168.0.11"
    exit 1
fi

if [[ "$ROLE" != "master" && "$ROLE" != "node" ]]; then
    echo "Invalid role. Use 'master' or 'node'."
    exit 1
fi

# Installing required packages
sudo apt install -y haproxy keepalived nodejs npm

# Enable Non-Local IP Binding
if ! grep -q "^net.ipv4.ip_nonlocal_bind = 1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_nonlocal_bind = 1" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
fi

# Configure IP-Adresses for Peers
PEERS=""
for i in {12..14}; do
    if [[ "192.168.0.$i" != "$OWN_IP" ]]; then
        PEERS+="192.168.0.$i"$'\n'
    fi
done

# Set Higher Priority for Master
PRIORITY=100
if [[ "$ROLE" == "master" ]]; then
    PRIORITY=200
fi

# Configure Keepalived
sudo bash -c "cat > /etc/keepalived/keepalived.conf <<EOF
vrrp_instance VI_1 {
    interface eth0
    state ${ROLE^^}
    priority $PRIORITY
    virtual_router_id 51
    unicast_src_ip $OWN_IP
    unicast_peer {
        $PEERS
    }
    virtual_ipaddress {
        192.168.0.100
    }
}
EOF"

# Restart Keepalived to apply the configuration
sudo systemctl restart keepalived


# Configure HAProxy as a load balancer
sudo bash -c "cat > /etc/haproxy/haproxy.cfg <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 1s
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    option  httplog
    option  dontlognull
    timeout connect 5000ms
    timeout client  50000ms
    timeout server  50000ms
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

frontend http_front
    bind *:80
    default_backend http_back

backend http_back
    balance roundrobin
    option redispatch
    retries 5
$(echo "$PEERS" | while read -r ip; do echo "    server node_$ip $ip:8080 check"; done)
EOF"

# Restart HAProxy to apply the configuration
sudo systemctl restart haproxy


# Create a directory for the server
if [[ ! -d "/home/student/rsa/server" ]]; then
    mkdir -p /home/student/rsa/server
fi
cd /home/student/rsa/server

# Create the server.js file
cat > server.js <<EOF
// compute_key.js
const express = require('express');
const app = express();
const port = 8080;

// Route to compute the modular inverse
app.get('/compute-inverse', (req, res) => {


  // Extract parameters from the query string
  const { e, phi } = req.query;

  // Validate input parameters
  if (!e || !phi) {
    return res.status(400).json({ error: 'Missing parameters e or phi' });
  }

  try {
    const eBigInt = BigInt(e);
    const phiBigInt = BigInt(phi);

    // Compute the modular inverse
    const d = computeModularInverse(eBigInt, phiBigInt);

    res.json({ privateKey: d.toString() });
  } catch (error) {
    res.status(500).json({ error: 'Error computing modular inverse' });
  }
});

// Function to compute the modular inverse using the Extended Euclidean Algorithm
function computeModularInverse(a, m) {
  let m0 = m;
  let y = 0n;
  let x = 1n;

  while (a > 1n) {
    const q = a / m;
    const t = m;

    m = a % m;
    a = t;

    const temp = y;
    y = x - q * y;
    x = temp;
  }

  // Ensure x is positive
  if (x < 0n) {
    x += m0;
  }

  return x;
}

// Start the server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
}).on('error', (err) => {
  console.error('Failed to start server:', err);
  process.exit(1);
});
EOF

# Install dependencies
npm install express crypto


# Ensure no existing server.js process is running
if pgrep -f "node .*server.js" > /dev/null; then
    echo "Stopping existing server.js process..."
    pkill -f "node .*server.js"
fi

# Start the server
nohup node server.js > /home/student/rsa/server/server.log 2>&1 &
