#!/bin/sh
# Nightly backup of the shop (Chloé, 2024)
DATE=$(date +%F)
cp -r /var/www/atelier /var/www/atelier/old/site-$DATE
mysqldump shop > /tmp/shop-$DATE.sql
mysqldump -u shop -pPixel2024! shop > /tmp/shop.sql
gzip /tmp/shop-$DATE.sql
