#!/bin/bash

GITLAB_URL="http:localhost:80"

# Create .env file if it doesn't exist
if [[ ! -f ".env" ]]; then
    echo "Creating .env file with neccessary options to register GitLab runner"
    cat <<EOF > .env
## GitLab Environment
GITLAB_HOME=./gitlab
GITLAB_URL=${GITLAB_URL}
GITLAB_ROOT_PWD=
GITLAB_USER_PWD=
GITLAB_ACCESS_TOKEN=

## GitLab Personal Access Token with repo read permissions required by gitlab-ci-pipeline-exporter
GITLAB_PERSONAL_TOKEN=

## GitLab Personal Access Token with create_runner permissions
GITLAB_PERSONAL_TOKEN_RUNNER=

## Prometheus Environment
PROMETHEUS_HOME=./prometheus

## Grafana Envirnment
GRAFANA_HOME=./grafana
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