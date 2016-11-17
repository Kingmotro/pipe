#!/usr/bin/env bash

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