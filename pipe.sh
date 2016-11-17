#!/usr/bin/env bash

source includes/util.sh
source config

declare -A bungeecord_versions

help() {
    echo Usage
    echo pipe create
    echo pipe start
    echo pipe download
}

create() {
    echo Creating server...
    version="latest"
    name=""
    port="25565"
    serverType="spigot"
    base=""

    SHORT="n:p:t:v:b:"
    LONG="name:,port:,type:,version:,base:"

    # -temporarily store output to be able to check for errors
    # -activate advanced mode getopt quoting e.g. via “--options”
    # -pass arguments only via   -- "$@"   to separate them correctly
    PARSED=`getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@"`
    if [[ $? -ne 0 ]]; then
        # e.g. $? == 1
        #  then getopt has complained about wrong arguments to stdout
        exit 2
    fi
    # use eval with "$PARSED" to properly handle the quoting
    eval set -- "$PARSED"

    # now enjoy the options in order and nicely split until we see --
    while true; do
        case "$1" in
            -n|--name)
                name="$2"
                shift 2
                ;;
            -p|--port)
                port="$2"
                shift 2
                ;;
            -t|--type)
                serverType="$2"
                shift 2
                ;;
            -v|--version)
                version="$2"
                shift 2
                ;;
            -b|--base)
                base="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Invalid argument"
                exit 3
                ;;
        esac
    done

    if [ "$name" == "" ]; then
        # No name give
        # Finally my random name generator has a chance to shine!
        name="$(generateRandomName)"
    fi

    if [ "$base" != "" ]; then
        # We need to copy over the needed files
        echo "This feature isn't ready yet!"
    fi

    echo "Name: $name"
    echo "Port: $port"
    echo "Type: $serverType"
    echo "Version: $version"
    echo "Base: $base"

    mkdir -p "$servers_path/$name/"

    if [ "$serverType" == "spigot" ]; then
        createSpigot "$name" "$port" "$version"
    elif [ "$serverType" == "bungeecord" ]; then
        createBungeecord "$name" "$port" "$version"
    else
        echo "Invalid type"
        exit 3
    fi
}

destroy() {
    name=""

    SHORT="n:"
    LONG="name:"

    # -temporarily store output to be able to check for errors
    # -activate advanced mode getopt quoting e.g. via “--options”
    # -pass arguments only via   -- "$@"   to separate them correctly
    PARSED=`getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@"`
    if [[ $? -ne 0 ]]; then
        # e.g. $? == 1
        #  then getopt has complained about wrong arguments to stdout
        exit 2
    fi
    # use eval with "$PARSED" to properly handle the quoting
    eval set -- "$PARSED"

    # now enjoy the options in order and nicely split until we see --
    while true; do
        case "$1" in
            -n|--name)
                name="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Invalid argument"
                exit 3
                ;;
        esac
    done

    echo "Destroying $name... All files will be deleted"

    if [ -f "$servers_path/$name/pipe.cfg" ]; then
        tmux kill-session -t "$name"
        rm -rf "$servers_path/$name"
    else
        echo "It doesn't look like there's a server here..."
        exit 3
    fi;   
}

createSpigot() {
    name="$1"
    port="$2"
    version="$3"

    if [ "$version" == "latest" ]; then
        download "spigot" "latest"
        echo Copying latest version of Spigot
        cp "$download_path/buildtools/spigot-1.10.2.jar" "$servers_path/$name/spigot.jar"
    else
        if [ ! -f "$download_path/buildtools/spigot-$version.jar" ]; then
            echo "Spigot $version not downloaded; downloading it"
            download "spigot" "$version"
        else
            echo "Spigot $version already downloaded; copying it"
        fi
        cp "$download_path/buildtools/spigot-$version.jar" "$servers_path/$name/spigot.jar"
    fi
    printf "eula=true" > "$servers_path/$name/eula.txt"
    printf "server-port=$port" > "$servers_path/$name/server.properties"
    printf "max_ram=1G\nmin_ram=512M" > "$servers_path/$name/pipe.cfg"
}

createBungeecord() {
    name="$1"
    port="$2"
    version="$3"
    download "bungeecord" "$version"
    cp "$download_path/BungeeCord.jar" "$servers_path/$name/BungeeCord.jar"
    printf "max_ram=512M\nmin_ram=128M" > "$servers_path/$name/pipe.cfg"
    # We also need to set the config port here
}

update() {
    name=""
    stop="false"

    SHORT="n:"
    LONG="name:"

    # -temporarily store output to be able to check for errors
    # -activate advanced mode getopt quoting e.g. via “--options”
    # -pass arguments only via   -- "$@"   to separate them correctly
    PARSED=`getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@"`
    if [[ $? -ne 0 ]]; then
        # e.g. $? == 1
        #  then getopt has complained about wrong arguments to stdout
        exit 2
    fi
    # use eval with "$PARSED" to properly handle the quoting
    eval set -- "$PARSED"

    # now enjoy the options in order and nicely split until we see --
    while true; do
        case "$1" in
            -n|--name)
                name="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Invalid argument"
                exit 3
                ;;
        esac
    done

    echo "Updating $name to the last downloaded jar"

    if [ -f "$servers_path/$name/spigot.jar" ]; then
        updateSpigot "$name"
    elif [ -f "$servers_path/$name/BungeeCord.jar" ]; then
        updateBungeecord "$name"
    else
        echo "It doesn't look like there's a server here..."
        exit 3
    fi;
}

updateSpigot() {
    name="$1"
    cp "$download_path/buildtools/spigot-1.10.2.jar" "$servers_path/$name/spigot.jar"
}

updateBungeecord() {
    name="$1"
    cp "$download_path/BungeeCord.jar" "$servers_path/$name/BungeeCord.jar"
}

start() {
    name=""
    force="false"

    SHORT="n:f"
    LONG="name:,force"

    # -temporarily store output to be able to check for errors
    # -activate advanced mode getopt quoting e.g. via “--options”
    # -pass arguments only via   -- "$@"   to separate them correctly
    PARSED=`getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@"`
    if [[ $? -ne 0 ]]; then
        # e.g. $? == 1
        #  then getopt has complained about wrong arguments to stdout
        exit 2
    fi
    # use eval with "$PARSED" to properly handle the quoting
    eval set -- "$PARSED"

    # now enjoy the options in order and nicely split until we see --
    while true; do
        case "$1" in
            -n|--name)
                name="$2"
                shift 2
                ;;
            -f|--force)
                force="true"
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Invalid argument"
                exit 3
                ;;
        esac
    done

    echo "Starting $name..."

    cd "$servers_path/$name"
    source pipe.cfg

    if [ -f "spigot.jar" ]; then
        tmux new -d -s "$name" "java -Xms${min_ram} -Xmx${max_ram} -jar spigot.jar"
    elif [ -f "BungeeCord.jar" ]; then
        tmux new -d -s "$name" "java -Xms${min_ram} -Xmx${max_ram} -jar BungeeCord.jar"
    else
        echo "It doesn't look like there's a server here..."
        exit 3
    fi;
}

stop() {
    name=""
    killServer="false"

    SHORT="n:k"
    LONG="name:,kill"

    # -temporarily store output to be able to check for errors
    # -activate advanced mode getopt quoting e.g. via “--options”
    # -pass arguments only via   -- "$@"   to separate them correctly
    PARSED=`getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@"`
    if [[ $? -ne 0 ]]; then
        # e.g. $? == 1
        #  then getopt has complained about wrong arguments to stdout
        exit 2
    fi
    # use eval with "$PARSED" to properly handle the quoting
    eval set -- "$PARSED"

    # now enjoy the options in order and nicely split until we see --
    while true; do
        case "$1" in
            -n|--name)
                name="$2"
                shift 2
                ;;
            -k|--kill)
                killServer="true"
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Invalid argument"
                exit 3
                ;;
        esac
    done

    echo "Stopping $name..."

    cd "$servers_path/$name"
    source pipe.cfg

    if [ -f "spigot.jar" ]; then
        tmux send -t "$name" stop ENTER
    elif [ -f "BungeeCord.jar" ]; then
        tmux send -t "$name" end ENTER
    else
        echo "It doesn't look like there's a server here..."
        exit 3
    fi;
}

restart() {
    stop "$@"
    start "$@"
}

backup() {
    echo Stub
}

clean() {
    echo Stub
}

download() {
    target="$1"
    version="$2"

    mkdir -p "$download_path"

    case "$target" in
        "buildtools")
            downloadBuildTools
            ;;
        "spigot")
            downloadSpigot "$version"
            ;;
        "bungeecord")
            downloadBungeecord "$version"
            ;;
        "all")
            downloadBuildTools
            downloadSpigot "$@"
            downloadBungeecord "$@"
            ;;
        *)
            echo Invalid argument
            exit 3
            ;;
    esac
}

downloadBuildTools() {
    echo Downloading latest buildtools...
    mkdir -p "$download_path/buildtools"
    wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar -O "$download_path/buildtools/BuildTools.jar"
}

downloadSpigot() {
    version="latest"

    SHORT="v:"
    LONG="version:"

    # -temporarily store output to be able to check for errors
    # -activate advanced mode getopt quoting e.g. via “--options”
    # -pass arguments only via   -- "$@"   to separate them correctly
    PARSED=`getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@"`
    if [[ $? -ne 0 ]]; then
        # e.g. $? == 1
        #  then getopt has complained about wrong arguments to stdout
        exit 2
    fi
    # use eval with "$PARSED" to properly handle the quoting
    eval set -- "$PARSED"

    # now enjoy the options in order and nicely split until we see --
    while true; do
        case "$1" in
            -v|--version)
                version="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Invalid argument"
                exit 3
                ;;
        esac
    done

    if [ ! -f "$download_path/buildtools/BuildTools.jar" ]; then
        echo "BuildTools isn't already downloaded, getting it now"
        download "buildtools"
    fi
    
    echo Running BuildTools...
    cd "$download_path/buildtools/"
    java -jar BuildTools.jar --rev "$version" > /dev/null
    cd -
}

downloadBungeecord() {
    version="lastSuccessfulBuild"

    SHORT="v:"
    LONG="version:"

    # -temporarily store output to be able to check for errors
    # -activate advanced mode getopt quoting e.g. via “--options”
    # -pass arguments only via   -- "$@"   to separate them correctly
    PARSED=`getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@"`
    if [[ $? -ne 0 ]]; then
        # e.g. $? == 1
        #  then getopt has complained about wrong arguments to stdout
        exit 2
    fi
    # use eval with "$PARSED" to properly handle the quoting
    eval set -- "$PARSED"

    # now enjoy the options in order and nicely split until we see --
    while true; do
        case "$1" in
            -v|--version)
                version="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Invalid argument"
                exit 3
                ;;
        esac
    done

    if [ "$version" == "latest" ]; then
        $version = "lastSuccessfulBuild"
    fi

    wget http://ci.md-5.net/job/BungeeCord/$version/artifact/bootstrap/target/BungeeCord.jar -O "$download_path/BungeeCord.jar"
}

main() {
    getopt --test > /dev/null
    if [[ $? -ne 4 ]]; then
        echo "Sorry, `getopt --test` failed in this environment."
        exit 1
    fi

    command="$1"

    case "$command" in
        "create")
            create "$@"
            ;;
        "destroy")
            destroy "$@"
            ;;
        "start")
            start "$@"
            ;;
        "stop")
            stop "$@"
            ;;
        "restart")
            restart "$@"
            ;;
        "download")
            download "$2" "$3"
            ;;
        "update")
            update "$2" "$3"
            ;;
        *)
            help
            ;;
    esac
}

main "$@"
