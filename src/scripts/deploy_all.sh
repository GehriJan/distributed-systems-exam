

ssh student@192.168.0.12 'bash -s -- master 192.168.0.12' < ./src/scripts/install_ha.sh
ssh student@192.168.0.13 'bash -s -- node 192.168.0.13' < ./src/scripts/install_ha.sh
ssh student@192.168.0.14 'bash -s -- node 192.168.0.14' < ./src/scripts/install_ha.sh