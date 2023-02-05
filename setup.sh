#!/bin/bash
version=1.0.0
Help() {
    echo "Running pypi respository - version: $version"
    echo "usage: bash setup.py [options] [command]"
    echo "commands:"
    echo " -P| port default 8080"
    echo " -p| password default root"
    echo " -u| username default root"
    echo " -n| docker name default pypi"
    echo "options:"
    echo " -h| show this help"
    echo " -v| show this version"
    echo " -a| add authentication"
}
mkdir -p ./auth/
mkdir -p ./packages/

run_docker() {
    if [ "$1" == "" ]; then
        port=8080
    else
        port="$1"
    fi
    if [ "$2" == "" ]; then
        dname="pypi"
    else
        dname="$2"
    fi
    echo "deleting container: $dname"
    docker rm -f $dname
    docker run -d -p $port:8080 --name $dname \
    -v $(pwd)/auth/.htpasswd:/data/.htpasswd \
    -v $(pwd)/packages:/data/packages \
    --restart=always \
    pypiserver/pypiserver:latest
}
run_docker_no_auth() {
    if [ "$1" == "" ]; then
        port=8080
    else
        port="$1"
    fi
    if [ "$2" == "" ]; then
        dname="pypi"
    else
        dname="$2"
    fi
    echo "deleting container: $dname"
    docker rm -f $dname
    docker run -d -p $port:8080 --name $dname \
    -v $(pwd)/packages:/data/packages \
    --restart=always \
    pypiserver/pypiserver:latest
}
add_user() {
    if [ "$1" == "" ]; then
        uname="root"
    else
        uname="$1"
    fi
    if [ "$2" == "" ]; then
        pass="root"
    else
        pass="$2"
    fi
    docker run \
    --entrypoint htpasswd \
    --name htpass \
    httpd:2 -Bbn "$uname" "$pass" >auth/.htpasswd
    echo "deleting container: htpass"
    docker rm -f htpass
}
# while getopts :h:v option; do
#     case "$option" in
#     h)
#         Help
#         exit
#         ;;
#     v)
#         echo "$version"
#         exit
#         ;;
#     esac
# done
auth="0"
while getopts :havp:P:u:n: flag; do
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
    P) port=${OPTARG} ;;
    p) pass=${OPTARG} ;;
    u) username=${OPTARG} ;;
    n) name=${OPTARG} ;;
    esac
done

with_auth() {

    if [ "$pass" == "" ] && [ "$username" == "" ]; then
        echo "adding user with default credentials, [root,root]..."
        add_user
    else
        echo "adding user to the htpasswd..."
        add_user "$username" "$pass"
    fi

    run_docker "$port" "$name"
}

if [ "$auth" == "0" ]; then
    run_docker_no_auth "$port" "$name"
else
    with_auth
fi
