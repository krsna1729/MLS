#!/bin/bash

STREAM_NUM=25

#Configure Timezone For Recording Timestamps
sudo dpkg-reconfigure tzdata

#Install dependencies
sudo apt-get update && sudo apt-get -y install build-essential libpcre3 libpcre3-dev libssl-dev git zip unzip curl php8.3-cli php8.3-mbstring php8.3-fpm php8.3-mysql php8.3-curl php8.3-gd php8.3-bcmath htop ffmpeg libzmq3-dev nodejs yt-dlp

#Install NGINX with RTMP module
sudo mkdir ~/build && cd ~/build
sudo git clone git://github.com/arut/nginx-rtmp-module.git
sudo wget http://nginx.org/download/nginx-1.26.2.tar.gz
sudo tar xzf nginx-1.26.2.tar.gz
cd nginx-1.26.2
sudo ./configure --with-http_ssl_module --add-module=../nginx-rtmp-module
echo "Hold on! NGINX is installing."
sudo make -s
sudo make install

# Clear the default nginx.config
sudo /usr/local/nginx/sbin/nginx -s stop
sudo cp /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.old

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
sudo cp -R ~/MLS/scripts /usr/local/nginx
sudo rm -R ~/MLS/scripts/images
sudo chmod +x -R /usr/local/nginx/scripts
sudo mkdir /usr/local/nginx/scripts
sudo chmod +x -R /usr/local/nginx/scripts

cd /usr/local/nginx/scripts/
for ((i = 2; i <= ${STREAM_NUM}; i++)); do
	sudo cp 1.sh ${i}.sh
	sudo cp ./images/1lowerthird.png ./images/${i}lowerthird.png
	sudo cp ./images/1video.mp4 ./images/${i}video.mp4
	sudo cp ./images/1holding.mp4 ./images/${i}holding.mp4
	sudo cp ./images/1failover.mp4 ./images/${1}failover.mp5
done

sudo cp /usr/local/nginx/scripts/.htpasswd /usr/local/nginx/conf/
sudo cp /etc/php/8.3/fpm/php.ini /etc/php/8.3/fpm/php.old
sudo cp /usr/local/nginx/scripts/php.ini /etc/php/8.3/fpm/
sudo cp /usr/local/nginx/scripts/images/*lowerthird.png /usr/local/nginx/scripts/images/lowerthird

sudo systemctl restart php8.3-fpm

sudo cp /usr/local/nginx/scripts/nginx.conf /usr/local/nginx/conf/
sudo rm -R /usr/local/nginx/html
sudo cp -R ~/MLS/html /usr/local/nginx

#Setup HLS & Recording folders
sudo mkdir /usr/local/nginx/html/hls
sudo chmod -R 777 /usr/local/nginx/html/hls

sudo mkdir /usr/local/nginx/html/recording
sudo chmod -R 777 /usr/local/nginx/html/recording

cd /usr/local/nginx/html && sudo npm init -y && sudo npm install ws && cd ~

#Shift Instagram-Live to generic folder
sudo cp -R ~/InstagramLive-PHP /usr/local/nginx/scripts/ && sudo mv /usr/local/nginx/scripts/InstagramLive-PHP/ /usr/local/nginx/scripts/InstagramLive-PHP1/
sudo cp -R /usr/local/nginx/scripts/InstagramLive-PHP1/ /usr/local/nginx/scripts/InstagramLive-PHP2/
sudo cp -R /usr/local/nginx/scripts/InstagramLive-PHP1/ /usr/local/nginx/scripts/InstagramLive-PHP3/
sudo cp -R /usr/local/nginx/scripts/InstagramLive-PHP1/ /usr/local/nginx/scripts/InstagramLive-PHP4/
sudo cp -R /usr/local/nginx/scripts/InstagramLive-PHP1/ /usr/local/nginx/scripts/InstagramLive-PHP5/
sudo cp -R /usr/local/nginx/scripts/InstagramLive-PHP1/ /usr/local/nginx/scripts/InstagramLive-PHP6/
sudo cp -R /usr/local/nginx/scripts/InstagramLive-PHP1/ /usr/local/nginx/scripts/InstagramLive-PHP7/
sudo cp -R /usr/local/nginx/scripts/InstagramLive-PHP1/ /usr/local/nginx/scripts/InstagramLive-PHP8/
sudo cp -R /usr/local/nginx/scripts/InstagramLive-PHP1/ /usr/local/nginx/scripts/InstagramLive-PHP9/
sudo cp -R /usr/local/nginx/scripts/InstagramLive-PHP1/ /usr/local/nginx/scripts/InstagramLive-PHP10/

sudo cp -R ~/MLS /usr/local/nginx/scripts

# restart nginx with new config. Set it to start on boot.
sudo /usr/local/nginx/sbin/nginx
sudo cp /usr/local/nginx/scripts/nginxrestart.sh /etc/init.d && sudo update-rc.d nginxrestart.sh defaults

#make a little announcment with useful data for the user
WANIP=$(curl -s http://whatismyip.akamai.com/)
echo "Send source RTMP input on port 1935 to $WANIP"
echo " "
echo "Add www-data ALL=NOPASSWD: /bin/bash, /bin/ls to sudo visudo"
echo " "
