#!/bin/bash

STREAM_NUM=25

#Configure Timezone For Recording Timestamps
sudo dpkg-reconfigure tzdata

#Install dependencies
sudo apt-get update && sudo apt-get -y install build-essential libpcre3 libpcre3-dev libssl-dev git zip unzip curl php8.3-cli php8.3-mbstring php8.3-fpm php8.3-mysql php8.3-curl php8.3-gd php8.3-bcmath htop ffmpeg libzmq3-dev nodejs yt-dlp

#Install NGINX with RTMP module
sudo apt-get install -y nginx libnginx-mod-rtmp

# Clear the default nginx.config
sudo systemctl stop nginx
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.old

#Install PHP
cd ~
sudo curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

#Install Instagram-Live scripts
sudo unzip ~/MLS/insta_php.zip -d ~/
#sudo git clone https://github.com/regstuff/InstagramLive-PHP.git
#sudo composer install -d InstagramLive-PHP/

# Download and move config files
cd ~/MLS/scripts/
sudo mkdir images
cd images
sudo wget -O 1lowerthird.png https://www.dropbox.com/s/25xvndu4hzrtvom/1lowerthird.png?dl=0
sudo wget -O 1video.mp4 https://www.dropbox.com/s/il7qa994iv9r7gu/1video.mp4?dl=0
sudo wget -O 1holding.mp4 https://www.dropbox.com/s/vnphorklxm1xopz/1holding.mp4?dl=0
sudo wget -O 1failover.mp4 https://www.dropbox.com/s/b595qj68l3t5g6f/1failover.mp4?dl=0
sudo mkdir lowerthird

#Shift files to right locations
sudo chgrp -R www-data ~/MLS
sudo chmod g+rw -R ~/MLS
sudo cp -R ~/MLS/scripts /etc/nginx
sudo rm -R ~/MLS/scripts/images
sudo chmod +x -R /etc/nginx/scripts
sudo mkdir /etc/nginx/scripts
sudo chmod +x -R /etc/nginx/scripts

cd /etc/nginx/scripts/
for ((i = 2; i <= ${STREAM_NUM}; i++)); do
	sudo cp 1.sh ${i}.sh
	sudo cp ./images/1lowerthird.png ./images/${i}lowerthird.png
	sudo cp ./images/1video.mp4 ./images/${i}video.mp4
	sudo cp ./images/1holding.mp4 ./images/${i}holding.mp4
	sudo cp ./images/1failover.mp4 ./images/${1}failover.mp5
done

sudo cp /etc/nginx/scripts/.htpasswd /etc/nginx/
sudo cp /etc/php/8.3/fpm/php.ini /etc/php/8.3/fpm/php.old
sudo cp /etc/nginx/scripts/php.ini /etc/php/8.3/fpm/
sudo cp /etc/nginx/scripts/images/*lowerthird.png /etc/nginx/scripts/images/lowerthird

sudo systemctl restart php8.3-fpm

sudo cp /etc/nginx/scripts/nginx.conf /etc/nginx/
sudo rm -R /var/www/html
sudo cp -R ~/MLS/html /var/www

#Setup HLS & Recording folders
sudo mkdir /var/www/html/hls
sudo chmod -R 777 /var/www/html/hls

sudo mkdir /var/www/html/recording
sudo chmod -R 777 /var/www/html/recording

cd /var/www/html && sudo npm init -y && sudo npm install ws && cd ~

#Shift Instagram-Live to generic folder
sudo cp -R ~/InstagramLive-PHP /etc/nginx/scripts/ && sudo mv /etc/nginx/scripts/InstagramLive-PHP/ /etc/nginx/scripts/InstagramLive-PHP1/
sudo cp -R /etc/nginx/scripts/InstagramLive-PHP1/ /etc/nginx/scripts/InstagramLive-PHP2/
sudo cp -R /etc/nginx/scripts/InstagramLive-PHP1/ /etc/nginx/scripts/InstagramLive-PHP3/
sudo cp -R /etc/nginx/scripts/InstagramLive-PHP1/ /etc/nginx/scripts/InstagramLive-PHP4/
sudo cp -R /etc/nginx/scripts/InstagramLive-PHP1/ /etc/nginx/scripts/InstagramLive-PHP5/
sudo cp -R /etc/nginx/scripts/InstagramLive-PHP1/ /etc/nginx/scripts/InstagramLive-PHP6/
sudo cp -R /etc/nginx/scripts/InstagramLive-PHP1/ /etc/nginx/scripts/InstagramLive-PHP7/
sudo cp -R /etc/nginx/scripts/InstagramLive-PHP1/ /etc/nginx/scripts/InstagramLive-PHP8/
sudo cp -R /etc/nginx/scripts/InstagramLive-PHP1/ /etc/nginx/scripts/InstagramLive-PHP9/
sudo cp -R /etc/nginx/scripts/InstagramLive-PHP1/ /etc/nginx/scripts/InstagramLive-PHP10/

sudo cp -R ~/MLS /etc/nginx/scripts

# restart nginx with new config. Set it to start on boot.
sudo systemctl start nginx
sudo cp /etc/nginx/scripts/nginxrestart.sh /etc/init.d && sudo update-rc.d nginxrestart.sh defaults

#make a little announcment with useful data for the user
WANIP=$(curl -s http://whatismyip.akamai.com/)
echo "Send source RTMP input on port 1935 to $WANIP"
echo " "
echo "Add www-data ALL=NOPASSWD: /bin/bash, /bin/ls to sudo visudo"
echo " "
