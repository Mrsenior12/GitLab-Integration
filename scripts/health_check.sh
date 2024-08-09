#!/bin/bash

RESPONSE_CODE=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' "http://localhost:80")   

if [[ $? -eq 0 && ${RESPONSE_CODE} -eq 302 ]]; then
    echo 0
else
    echo 1
fi
