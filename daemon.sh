#!/bin/bash
basedir="$(dirname "$0")"
source "${basedir}/env.sh"

# Alias ssh commands.
declare -a ssh_master
declare -a ssh_slave
ssh_master=(ssh "${ssh_host}" -M -oControlPath="${ssh_ctrl_sock}")
ssh_slave=(ssh "${ssh_host}" -S "${ssh_ctrl_sock}")

# Ports being forwarded (as a state).
declare -A ports

# Optional logging utility.
function log() {
  if [[ -n "${LOGGING}" ]]; then
    echo "$@" >&2
  fi
}

# Retry-on-failure loop.
while true; do
  # Create the control master.
  rm -f "${ssh_ctrl_sock}"
  "${ssh_master[@]}" -fN "${ssh_args[@]}"

  # Close the control master on exit.
  trap '"${ssh_slave[@]}" -O exit' EXIT

  declare -a lines
  ports=()
  # Daemon loop. Read currently listened ports from remote.
  while lines=($("${ssh_slave[@]}" -- python3 - "${local_port}" "${remote_port}" <"${basedir}/show-ports.py")); do
    # Forward newly listned ports.
    unset new_ports
    declare -A new_ports
    for line in "${lines[@]}"; do
      new_ports[$line]=1
      if ! [[ ${ports[$line]} ]]; then
        log add "${line}"
        ports[$line]=1
        "${ssh_slave[@]}" -O forward -L "${line}"
      fi
    done

    # Remove ports that are previously listened but now disappeared.
    for port in "${!ports[@]}"; do
      if ! [[ ${new_ports[$port]} ]]; then
        log rm "${port}"
        unset ports[$port]
        "${ssh_slave[@]}" -O cancel -L "${port}"
      fi
    done

    sleep 1
  done
  sleep 3
done
