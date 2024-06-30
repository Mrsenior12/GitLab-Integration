#!/bin/bash

GITLAB_URL="http:localhost:80"
GITLAB_USERNAME="root"
GITLAB_PWD=""
GET_INIT=0
REGISTER_RUNNER=0
NEW_PASSWORD=""

while getopts irp: opt; do
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
    esac
done

get_gitlab_initpassword() {
    INIT_PWD=$(docker exec gitlab_server grep "Password:" /etc/gitlab/initial_root_password | awk '{print $2}' )
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

    STATUS=$(curl -s --request PUT "${GITLAB_URL}/api/v4/users/1" \
        --header "PRIVATE-TOKEN: ${GITLAB_ROOT_PWD}" \
        --header "Content-Type: application/json" \
        --data "{\"password\":\"${NEW_PASSWORD}\"}")

    if echo "${STATUS}" | grep -q "errors"; then
        echo "Error while changeing password"
        return 1
    fi;

}

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

if [[ ${GET_INIT} == 1 ]]; then
    echo "Saving GitLab root init password to .env file"
    get_gitlab_initpassword
fi

if [[ ${NEW_PASSWORD} != "" ]]; then
    echo "Changing default password"
    change_init_password
    sed -i "/^GITLAB_USER_PWD=.*/c\GITLAB_USER_PWD=\"${NEW_PASSWORD}\"" ".env"


fi;

