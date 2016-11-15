#!/bin/bash

source includes/util.sh

help() {
    echo Usage
    echo pipe create
    echo pipe start
}

create() {
    echo Creating server...
    version=""
    name="$(generateRandomName)"
    port=""
    serverType=""
    base=""

    echo "$name"

    SHORT=v:n:p:t:v:b:
    LONG=version:name:port:type:base:

    PARSED=`getopt --options "$SHORT" --longoptions "$LONG" --name "$0" -- "$@"`
    if [[ "$?" -ne 0 ]]; then
        exit 2
    fi
    eval set -- "$PARSED"

    while true; do
        case "$1" in
            -b|--base)
                version="$2"
                shift 2
                ;;
            *)
                echo "Invalid argument"
                exit 3
                ;;
        esac
    done
}

start() {
    echo Starting server...
}

download() {
    target="$1"

    source config
    mkdir "$download_path"

    case "$target" in
    "buildtools")
        downloadBuildTools
        ;;
    "spigot")
        downloadSpigot "$target"
        ;;
    "bungeecord")
        downloadBungeecord
        ;;
    "all")
        downloadBuildTools
        downloadSpigot "$@"
        downloadBungeecord
        ;;
    *)
        help
        ;;
    esac
}

downloadBuildTools() {
    source config
    cd "$download_path"
    wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar -O BuildTools.jar
}

downloadSpigot() {
    version="latest"

    SHORT=v:
    LONG=version:

    PARSED=`getopt --options "$SHORT" --longoptions "$LONG" --name "$0" -- "$@"`
    if [[ "$?" -ne 0 ]]; then
        exit 2
    fi
    eval set -- "$PARSED"

    while true; do
        case "$1" in
            -v|--version)
                version = "$2"
                shift 2
                ;;
            *)
                echo "Invalid argument"
                exit 3
                ;;
        esac
    done

    source config
    cd "$download_path"
    java -jar BuildTools.jar --rev "$version"
}

downloadBungeecord() {
    source config
    cd "$download_path"
    wget http://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar -O BungeeCord.jar
}

main() {

    getopt --test > /dev/null
    if [[ $? -ne 4 ]]; then
        echo "Sorry, `getopt --test` failed in this environment."
        exit 1
    fi

for i in $*; do
   echo $i
 done

    command="$1"

    case "$command" in
    "create")
        create "$@"
        ;;
    "start")
        start "$@"
        ;;
    "download")
        download "$@"
        ;;
    *)
        help
        ;;
    esac
}

main "$@"