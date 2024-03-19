#!/usr/bin/env bash


obtain_initial_root_password() {
    full_line=$(docker exec -it "${PROJECT_NAME}_gitlabserver_1" grep 'Password:' /etc/gitlab/initial_root_password)

    result=$?

    if [ "$result" -ne "0" ]
    then
        echo "${full_line}"
        echo "docker exec failed"
        return 1
    fi

    password="${full_line}//Password: /}"
    if [ -z "${password}" ]
    then
        echo "docker exec output empty"
        return 2
    fi

    echo "${password}"
    return 0
}


set_new_root_password() {
    user="root"
    new_password="$1"
    docker exec -it "${PROJECT_NAME}_gitlabserver_1" gitlab-rails runner "user = User.find_by_username('$user'); user.password = '$new_password'; user.password_confirmation = '$new_password'; user.save!"

    return 0
}


obtain_personal_access_token() {
    token='token-string-here'
    output=$(docker exec -it "${PROJECT_NAME}_gitlabserver_1 gitlab-rails" runner "token = User.find_by_username('root').personal_access_tokens.create(scopes: ['api', 'read_api', 'read_user', 'create_runner', 'k8s_proxy', 'read_repository', 'write_repository', 'ai_features', 'sudo', 'admin_mode'], name: 'Automation token', expires_at: 365.days.from_now); token.set_token('$token'); token.save!")

    result=$?
    if [ "$result" -ne "0" ]
    then
        echo "${output}"
        echo "docker exec failed"
        return 1
    fi

    echo "$token"
    return 0
}


obtain_runner_authentication_token() {
    personal_access_token="$1"
    curl --version > /dev/null
    json=$(curl --request POST --url "${NETWORK_16BIT_PREFIX}.0.2/api/v4/user/runners" --data "runner_type=instance_type" --data "description=runner" --data "tag_list=one" --header "PRIVATE-TOKEN: $personal_access_token")

    result=$?
    if [ "$result" -ne "0" ]
    then
        echo "${json}"
        echo "docker exec failed"
        return 1
    fi

    jq --version > /dev/null
    token=$(echo "$json" | jq '.token' -r)

    echo "$token"
    return 0
}
