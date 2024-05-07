#!/bin/sh

# Create digest file
DIGEST="$( printf "%s:%s:%s" "$USERNAME" "WebDAV" "$PASSWORD" | md5sum | awk '{print $1}' )"
printf "%s:%s:%s\n" "$USERNAME" "WebDAV" "$DIGEST" >> /digest.user

# Forward logs
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log

# Start nginx
nginx -g "daemon off;"
