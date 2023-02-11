#!/bin/bash
version=1.0.1
Help() {
    echo "Running respository service - version: $version"
    echo "usage: bash setup.py [options] [command]"
    echo "commands:"
    echo " -p| password default admin"
    echo " -u| username default admin"
    echo "options:"
    echo " -h| show this help"
    echo " -v| show this version"
    echo " -a| add authentication"
    echo " -A| jsut add user"
}
mkdir -p ./docker-auth/
mkdir -p ./packages/
mkdir -p ./docker-auth/
mkdir -p ./pypi-auth/
mkdir -p ./registry/

add_user() {
    if [ "$1" == "" ]; then
        uname="admin"
    else
        uname="$1"
    fi
    if [ "$2" == "" ]; then
        pass="admin"
    else
        pass="$2"
    fi
    docker run \
        --entrypoint htpasswd \
        --name htpass \
        httpd:2 -Bbn "$uname" "$pass" >docker-auth/htpasswd
    echo "deleting container: htpass"
    docker rm -f htpass
}
auth="0"
add="0"
while getopts :haAvp:u: flag; do
    case "${flag}" in
    h)
        Help
        exit
        ;;
    v)
        echo "$version"
        exit
        ;;
    a)
        auth="1"
        ;;
    A)
        add="1"
        ;;
    u) username=${OPTARG} ;;
    p) pass=${OPTARG} ;;
    esac
done

with_auth() {

    if [ "$pass" == "" ] && [ "$username" == "" ]; then
        echo "adding user with default credentials, [admin,admin]..."
        add_user
    else
        echo "adding user to the htpasswd..."
        add_user "$username" "$pass"
    fi

    docker stack deploy -c docker-compose-auth.yml repositories
}

if [ "$add" == "1" ]; then
    if [ "$pass" == "" ] && [ "$username" == "" ]; then
        echo "adding user with default credentials, [admin,admin]..."
        add_user
    else
        echo "adding user to the htpasswd..."
        add_user "$username" "$pass"
    fi
    exit
fi

if [ "$auth" == "0" ]; then
    docker stack deploy -c docker-compose-simple.yml repositories
else
    with_auth
fi
