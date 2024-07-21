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

if [[ $(docker ps | egrep "gitlab_server" | awk '{print $7}') != "Up" ]]; then
    echo "GitLab instance is not running"
    exit 1
fi

source .env

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
    
    docker exec -it gitlab_server gitlab-rails runner "user = User.find_by_username('root'); user.password = '${NEW_PASSWORD}'; user.password_confirmation = '${NEW_PASSWORD}'; user.save!"

}

if [[ ${GET_INIT} == 1 ]]; then
    echo "Saving GitLab root init password to .env file"
    get_gitlab_initpassword
fi

if [[ ${NEW_PASSWORD} != "" ]]; then
    echo "Changing default password"
    change_init_password
    sed -i "/^GITLAB_USER_PWD=.*/c\GITLAB_USER_PWD=\"${NEW_PASSWORD}\"" ".env"
fi;

