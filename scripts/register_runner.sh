#!/bin/bash

GITLAB_URL="http:localhost:80"
GITLAB_USERNAME="root"
GITLAB_PWD=""
GET_INIT=0
REGISTER_RUNNER=0
NEW_PASSWORD=""
TOKEN_TYPE=""

while getopts irpt: opt; do
    case ${opt} in
        i) 
        # Option for fetching root_init_password from /etc/gitlab/initial_root_password
        # Following file will be removed after 24h after first startup of GitLab instance
        # After fetching this password it will save it to .env file
            GET_INIT=1
            ;;
        r)
        # Option used for registering GitLab runner supporting Dokcer
            REGISTER_RUNNER=1
            ;;
        p)
        # Option used to set custom password for root user in GitLab instance
        # Provided password will be saved in .env file
            NEW_PASSWORD=${OPTARG}
            ;;
        t)
        # Option used to create Personal Access Token for GitLab-CI-pipeline-exporter
            TOKEN_TYPE="exporter"
            ;;
    esac
done

if [[ $(docker inspect -f '{{.State.Status}}' gitlab) != "running" ]]; then
    echo "GitLab instance is not running"
    exit 1
fi

source .env

get_gitlab_initpassword() {
    INIT_PWD=$(docker exec gitlab grep "Password:" /etc/gitlab/initial_root_password | awk '{print $2}' )
    if [[ ${GITLAB_ROOT_PWD} == "" ]]; then
        sed -i "/^GITLAB_ROOT_PWD=.*/c\GITLAB_ROOT_PWD=\"${INIT_PWD}\"" ".env"
    fi; 
}

change_init_password(){
    get_gitlab_initpassword
    if [[ ${GITLAB_ROOT_PWD} == "" ]]; then
        echo "Unable to fetch root password"
        exit 1
    fi;
    
    docker exec -it gitlab gitlab-rails runner "user = User.find_by_username('root'); user.password = '${NEW_PASSWORD}'; user.password_confirmation = '${NEW_PASSWORD}'; user.save!"

}

generate_personal_access_token(){
    local TOKEN_NAME=${1}
    local TOKEN_SCOPE=${2}
    local TOKEN_SHA=${3}

    docker exec -it \
        --env TOKEN_NAME=${TOKEN_NAME} \
        --env TOKEN_SCOPE=${TOKEN_SCOPE} \
        --env TOKEN_SHA=${TOKEN_SHA} gitlab \
            gitlab-rails runner "token = User.find_by_username('root').personal_access_tokens.create(scopes: ['${TOKEN_SCOPE}'], name: '${TOKEN_NAME}', expires_at: 1.year.from_now); \
                token.set_token('${TOKEN_SHA}'); \
                token.save!"

}

if [[ ${GET_INIT} == 1 ]]; then
    echo "Saving GitLab root init password to .env file"    
fi

if [[ ${NEW_PASSWORD} != "" ]]; then
    echo "Changing default password"
    change_init_password
    sed -i "/^GITLAB_USER_PWD=.*/c\GITLAB_USER_PWD=\"${NEW_PASSWORD}\"" ".env"
fi;

if [[ ${TOKEN_TYPE} == "exporter" ]]; then
    echo "--- Creating Personal Access Token for GitLab-CI-pipeline-exporter ---"

    SHA_VALUE=$(echo $RANDOM | shasum | head -c 30)
    generate_personal_access_token "GitLab-Exporter-TokenV2" "read_api" "${SHA_VALUE}"
    sed -i "/^GITLAB_PERSONAL_TOKEN_EXPORTER=.*/c\GITLAB_PERSONAL_TOKEN_EXPORTER=\"${SHA_VALUE}\"" ".env"

fi

if [[ ${REGISTER_RUNNER} == 1 ]]; then
    if [[ ${GITLAB_PERSONAL_TOKEN_RUNNER} == "" ]]; then
        echo "--- Creating Personal Access Token for GitLab Runner ---"
        SHA_VALUE=$(echo $RANDOM | shasum | head -c 30)
        generate_personal_access_token "GitLab-Runner-TokenV2" "create_runner" "${SHA_VALUE}"
    

        sed -i "/^GITLAB_PERSONAL_TOKEN_RUNNER=.*/c\GITLAB_PERSONAL_TOKEN_RUNNER=\"${SHA_VALUE}\"" ".env"

        TOKEN_JSON=$(curl --request POST --header "PRIVATE-TOKEN: ${SHA_VALUE}" --data "runner_type=instance_type" \
            "http://localhost:80/api/v4/user/runners")

        AUTH_TOKEN=$(echo ${TOKEN_JSON} | awk -F'"token":"|"' '{print $4}')
        sed -i "/^GITLAB_RUNNER_AUTH_TOKEN=.*/c\GITLAB_RUNNER_AUTH_TOKEN=\"${AUTH_TOKEN}\"" ".env"

        GITLAB_RUNNER_AUTH_TOKEN=${AUTH_TOKEN}
    fi

    echo "--- Registering GitLab Runner ---"
    docker exec --env GITLAB_RUNNER_AUTH_TOKEN=${GITLAB_RUNNER_AUTH_TOKEN} \
                --env URL="http://gitlab:80" \
                gitlab_runner gitlab-runner register \
                --non-interactive \
                --url "${URL}" \
                --token "${GITLAB_RUNNER_AUTH_TOKEN}" \
                --executor "docker" \
                --docker-image docker:latest \
                --description "docker-runner"   

    # Add to register runner configuration additional information
    docker exec gitlab_runner sed -i '/network_mtu = 0/a\    network_mode = "gitlab_network"' /etc/gitlab-runner/config.toml 
    docker exec gitlab_runner sed -i 's|volumes = \["/cache"\]|volumes = \["/var/run/dock.sock:/var/run/dock.sock", "/cache"\]|' /etc/gitlab-runner/config.toml 

fi

source .env
