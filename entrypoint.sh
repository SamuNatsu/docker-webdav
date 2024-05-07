#!/bin/sh

# Create digest file
DIGEST="$( printf "%s:%s:%s" "$USERNAME" "WebDAV" "$PASSWORD" | md5sum | awk '{print $1}' )"
printf "%s:%s:%s\n" "$USERNAME" "WebDAV" "$DIGEST" >> /digest.user

# Start nginx
nginx -g "daemon off;"
