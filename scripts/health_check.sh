#!/bin/sh

# RESPONSE_CODE=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' "http://localhost:80")   

printenv 

RESPONSE_CODE=$(wget --spider -S "http://localhost:80" 2>&1 | grep "HTTP/" | tail -n 1 | awk '{print $2}' )

if [[ $? -eq 0  ]] &&  [[ ${RESPONSE_CODE} -eq 200 ]] || [[ ${RESPONSE_CODE} -eq 302 ]]; then
    echo 0
else
    echo 1
fi
