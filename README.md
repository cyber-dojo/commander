
[![CircleCI](https://circleci.com/gh/cyber-dojo/commander.svg?style=svg)](https://circleci.com/gh/cyber-dojo/commander)

# cyber-dojo

Assuming you have followed [these setup instructions](https://blog.cyber-dojo.org/2014/09/setting-up-your-own-cyber-dojo-server.html) you can use the main cyber-dojo bash script to control a [cyber-dojo](https://cyber-dojo.org) server.

To bring up a default server:
```bash
$ cyber-dojo up
```

To update to the latest version and switch to it:
```bash
$ cyber-dojo update
$ cyber-dojo up
```

To see an overview of available commands:
```bash
$ cyber-dojo --help
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

# overridable port
By default your cyber-dojo server will be on port 80.
You can override this in two ways:
* with an environment variable
  ```bash
  $ export CYBER_DOJO_PORT=81
  $ cyber-dojo up
  ...
  Using port=81
  ...
  ```
* with a command-line argument
  ```bash
  $ cyber-dojo up --port=82
  ...
  Using port=82
  ...
  ```

# overridable start-point images
...TODO...

# overridable .env files
There are default .env files for three services:
- nginx.env
- grafana.env
- web.env

You can override these as follows:
- Create your own .env file, eg nginx.env
- Set an environment-variable to its absolute path. For example:
  ```bash
  $ export CYBER_DOJO_NGINX_ENV=/home/fred/nginx.env
  ```
- Re-issue the up command:
  ```bash
  $ cyber-dojo up
  ```
- Read the up information messages to verify your .env file is being used:
  ```text
  ...
  Using grafana.env=default
  Using nginx.env=/home/fred/nginx.env (custom)
  Using web.env=default
  ...
  ```

- - - -

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
