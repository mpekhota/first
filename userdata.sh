#!/bin/bash
yum install httpd -y
touch /var/www/html/index.html && chmod 0755 /var/www/html/index.html
echo This page running in Amazon Cloud! > /var/www/html/index.html
service httpd start
