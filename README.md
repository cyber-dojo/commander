
[![CircleCI](https://circleci.com/gh/cyber-dojo/commander.svg?style=svg)](https://circleci.com/gh/cyber-dojo/commander)

# the cyber-dojo bash script

Assuming you have followed [these setup instructions](https://blog.cyber-dojo.org/2014/09/setting-up-your-own-cyber-dojo-server.html) you can use the main cyber-dojo script to control a [cyber-dojo](https://cyber-dojo.org) server.

To bring up a default server:
```bash
./cyber-dojo up
```

To update to the latest version and switch to it:
```bash
./cyber-dojo update
./cyber-dojo up
```

To see an overview of available commands:
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

# overridable start-point images
...

# overridable .env files
There are default .env files for three services:
- nginx.env
- grafana.env
- web.env
You can override these as follows:
- Create your own .env file, eg nginx.env
- Set an environment-variable to its absolute path. For example:
  ```bash
  export CYBER_DOJO_NGINX_ENV=/home/fred/nginx.env
  ```
- Reissue the up command:
  ```bash
  ./cyber-dojo up
  ...
  Using nginx.env=/home/fred/nginx.env (custom)
  ...
  ```

- - - -

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
