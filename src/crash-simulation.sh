



IP=$1
UP_DOWN=$2

if [ "$UP_DOWN" = "down" ]; then
    sshpass -p "vsstuttart2025!" ssh student@$IP << EOF
        sudo systemctl stop keepalived
        sudo systemctl stop haproxy
        pkill -f "node .*server.js"
EOF
elif [ "$UP_DOWN" = "up" ]; then
    sshpass -p "vsstuttart2025!" ssh student@$IP << EOF
        sudo systemctl start keepalived
        sudo systemctl start haproxy
        cd /home/student/rsa/server
        nohup node server.js > /home/student/rsa/server/server.log 2>&1 &
EOF
else
    echo "Invalid or no action specified for UP_DOWN."
fi