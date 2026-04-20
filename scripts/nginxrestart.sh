#!/bin/bash
# Deletes NGINX logs on restart to conserve space
sudo rm /var/log/nginx/*.log

# Resets any lowerthirds applied previously to blank images
sudo cp /etc/nginx/scripts/images/lowerthird/*lowerthird.png /etc/nginx/scripts/images

# Replaces page titles in webpages to name of instance
sudo sed -i "s|<title>.*</title>|<title>$(hostname) Control</title>|" /var/www/html/index.html
sudo sed -i "s|<title>.*</title>|<title>$(hostname) Settings</title>|" /var/www/html/settings.html
sudo sed -i "s|id="\""server-name"\"">.*</|id="\""server-name"\"">MLS: $(hostname)</|" /var/www/html/index.html
sudo sed -i "s|id="\""server-name"\"">.*</|id="\""server-name"\"">MLS: $(hostname)</|" /var/www/html/settings.html
sudo sed -i "s|<title>.*</title>|<title>$(hostname) Stats</title>|" /var/www/html/stat.xsl

# Restart NGINX
sudo systemctl stop nginx
sudo systemctl start nginx
