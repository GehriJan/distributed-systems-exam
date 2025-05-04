

sshpass -p "vsstuttart2025!" ssh student@192.168.0.12 'bash -s -- master 192.168.0.12' < ./install_ha.sh
sshpass -p "vsstuttart2025!" ssh student@192.168.0.13 'bash -s -- node 192.168.0.13' < ./install_ha.sh
sshpass -p "vsstuttart2025!" ssh student@192.168.0.14 'bash -s -- node 192.168.0.14' < ./install_ha.sh