#!/bin/bash

docker exec -it gitlab_server grep 'Password:' /etc/gitlab/initial_root_password > root_pwd.txt
