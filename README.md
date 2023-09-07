[![Github Action (main)](https://github.com/cyber-dojo/commander/actions/workflows/main.yml/badge.svg)](https://github.com/cyber-dojo/commander/actions)

# cyberdojo/commander docker image

- The source for the [cyberdojo/commander](https://hub.docker.com/r/cyberdojo/commander/tags) Docker image.
- Provides the main `cyber-dojo` bash script to control a cyber-dojo server
- Provides the `cyberdojo/commander` docker image which receives commands delegated from the main `cyber-dojo` bash script.


```bash
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
    update       Updates the server to latest or to a given version
    version      Displays the current version

Run 'cyber-dojo COMMAND --help' for more information on a command.
```

- - - -

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
