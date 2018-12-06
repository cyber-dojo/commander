#!/bin/sh

check_host_volume_mount_permissions()
{
  local service=$1
  local uid=$2
  local dir=$3

  # We could be on Docker-ToolBox, in which case
  # the check _must_ run on the VM and not locally.
  # So checking via a docker-run with a volume-mount.

  docker run \
    --rm \
    --user=${uid} \
    --volume /cyber-dojo/${dir}:/cyber-dojo/${dir}:rw \
    cyberdojo/${service} \
    sh -c "cd /cyber-dojo/${dir} && touch owner-probe.txt >& /dev/null"

  result=$?
  if [ "${result}" != "0" ]; then
    echo "  The ${service} service (uid=${uid}) requires ownership of /cyber-dojo/${dir}/"
    echo '  Please run this command:'
    echo "  $ sudo chown -R ${uid}:${uid} /cyber-dojo/${dir}"
    if [[ ! -z ${DOCKER_MACHINE_NAME} ]]; then
      echo '  You appear to be running Docker ToolBox.'
      echo '  If so, make sure you run this command on the VM.'
      echo '  For example:'
      echo "  $ docker-machine ssh default 'sudo chown -R ${uid}:${uid} /cyber-dojo/${dir}'"
    fi
    echo
  else
    echo "Checked that the ${service} service has ownership of /cyber-dojo/${dir}"
    docker run \
      --rm \
      --user=${uid} \
      --volume /cyber-dojo/${dir}:/cyber-dojo/${dir}:rw \
      cyberdojo/${service} \
      sh -c "cd /cyber-dojo/${dir} && rm owner-probe.txt"
  fi

}

check_host_volume_mount_permissions "saver"  "19663" "katas"
check_host_volume_mount_permissions "saver"  "19663" "groups"
check_host_volume_mount_permissions "porter" "19664" "id-map"
