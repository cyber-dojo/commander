
[![CircleCI](https://circleci.com/gh/cyber-dojo/commander.svg?style=svg)](https://circleci.com/gh/cyber-dojo/commander)

# the cyber-dojo bash script

Controls a [cyber-dojo](https://cyber-dojo.org) server.
Delegates its commands to a docker container created from
**cyberdojo/commander**.

```text
$ ./cyber-dojo

Use: cyber-dojo [--debug] COMMAND
     cyber-dojo --help

Commands:
    clean        Removes old images/volumes/containers
    down         Brings down the server
    logs         Prints the logs from a service container
    sh           Shells into a service container
    start-point  Manages cyber-dojo start-points
    up           Brings up the server
    update       Updates the server and languages to the latest images

Run 'cyber-dojo COMMAND --help' for more information on a command.
```

# cyberdojo/commander docker image

Installed within **cyberdojo/commander** are docker and docker-compose, together with the
main cyber-dojo server's
[docker-compose.yml](https://github.com/cyber-dojo/commander/blob/master/docker-compose.yml)
file.

# env files

- nginx.env
- grafana.env
- zipper.env
- web.env
This holds environment variables for the web service.
To add a message to the UI footer-info-bar
MESSAGE=your-message-here

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
