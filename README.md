
<img width="707" alt="cyber-dojo-screen-shot" src="https://cloud.githubusercontent.com/assets/252118/25101292/9bdca322-23ab-11e7-9acb-0aa5f9c5e005.png">

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

- - - -

[![Build Status](https://travis-ci.org/cyber-dojo/commander.svg?branch=master)](https://travis-ci.org/cyber-dojo/commander)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png" alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# the cyber-dojo bash script

Controls a [cyber-dojo](http://cyber-dojo.org) web server.
Delegates its commands to a docker container created from
**cyberdojo/commander**.

```
$ ./cyber-dojo

Use: cyber-dojo [--debug] COMMAND
     cyber-dojo --help

Commands:
    clean        Removes old images/volumes/containers
    down         Brings down the server
    logs         Prints the logs from the server
    sh           Shells into the server
    start-point  Manages cyber-dojo start-points
    up           Brings up the server
    update       Updates the server to the latest images

Run 'cyber-dojo COMMAND --help' for more information on a command.
```

# cyberdojo/commander docker image

Installed within **cyberdojo/commander** are docker and docker-compose, together with the
main cyber-dojo server's
[docker-compose.yml](https://github.com/cyber-dojo/commander/blob/master/docker-compose.yml)
file.

