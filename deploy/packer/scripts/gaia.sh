#!/bin/sh
echo === Cloning gaia repo ===
sudo git clone -b great-gaia-guidance  --depth 1 https://github.com/blockstack/gaia /root/gaia

echo === Configuring Boot Scripts ===
sudo mkdir -p /gaia
sudo cat <<EOF> /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
source /usr/local/bin/aws_tags || exit 1

cp /root/gaia/deploy/docker/sample-aws.env /gaia/docker/aws.env
sed -i "s/DOMAIN_NAME=\".*\"/DOMAIN_NAME=\"$Domain\"/g" /root/gaia/deploy/docker/aws.env
sed -i "s/CERTBOT_EMAIL=\".*\"/CERTBOT_EMAIL=\"$Email\"/g" /root/gaia/deploy/docker/aws.env
sed -i "s/GAIA_BUCKET_NAME=\".*\"/GAIA_BUCKET_NAME=\"$BucketName\"/g" /root/gaia/deploy/docker/aws.env
exit 0
EOF

sudo chmod 755 /etc/rc.local
sudo mv /tmp/aws_tags /usr/local/bin/aws_tags
sudo chmod 755 /usr/local/bin/aws_tags

echo === Copying files ===
sudo cp -R /root/gaia/deploy/packer/system-files/etc/modules-load.d/nf.conf /etc/modules-load.d/nf.conf 
sudo cp -R /root/gaia/deploy/packer/system-files/etc/sysctl.d/startup.conf /etc/sysctl.d/startup.conf
for FILE in $(sudo ls /root/gaia/deploy/unit-files); do
  sudo cp -a /root/gaia/deploy/unit-files/${FILE} /etc/systemd/system/${FILE}
done

sudo cp -R /root/gaia/deploy/configs /gaia/
sudo cp -R /root/gaia/deploy/docker /gaia/

sudo systemctl enable gaia
sudo rm -rf /root/gaia
