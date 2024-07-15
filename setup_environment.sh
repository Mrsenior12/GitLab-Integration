#!/bin/bash

GITLAB_URL="http:localhost:80"

# Create .env file if it doesn't exist
if [[ ! -f ".env" ]]; then
    echo "Creating .env file with neccessary options to register GitLab runner"
    cat <<EOF > .env
GITLAB_HOME=./gitlab
GITLAB_URL=${GITLAB_URL}
GITLAB_ROOT_PWD=
GITLAB_USER_PWD=
GITLAB_REGISTRY_TOKEN=
GITLAB_PERSONAL_TOKEN=
EOF
fi;

# Load Environmental Variables
source .env

REQUIRED_DIRECTORIES=("${GITLAB_HOME}")

for DIRECTORY in "${REQUIRED_DIRECTORIES[@]}"
do
    if [[ ! -d "${DIRECTORY}" ]]; then
        echo "Creating directory: ${DIRECTORY}"
        mkdir -p "${DIRECTORY}"
    fi
done