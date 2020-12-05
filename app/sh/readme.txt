
This dir holds scripts that are cat'ed out of the commander
container and saved to /tmp on the HOST and then, run from
the HOST, and not from inside the container.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
This is needed for start-point-create.sh, the script handling

 $ ./cyber-dojo start-point create <NAME>
      --custom|--exercises|--languages \
        <url>...

to ensure <url>s are always accessible to the git-clone
commands the script performs. If you're running Docker-Toolbox only
urls volume-mounted to the default VM under /Users/<user>
are accessible in the default VM.
