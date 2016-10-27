[![Build Status](https://travis-ci.org/cyber-dojo/commander.svg?branch=master)](https://travis-ci.org/cyber-dojo/commander)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png" alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# the **cyber-dojo** bash script

The cyber-dojo shell script controls a
[cyber-dojo](http://cyber-dojo.org) web server.
It delegates its commands to a docker container created from the
cyberdojo/commander docker image.

```
$ ./cyber-dojo

Use: cyber-dojo [--debug] COMMAND
     cyber-dojo --help

Commands:
    clean        Removes dangling images
    down         Brings down the server
    logs         Prints the logs from the server
    sh           Shells into the server
    up           Brings up the server
    update       Updates the server to the latest images
    start-point  Manages cyber-dojo start-points

Run 'cyber-dojo COMMAND --help' for more information on a command.
```

# **cyberdojo/commander** docker image

Embedded within cyberdojo/commander are docker and docker-compose, together with its
docker-compose.yml.
