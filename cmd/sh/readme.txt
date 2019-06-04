
This dir holds scripts that are cat'ed out of the commander
container and saved to /tmp on the HOST and then run from
the HOST.
This is important for start-point-create.sh, the script handling

 $ ./cyber-dojo start-point create -
      --custom|--exercises|--languages \
        <git-repo-url>...

to ensure <git-repo-url>s are always accessible to the git-clone
commands it performs. If you're running Docker-Toolbox then only
git-repo-urls volume-mounted into the default VM under /Users/<user>
are accessible in the default VM.
