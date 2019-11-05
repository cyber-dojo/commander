
[![CircleCI](https://circleci.com/gh/cyber-dojo/commander.svg?style=svg)](https://circleci.com/gh/cyber-dojo/commander)

# cyber-dojo

Assuming you have followed [these setup instructions](https://blog.cyber-dojo.org/2014/09/setting-up-your-own-cyber-dojo-server.html) you use the main cyber-dojo bash script to control a [cyber-dojo](https://cyber-dojo.org) server.

#
- [bring up a default server](#bring-up-a-default-server)
- [update the server to the latest version](#update-the-server-to-the-latest-version)
- [update the server to a specific version](#update-the-server-to-a-specific-version )
- [overriding the default port](#overriding-the-default-port)
- [overriding the default start-point images](#overriding-the-default-start-point-images)
- [overriding the default rails web service image](#overriding-the-default-rails-web-service-image)
- [overriding the default dot env files](#overriding-the-default-dot-env-files)

# bring up a default server
```bash
$ cyber-dojo up
...
$ cyber-dojo version
Version: 1.0.19
   Type: public
...
```

# update the server to the latest version
```bash
$ cyber-dojo update latest
$ cyber-dojo version
Version: 1.0.23
   Type: public
...
# Now make it live...
$ cyber-dojo up
Using version=1.0.23 (public)
...
```

# update the server to a specific version
```bash
$ cyber-dojo update 1.0.21
$ cyber-dojo version
Version: 1.0.21
   Type: public
...
# Now make it live...
$ cyber-dojo up
Using version=1.0.21 (public)
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
  or
  ```bash
  $ CYBER_DOJO_PORT=81 cyber-dojo up
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

# overriding the default rails web service image
By default your cyber-dojo server will use [cyberdojo/web](https://hub.docker.com/r/cyberdojo/web/tags) as its web service image (tagged appropriately).
You can override this using environment variables to specify the image name and its tag:
  ```bash
  $ export CYBER_DOJO_WEB_IMAGE=turtlesec/web
  $ export CYBER_DOJO_WEB_TAG=84d6d0e
  $ cyber-dojo up ...
  Using avatars=cyberdojo/avatars:47dd256
  Using differ=cyberdojo/differ:610f484
  Using nginx=cyberdojo/nginx:02183dc
  Using ragger=cyberdojo/runner:f03228c
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
There are default .env files for two of the core-services:
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

- - - -

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
