#!/bin/sh

help="Usage2 > bash Setup.sh [commands : -n[name]] [-p[password] [-t type of installation [SIMPLE,SSL]] ] "
mkdir -p ./auth/
mkdir -p ./certs/
mkdir -p ./registry/
setup_simple() {
    if [ "$Rame" == "" ]; then
        Rame="registry"
    fi
    if [ "$port" == "" ]; then
        port=5000
    fi
    echo "deleting container: $Rame"
    docker rm -f "$Rame"
    sh SimpleHtpasswdAuth.sh "$Rame" "$port"
}

setup_ssl() {
    if [ "$Rame" == "" ]; then
        Rame="registry"
    fi
    if [ "$port" == "" ]; then
        port=5000
    fi
    echo "deleting container: $Rame"
    docker rm -f "$Rame"
    sh SSLHtpasswdAuth.sh "$Rame" "$port"
}

add_user() {

    if [ "$1" == "" ]; then
        name="root"
    else
        name="$1"
    fi
    if [ "$2" == "" ]; then
        pass="root"
    else
        pass="$2"
    fi
    docker run \
        --entrypoint htpasswd \
        --name htpass \
        httpd:2 -Bbn "$name" "$pass" >auth/htpasswd
    echo "deleting container: htpass"
    docker rm -f htpass
}

while getopts t:n:p:N:P: flag; do
    case "${flag}" in
    t) type=${OPTARG} ;;
    n) name=${OPTARG} ;;
    p) pass=${OPTARG} ;;
    N) Rame=${OPTARG} ;;
    P) port=${OPTARG} ;;
    esac
done

run_simple_setup=false
run_ssl_setup=false

case "$type" in
SIMPLE)
    run_simple_setup=true
    ;;
SSL)
    run_ssl_setup=true
    ;;
*)
    echo "Unknown type $type"
    exit 1
    ;;
esac

if [ "$pass" == "" ] && [ "$name" == "" ]; then
    echo "adding user with default credentials, [root,root]..."
    add_user
else
    echo "adding user to the htpasswd..."
    add_user "$name" "$pass"
fi

if [ $run_simple_setup == true ]; then
    echo "running simple setup..."
    setup_simple
elif [ $run_ssl_setup == true ]; then
    echo "running ssl setup..."
    setup_ssl
else
    echo "$help"
fi
