#!/bin/bash

# Simple timer
start=$(date +'%m%s')

echo ""
echo "Kali EC2_IP Address "
echo $(curl -s https://api.ipify.org)
echo ""

INSTALL=$(omp -u admin -w admin --ping | grep -i "OMP ping was successful")
if [[ $INSTALL == "OMP ping was successful." ]] ; then
  echo "OpenVas detected!"
  exit
fi


# install some depedencies and do the updates
sudo apt-get update -y # OK

# install swaks to send emails
sudo apt-get install swaks -y

# install OpenVas
sudo apt-get install openvas -y # OK

# Setting up Kali for Vulnerability Scanning
sudo openvas-setup -y # OK

cd /lib/systemd/system
# sudo sed -e 's/127.0.0.1/0.0.0.0/g' greenbone-security-assistant.service openvas-manager.service openvas-scanner.service
sudo sed -e 's/127.0.0.1/0.0.0.0/g' greenbone-security-assistant.service openvas-manager.service openvas-scanner.service -i

# Starting the OpenVAS daemon
sudo systemctl daemon-reload

sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade


sudo DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --fix-broken install -y

# Setting up Kali for Vulnerability Scanning afther the upgrates and updates
sudo openvas-setup -y # OK
# Starting the OpenVAS daemon
sudo systemctl daemon-reload

# install OpenVas
sudo openvas-start # OK

sleep 5
# Add an admin user
sudo openvasmd --user=admin --new-password=admin

# Starting the OpenVAS daemon
sudo systemctl daemon-reload
sudo service openvas-scanner restart
sudo service openvas-manager restart
sudo openvasmd --rebuild --progress

sudo openvas-start # OK

# # There is more then one way to restart the servces with openVas, this is the second way
# # Starting the OpenVAS daemon
# sudo systemctl daemon-reload
# sudo openvas-services stop
# sudo openvasmd --rebuild
# sudo openvas-services start
# sudo openvas-start # OK


# Script complete. Give stats:
end=$(date +'%m%s')
diff=$(($end-$start))
echo ""
echo "Installation completed in $diff seconds."
echo "=================================================================="
echo ""

# restart bash session
exec bash -l

exit
