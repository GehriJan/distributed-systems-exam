sudo systemctl start sshd
sudo systemctl deamon-reload
sudo systemctl start sshd
sudo systemctl enable sshd

passwd



192.168.124.65
192.168.124.206
192.168.124.166
192.168.124.186


# Install keepalived
sudo dnf update -y
sudo dnf install -y keepalived

# Configure keepalived for the master node
cat <<EOF | sudo tee /etc/keepalived/keepalived.conf
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1234
    }
    virtual_ipaddress {
        192.168.124.100
    }
}
EOF


sudo dnf update -y
sudo dnf install -y keepalived
# Configure keepalived for other nodes
cat <<EOF | sudo tee /etc/keepalived/keepalived.conf
vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 50
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1234
    }
    virtual_ipaddress {
        192.168.124.100
    }
}
EOF

# Restart keepalived service
sudo systemctl restart keepalived
sudo systemctl enable keepalived