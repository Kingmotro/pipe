# pipe
<img src="http://i.imgur.com/vnX7x7j.jpg">

Pipe is a server wrapper for Spigot and BungeeCord. It allows your to easily create and manage minecraft server through the command line. It also serves various utility functions allowing you to easily update and backup servers, with a single command

##Requirements
Most servers already include what we need, but in case they don't
* tmux
* getopt
* zip
* Java

##Usage
    pipe [command] [-arguments]
    
###Commands
    backup
    clean
    create
    destroy
    download
    restart
    send
    start
    stop
    update

###General Arguments
    Name              Description
   ######            #############
    -n <name>         Server name
    -v <version>      Version 
                      For Spigot: Use Minecraft version number (eg 1.10.2) or 'latest'
                      For BungeeCord: Use BungeeCord build number (eg 1208) or 'latest'
                      For BuildTools: This doesn't apply
    -a                Apply the operation to all servers; currently unused
    -c                Don't ask for confirmation; currently unused
    -s                Stop the server if it's running before doing the operation; currently unused

###Create Arguments
    -p <port>         Server port
    -t <type>         Server type (spigot or bungeecord)
    -b <name>         Base server; currently unused

###Start Arguments
    -f                Force startup; Kill any process using the servers port; currently unused

###Stop Arguments
    -k                Kill the server immediately; don't wait for it to stop; currently unused
    
