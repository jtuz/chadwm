#!/bin/bash

interval=0

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

  printf "^c#3b414d^ ^b#7ec7a2^ CPU"
  printf "^c#abb2bf^ ^b#353b45^ $cpu_val"
}

update_icon() {
  printf "^c#7ec7a2^ "
}

pkg_updates() {
  # updates=$(doas xbps-install -un | wc -l) # void
  updates=$(checkupdates | wc -l)   # arch , needs pacman contrib
  # updates=$(aptitude search '~U' | wc -l)  # apt (ubuntu,debian etc)

  if [ -z "$updates" ]; then
    printf "^c#7ec7a2^ Fully Updated"
  else
    printf "^c#7ec7a2^ $updates"" updates"
  fi
}

# battery
batt() {
  printf "^c#81A1C1^  "
  printf "^c#81A1C1^ $(acpi | sed "s/,//g" | awk '{if ($3 == "Discharging"){print $4; exit} else {print $4""}}' | tr -d "\n")"
}

brightness() {

  backlight() {
    backlight="$(xbacklight -get)"
    echo -e "$backlight"
  }

  printf "^c#BF616A^   "
  printf "^c#BF616A^%.0f\n" $(backlight)
}

mem() {
  printf "^c#7797b7^^b#1e222a^  "
  printf "^c#7797b7^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
  case "$(cat /sys/class/net/w*/operstate 2>/dev/null)" in
  up) printf "^c#3b414d^ ^b#7aa2f7^ 󰤨 ^d^%s" " ^c#7aa2f7^Connected" ;;
  down) printf "^c#3b414d^ ^b#7aa2f7^ 󰤭 ^d^%s" " ^c#7aa2f7^Disconnected" ;;
  esac
}

clock() {
  printf "^c#1e222a^ ^b#668ee3^ 󱑆 "
  # printf "^c#1e222a^^b#7aa2f7^ $(date '+%a, %I:%M %p') "
  printf "^c#1e222a^^b#7aa2f7^ $(date '+%d/%m/%Y %H:%M') "
}

dwm_keyboard () {
  printf "^c#7797b7^^b#1e222a^ ⌨ "
  printf "^c#7797b7^$(setxkbmap -query | awk '/layout/{print $2}')"
}

dwm_audio () {
  STATUS=$(amixer sget Master | tail -n1 | sed -r "s/.*\[(.*)\]/\1/")
  VOL=$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")
  if [ "$STATUS" = "off" ]; then
    printf "🔇"
  else
    #removed this line becuase it may get confusing
    if [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
      printf "🔈 %s%%" "$VOL"
    elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
      printf "🔉 %s%%" "$VOL"
    else
      printf "🔊 %s%%" "$VOL"
    fi
  fi
}

while true; do

  [ $interval == 0 ] || [ $(($interval % 3600)) == 0 ]
  interval=$((interval + 1))

  sleep 1 && xsetroot -name "$(dwm_keyboard) $(dwm_audio) $(mem) $(cpu) $(clock)"
  # sleep 1 && xsetroot -name "$(update_icon) $updates $(batt) $(brightness) $(cpu) $(mem) $(wlan) $(clock)"
done
