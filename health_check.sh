#!/bin/sh

wget --quiet --tries=1 --spider "http://gitlab_server:80" >/dev/null 2>&1   
if [[ $? -eq 0 ]]; then
    echo 0
else
    echo 1
fi
