#!/usr/bin/env bash
set -e

if [ -f /etc/default/goshimmer ]
then
    source /etc/default/goshimmer
elif [ -f /etc/sysconfig/goshimmer ]
then
    source /etc/sysconfig/goshimmer
else
    echo "Didn't find goshimmer playbook config" >&2
    exit 1
fi

SHIMMER_UID=$(id shimmer|sed 's/^uid=\([0-9]*\).*$/\1/')

echo "Making sure systemd goshimmer stopped ..." >&2
systemctl stop goshimmer

if docker ps -a | grep -q goshimmer
then
    docker rm -f goshimmer
fi

docker run --rm -it --name goshimmer --net=host --user=${SHIMMER_UID} --cap-drop=ALL -v /etc/localtime:/etc/localtime:ro,Z -v /var/lib/goshimmer/mainnetdb:/app/mainnetdb:rw,Z ${SHIMMER_IMAGE}:${TAG} -autopeering-entry-nodes $(echo "$OPTIONS" | awk -F"'" {'print $2'})