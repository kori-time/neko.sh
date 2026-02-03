#!/usr/bin/env bash
set -u

LOOPS="${LOOPS:-0}"            # 0 = infinite
SPEED="${SPEED:-0.20}"
LINE_SPEED="${LINE_SPEED:-0}"
BEEP_CHAR="${BEEP_CHAR:-█}"
WAVE_MAX="${WAVE_MAX:-32}"
EMOTE_COLS="${EMOTE_COLS:-18}"

sleep_s() { sleep "$1" 2>/dev/null || true; }
clear_screen() { printf '\033[2J\033[H'; }
dim() { printf '\033[2m%s\033[0m' "$*"; }
hdr() { printf '\033[1;35m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;31m%s\033[0m\n' "$*"; }
info() { printf '\033[1;36m%s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

get_os() { printf 'NEKO OS 24.04'; }

get_cpu_model() {
  if have lscpu; then
    lscpu 2>/dev/null | awk -F: '/Model name/ {gsub(/^[ \t]+/,"",$2); print $2; exit}'
  elif [[ -r /proc/cpuinfo ]]; then
    awk -F: '/model name/ {gsub(/^[ \t]+/,"",$2); print $2; exit}' /proc/cpuinfo
  else
    uname -p 2>/dev/null || printf 'unknown'
  fi
}

get_cpu_load() {
  if have uptime; then
    uptime 2>/dev/null | sed -n 's/.*load average[s]*: //p'
  elif [[ -r /proc/loadavg ]]; then
    awk '{print $1", "$2", "$3}' /proc/loadavg
  else
    printf 'unknown'
  fi
}

get_uptime() {
  if have uptime; then
    uptime -p 2>/dev/null | sed 's/^up //'
  elif [[ -r /proc/uptime ]]; then
    awk '{printf "%.0fs\n",$1}' /proc/uptime
  else
    printf 'unknown'
  fi
}

get_mem_line() {
  if have free; then
    free -h 2>/dev/null | awk 'NR==2 {printf "USED %s / TOT %s (FREE %s)", $3, $2, $4}'
  elif [[ -r /proc/meminfo ]]; then
    awk '
      /MemTotal/ {t=$2}
      /MemAvailable/ {a=$2}
      END {
        used=t-a
        printf "USED %.0fMiB / TOT %.0fMiB (AVAIL %.0fMiB)", used/1024, t/1024, a/1024
      }' /proc/meminfo
  else
    printf 'unknown'
  fi
}

get_gpu() {
  if have lspci; then
    lspci 2>/dev/null | awk -F': ' '/VGA|3D controller/ {print $2; exit}'
  else
    printf 'unknown'
  fi
}

get_disk() {
  if have df; then
    df -h / 2>/dev/null | awk 'NR==2 {printf "%s USED / %s TOT (%s AVAIL)", $3, $2, $4}'
  else
    printf 'unknown'
  fi
}

get_net() {
  if have ip; then
    ip -o -4 addr show 2>/dev/null | awk '{print $2": "$4}' | head -n 3 | paste -sd ' | ' -
  else
    printf 'unknown'
  fi
}

get_top_procs() {
  if have ps; then
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu 2>/dev/null | head -n 6
  else
    printf "PID  CMD  CPU  MEM\n(unknown)\n"
  fi
}

bios_beep_waves() {
  info "🔊 BIOS BEEP WAVES 🔊"
  local i w
  for i in 1 2 3 4 5 6 7 8; do
    w=$(( (RANDOM % WAVE_MAX) + 4 ))
    printf 'BEEP  : %s\n' "$(printf "%0.s$BEEP_CHAR" $(seq 1 "$w"))"
  done
  printf 'BEEEEEP: %s\n' "$(printf "%0.s$BEEP_CHAR" $(seq 1 "$WAVE_MAX"))"
}

crt_glitch_block() {
  hdr "===== FAKE CRT GLITCH PANIC ====="
  printf '|||||||||||||||||||||||||||||||||||||||||||||\n'
  printf '||||  SYNC WOST  ||||  SYNC WOST  ||||  SYNC  ||\n'
  printf '||  NO SIGNAW  ||||||  NO SIGNAW  ||||||  NO  ||\n'
  printf '|||||||||||||||||||||||||||||||||||||||||||||\n'
  printf '>>>> SCANWINE JITTEW <<<<\n'
  printf '>>>> HISS <<<<\n'
  printf '>>>> SCWEECH <<<<\n'
  printf '>>>> BEEEEP <<<<\n'
  printf '|||||||||||||||||||||||||||||||||||||||||||||\n'
}

emote_wall() {
  hdr "=== PUWE EMOTE WAWW ==="
  printf '%s\n' "$(printf '😾%.0s' $(seq 1 "$EMOTE_COLS"))"
  printf '%s\n' "$(printf '💢%.0s' $(seq 1 "$EMOTE_COLS"))"
  printf '%s\n' "$(printf '🔥%.0s' $(seq 1 "$EMOTE_COLS"))"
  printf '%s\n' "$(printf '🚨%.0s' $(seq 1 "$EMOTE_COLS"))"
  printf '%s\n' "$(printf '💥%.0s' $(seq 1 "$EMOTE_COLS"))"
  printf '%s\n' "$(printf '🐾%.0s' $(seq 1 "$EMOTE_COLS"))"
  printf '%s\n' "$(printf '😈%.0s' $(seq 1 "$EMOTE_COLS"))"
  printf '%s\n' "$(printf '☠️%.0s' $(seq 1 "$EMOTE_COLS"))"
  printf '%s\n' "$(printf '⚠️%.0s' $(seq 1 "$EMOTE_COLS"))"
  printf '%s\n' "$(printf '😭%.0s' $(seq 1 "$EMOTE_COLS"))"
}

spam_scroll() {
  warn ">>>> FASTA SCWOWW NO PAUSE <<<<"
  local lines=(
    "NYANYANYANYANYANYA!!!💢🔥😾💥🐾🚨☠️"
    "SMASHSMASHSMASH!!!💥💥💥💥💥"
    "HISSHISSHISS!!!😾😾😾😾😾"
    "BEEPBEEPBEEEEEP!!!🔊🔊🔊🔊🔊"
    "PANICPANICPANIC!!!🚨🚨🚨🚨🚨"
    "KEYBOAWDSATON!!!🐾🐾🐾🐾🐾"
    "CUPDOWNCUPDOWN!!!🍶❌🍶❌🍶❌"
    "NEKO OS 24.04 IS ANGY!!! 💢"
    "GWINWIN MODE: ACTIVE 😈😈😈"
    "ACCESS: NYEVEW 🔥"
  )
  local l
  for l in "${lines[@]}"; do
    printf '%s\n' "$l"
    [[ "$LINE_SPEED" != "0" ]] && sleep_s "$LINE_SPEED"
  done
}

countdown() {
  info ">>> COUNTDOWN TO TOTAWW COWWAPSE <<<"
  local t
  for t in 10 9 8 7 6 5 4 3 2 1; do
    printf 'T-MINUS %02d... 😈💥😾💢🔥🐾🚨\n' "$t"
    sleep_s 0.08
  done
  warn "================== TOTAWW COWWAPSE =================="
  warn "!!! SYSTEM PANIC !!!"
  warn "!!! SYSTEM PANIC !!!"
  warn "!!! SYSTEM PANIC !!!"
  printf 'FINAL BIOS MESSAGE: BEEEEEEEEEEEEEEEEEEEEEP\n'
  printf 'SYSTEM HAWTED. NEKO WINS. GWINWIN SITS ON KEYBOAWD. 🐾\n'
}

system_panel() {
  hdr "===== SYSTEM DIAGNOSTICS ====="
  printf 'OS  : %s\n' "$(get_os)"
  printf 'CPU : %s\n' "$(get_cpu_model)"
  printf 'GPU : %s\n' "$(get_gpu)"
  printf 'WAM : %s\n' "$(get_mem_line)"
  printf 'UP  : %s\n' "$(get_uptime)"
  printf 'LOAD: %s\n' "$(get_cpu_load)"
  printf 'DISK: %s\n' "$(get_disk)"
  printf 'NET : %s\n' "$(get_net)"
  printf '\n'
  hdr "===== TOP PWOCESSES (CPU) ====="
  get_top_procs
}

panic_frame() {
  clear_screen
  warn "!!!!!!!!!!!!!!!! NEKO SYSTEM PANIC LOOP !!!!!!!!!!!!!!!!"
  printf 'NEKO AWEWT! GWINWIN ACTIVITY DETECTED! KEYBOAWD IS NYOT SAFE!\n'
  printf 'OS: NEKO OS 24.04 | MODE: PANIC | FEELINGS: OVWFWOW 😾💢🔥\n\n'

  system_panel
  printf '\n'
  crt_glitch_block
  printf '\n'
  bios_beep_waves
  printf '\n'
  emote_wall
  printf '\n'
  spam_scroll
  printf '\n'
  countdown

  printf '\n'
  dim "[ PWESS CTRL+C TO ESCAPE... IF YOU DARE ]"
  printf '\n'
}

i=0
while :; do
  i=$((i+1))
  panic_frame

  if [[ "$LOOPS" -ne 0 && "$i" -ge "$LOOPS" ]]; then
    break
  fi

  sleep_s "$SPEED"
done
