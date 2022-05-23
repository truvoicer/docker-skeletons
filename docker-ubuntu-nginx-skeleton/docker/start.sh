#!/bin/bash

WEB_ROOT=/var/www/html

#REMOVING APACHE DEFAULT HTML
echo REMOVING APACHE DEFAULT HTML
#if [ -f "$WEB_ROOT/index.html" ]; then
#  rm -r "$WEB_ROOT"/index.html
#fi

cd "$WEB_ROOT" || exit

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
