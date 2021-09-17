#!/bin/bash
do_setup(){
  NAME="$1"
  POD_UID="$(echo "$2" | head -n1)"
  POD_ANNOTATIONS="$(echo "$2" | tail -n+2)"
  if ! echo "$POD_ANNOTATIONS" | grep -q pipework; then
    return 0
  fi
  POD_CGROUP=$(find "$CGROUPMNT" -name "*$(echo "$POD_UID" | tr - _)*" -type d)
  if [ -z "$POD_CGROUP" ]; then
    echo "Could not locate CGROUP for pod with uid $POD_UID"
    return 2
  fi
  M=$(find "$POD_CGROUP" -name tasks -exec grep -H '' {} + | sort -t: -k 2,2 | head -n1)
  POD_PID="$(echo "$M" | sed 's/.*://')"
  PIPEWORK_NAME="$(basename $(dirname "$M"))"
  PIPEWORK_VARS=$(echo "$2" | grep 'pipework_cmd.*='| sed -e 's/^[^"]\+"//' -e 's/"$//' -e "s/@CONTAINER_NAME@\|@CONTAINER_ID@/${PIPEWORK_NAME}/g")

  #echo "NAME=$NAME"
  #echo "POD_UID=$POD_UID"
  #echo "POD_PID=$POD_PID"
  #echo "POD_ANNOTATIONS=$POD_ANNOTATIONS"
  #echo "PIPEWORK_NAME=$PIPEWORK_NAME"

  echo "$PIPEWORK_VARS" | while read cmd; do
    echo "executing: $cmd"
    pipework "$cmd"
  done
}

do_cleanup(){
  echo "not implemented yet"
}

# ------------------------------------------------------------------------------
# Apache 2.0 License, Credit @ jpetazzino
# https://github.com/jpetazzo/pipework/blob/master/pipework#L184-L188
while read _ mnt fstype options _; do
  [ "$fstype" != "cgroup" ] && continue
  echo "$options" | grep -qw devices || continue
  CGROUPMNT=$mnt
done < /proc/mounts
# ------------------------------------------------------------------------------

if [ -z "$CGROUPMNT" ]; then
  echo "Could not locate cgroup mount point."
  exit 1
fi
if [ -z "$NODE_NAME" ]; then
  echo "Enviroment NODE_NAME is required!"
  exit 1
fi

kubectl get pod --no-headers --all-namespaces -w --field-selector spec.nodeName="$NODE_NAME" | \
  while read NAMESPACE NAME READY STATUS RESTARTS AGE; do  
    echo "reconciling $NAME"
    if VARS=$(kubectl -n "$NAMESPACE" get pod "$NAME" -o go-template='{{ .metadata.uid }}{{ with .metadata.annotations }}{{ range $k, $v := . }}{{ "\n" }}{{ printf "%s=\"%s\"" $k $v }}{{ end }}{{ end }}' 2>/dev/null); then
      echo "  run setup"
      do_setup "$NAME" "$VARS"
    else
      echo "  run cleanup"
      do_cleanup "$NAME"
    fi
  done
