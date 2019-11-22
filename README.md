
[![CircleCI](https://circleci.com/gh/cyber-dojo/commander.svg?style=svg)](https://circleci.com/gh/cyber-dojo/commander)

# cyber-dojo

Assuming you have followed [these setup instructions](https://blog.cyber-dojo.org/2014/09/setting-up-your-own-cyber-dojo-server.html) you use the [cyber-dojo bash script](https://github.com/cyber-dojo/commander/blob/master/cyber-dojo) to control a [cyber-dojo server](https://cyber-dojo.org).

- Bringing up a server
  * [on docker](#bringing-up-a-server-on-docker)
  * [on docker swarm](#bringing-up-a-server-on-docker-swarm)
- Versioning
  * [updating the server to the latest version](#updating-the-server-to-the-latest-version)
  * [resetting the server to a specific version](#resetting-the-server-to-a-specific-version)
  * [listing installed versions](#listing-installed-versions)
- Overriding the default...
  * [port](#overriding-the-default-port)
  * [start-point images](#overriding-the-default-start-point-images)
  * [nginx image](#overriding-the-default-nginx-image)
  * [rails web image](#overriding-the-default-rails-web-image)
  * [dot env files](#overriding-the-default-dot-env-files)
- Notes  
  * [environment variables can be set inline](#environment-variables-can-be-set-inline)

# bringing up a server on docker
```bash
$ cyber-dojo up
...
$ cyber-dojo version
Version: 0.1.19
   Type: public
...
```

# bringing up a server on docker swarm
This is currently in beta!
```bash
$ export CYBER_DOJO_SWARM=true
$ cyber-dojo up
```

# updating the server to the latest version
```bash
$ cyber-dojo update latest
$ cyber-dojo version
Version: 0.1.23
   Type: public
...
# Now make it live...
$ cyber-dojo up
Using version=0.1.23 (public)
...
```

# resetting the server to a specific version
```bash
$ cyber-dojo version
Version: 0.1.35
   Type: public
...
$ cyber-dojo update 0.1.21
$ cyber-dojo version
Version: 0.1.21
   Type: public
...
# Now make it live...
$ cyber-dojo up
Using version=0.1.21 (public)
...
```

# listing installed versions
From 0.1.50 onwards:
```bash
$ cyber-dojo version ls
0.1.49              2019-11-21 21:31:09 +0000 UTC
0.1.48              2019-11-20 12:52:04 +0000 UTC
...
0.1.21              2019-08-07 11:51:48 +0000 UTC
...
```

# overriding the default port
By default your cyber-dojo server will be on port 80.
You can override the port in two ways:
* an environment-variable
  ```bash
  $ export CYBER_DOJO_PORT=81
  $ cyber-dojo up
  ...
  Using port=81
  ...
  ```
* a command-line argument
  ```bash
  $ cyber-dojo up --port=82
  ...
  Using port=82
  ...
  ```

# overriding the default start-point images
By default your cyber-dojo server will use these start-point images (tagged appropriately)
- [cyberdojo/custom](https://hub.docker.com/r/cyberdojo/custom/tags)
- [cyberdojo/exercises](https://hub.docker.com/r/cyberdojo/exercises/tags)
- [cyberdojo/languages-common](https://hub.docker.com/r/cyberdojo/languages-common/tags)

You can override these start-point images in two ways:
* an environment-variable
  ```bash
  $ export CYBER_DOJO_CUSTOM=acme/my_custom:latest
  $ # export CYBER_DOJO_EXERCISES=...
  $ # export CYBER_DOJO_LANGUAGES=...
  $ cyber-dojo up
  ...
  Using custom=acme/my_custom:latest
  ...
  ```
* a command-line argument
  ```bash
  $ cyber-dojo up --custom=acme/my_custom:latest
  ...
  Using custom=acme/my_custom:latest
  ...
  ```

# overriding the default nginx image
* By default your cyber-dojo server will use [cyberdojo/nginx](https://hub.docker.com/r/cyberdojo/nginx/tags) as its nginx service image (tagged appropriately).
* From 0.1.47 onwards you can override this using environment variables to specify the image name and its tag:
  ```bash
  $ export CYBER_DOJO_NGINX_IMAGE=cucumber/nginx
  $ export CYBER_DOJO_NGINX_TAG=efd7e37
  $ cyber-dojo up ...
  ...
  Using nginx=cucumber/nginx:efd7e37
  ...
  ```
  ```yml
  # docker-compose.yml (used by cyber-dojo script)
  services:
    nginx:
      image: ${CYBER_DOJO_NGINX_IMAGE}:${CYBER_DOJO_NGINX_TAG}
      ...
  ```

# overriding the default rails web image
* By default your cyber-dojo server will use [cyberdojo/web](https://hub.docker.com/r/cyberdojo/web/tags) as its web service image (tagged appropriately).
* From 0.1.28 onwards you can override this using environment variables to specify the image name and its tag:
  ```bash
  $ export CYBER_DOJO_WEB_IMAGE=turtlesec/web
  $ export CYBER_DOJO_WEB_TAG=84d6d0e
  $ cyber-dojo up ...
  ...
  Using web=turtlesec/web:84d6d0e
  ...
  ```
  ```yml
  # docker-compose.yml (used by cyber-dojo script)
  services:
    web:
      image: ${CYBER_DOJO_WEB_IMAGE}:${CYBER_DOJO_WEB_TAG}
      ...
  ```  

# overriding the default dot env files
There are default .env files for two services:
- nginx.env
- web.env

You can override these .env files by creating your own .env file,
setting an environment-variable to its absolute path,
and re-issuing the up. For example:
  ```bash
  $ export CYBER_DOJO_NGINX_ENV=/home/fred/my_nginx.env
  $ cyber-dojo up
  ...
  Using nginx.env=/home/fred/my_nginx.env (custom)
  Using web.env=default
  ...
  ```

# environment variables can be set inline
Environment variables can be set directly in a bash command.
For example, instead of writing:
  ```bash
  $ export CYBER_DOJO_CUSTOM=acme/my_custom:latest
  $ export CYBER_DOJO_PORT=81
  $ cyber-dojo up
  ```
you can write:
  ```bash
  $ CYBER_DOJO_CUSTOM=acme/my_custom:latest CYBER_DOJO_PORT=81 cyber-dojo up
  ```

- - - -

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
