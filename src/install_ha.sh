
#!/bin/bash

# Usage: ./install_ha.sh <role> <own_ip>
# Example: ./install_ha.sh master 192.168.0.11

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

sudo apt update
sudo apt install -y haproxy keepalived

if ! grep -q "^net.ipv4.ip_nonlocal_bind = 1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_nonlocal_bind = 1" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
fi

PEERS=""
for i in {11..14}; do
    if [[ "192.168.0.$i" != "$OWN_IP" ]]; then
        PEERS+="192.168.0.$i"$'\n'
    fi
done

PRIORITY=100
if [[ "$ROLE" == "master" ]]; then
    PRIORITY=200
fi

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

sudo systemctl restart keepalived


# Configure HAProxy as a load balancer
sudo bash -c "cat > /etc/haproxy/haproxy.cfg <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
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
    server node2 192.168.0.12:8080 check
    server node3 192.168.0.13:8080 check
    server node4 192.168.0.14:8080 check
EOF"

# Restart HAProxy to apply the configuration
sudo systemctl restart haproxy



# Install Node.js and npm
sudo apt install -y nodejs npm

# Create a directory for the server
if [[ ! -d "/home/student/rsa/server" ]]; then
    mkdir -p /home/student/rsa/server
fi
cd /home/student/rsa/server

# Create the server.js file
cat > server.js <<EOF
const express = require('express');
const crypto = require('crypto');
const fs = require('fs');
const app = express();
const port = 8080;

app.get('/generate-key', (req, res) => {
    fs.appendFileSync('/home/student/rsa/server/server.log', 'Endpoint /generate-key was called\n');
    const { privateKey, publicKey } = crypto.generateKeyPairSync('rsa', {
        modulusLength: 2048,
    });
    res.json({ publicKey: publicKey.export({ type: 'pkcs1', format: 'pem' }) });
});

app.listen(port, () => {
    console.log(\`Server listening on port \${port}\`);
});
EOF

# Install dependencies
npm install express crypto

# Start the server
nohup node server.js > /home/student/rsa/server/server.log 2>&1 &
