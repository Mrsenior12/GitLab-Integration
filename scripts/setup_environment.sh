#!/bin/bash

GITLAB_URL="http://gitlab:80"

# Create .env file if it doesn't exist
if [[ ! -f ".env" ]]; then
    echo "Creating .env file with neccessary options to register GitLab runner"
    cat <<EOF > .env
## GitLab Environment
GITLAB_HOME=./gitlab
GITLAB_URL=${GITLAB_URL}
GITLAB_ROOT_PWD=
GITLAB_USER_PWD=

## GitLab Personal Access Token with repo read permissions required by gitlab-ci-pipeline-exporter
GITLAB_PERSONAL_TOKEN_EXPORTER=

## GitLab Personal Access Token with create_runner permissions
GITLAB_PERSONAL_TOKEN_RUNNER=
GITLAB_RUNNER_AUTH_TOKEN=

## Prometheus Environment
PROMETHEUS_HOME=./prometheus

## Grafana Envirnment
GRAFANA_HOME=./grafana

## Blackbox Environment
BLACKBOX_HOME=./blackbox

## GitLab-ci-pipeline-exporter Environment
GITLAB_CI_EXPORTER_HOME=./gitlab-ci-exporter

## Scripts Directory
SCRIPTS_HOME=./scripts
EOF
fi;

REQUIRED_DIRECTORIES=("${GITLAB_HOME}" "${GITLAB_HOME}/gitlab-runner" "${PROMETHEUS_HOME}" "${GRAFANA_HOME}")

for DIRECTORY in "${REQUIRED_DIRECTORIES[@]}"
do
    if [[ ! -d "${DIRECTORY}" ]]; then
        echo "Creating directory: ${DIRECTORY}"
        mkdir -p "${DIRECTORY}"
    fi
done
