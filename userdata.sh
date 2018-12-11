#!/bin/bash
yum install httpd -y
echo This page running in Amazon Cloud! > /var/www/html/index.html
touch /var/www/html/index.html && chmod 0755 /var/www/html/index.html
echo This page running in Amazon Cloud! > /var/www/html/index.html
service httpd start
