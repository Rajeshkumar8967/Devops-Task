#!/usr/bin/env bash
# System Health Monitoring Script
# Checks CPU, memory, disk and process count; logs an alert when a threshold is exceeded.
# Usage: ./system_health.sh            (run once)
#        INTERVAL=60 ./system_health.sh (loop every 60s)

CPU_THRESHOLD="${CPU_THRESHOLD:-80}"
MEM_THRESHOLD="${MEM_THRESHOLD:-80}"
DISK_THRESHOLD="${DISK_THRESHOLD:-80}"
PROC_THRESHOLD="${PROC_THRESHOLD:-300}"
LOG_FILE="${LOG_FILE:-./system_health.log}"
INTERVAL="${INTERVAL:-0}"

alert() {
  local msg
  msg="$(date '+%Y-%m-%d %H:%M:%S') ALERT: $1"
  echo "$msg" | tee -a "$LOG_FILE"
}

cpu_usage() {
  # Sample /proc/stat twice, one second apart
  read -r _ u1 n1 s1 i1 w1 q1 sq1 _ < /proc/stat
  sleep 1
  read -r _ u2 n2 s2 i2 w2 q2 sq2 _ < /proc/stat
  local idle=$(( (i2 + w2) - (i1 + w1) ))
  local total=$(( (u2+n2+s2+i2+w2+q2+sq2) - (u1+n1+s1+i1+w1+q1+sq1) ))
  echo $(( 100 * (total - idle) / total ))
}

check_once() {
  local cpu mem disk procs
  cpu=$(cpu_usage)
  mem=$(free | awk '/Mem:/ {printf "%d", $3/$2*100}')
  disk=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')
  procs=$(ps -e --no-headers | wc -l)

  echo "$(date '+%F %T') cpu=${cpu}% mem=${mem}% disk=${disk}% procs=${procs}" >> "$LOG_FILE"

  (( cpu   > CPU_THRESHOLD ))  && alert "CPU usage ${cpu}% exceeds ${CPU_THRESHOLD}%"
  (( mem   > MEM_THRESHOLD ))  && alert "Memory usage ${mem}% exceeds ${MEM_THRESHOLD}%"
  (( disk  > DISK_THRESHOLD )) && alert "Disk usage ${disk}% exceeds ${DISK_THRESHOLD}%"
  (( procs > PROC_THRESHOLD )) && alert "Process count ${procs} exceeds ${PROC_THRESHOLD}"

  echo "cpu=${cpu}% mem=${mem}% disk=${disk}% procs=${procs}"
}

if (( INTERVAL > 0 )); then
  while true; do check_once; sleep "$INTERVAL"; done
else
  check_once
fi
