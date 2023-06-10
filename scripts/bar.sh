#!/bin/bash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors!
. ~/.dwm/bar/themes/tokyonight

cpu() {
	cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

	printf "^c$black^ ^b$green^  "
	printf "^c$white^ ^b$grey^ $cpu_val"
}

pkg_updates() {
	# updates=$(doas xbps-install -un | wc -l) # void
	updates=$(checkupdates | wc -l)   # arch , needs pacman contrib
	# updates=$(aptitude search '~U' | wc -l)  # apt (ubuntu,debian etc)

	if [ -z "$updates" ]; then
		printf "^c$green^  Fully Updated"
	else
		printf "^c$green^  $updates"" updates"
	fi
}

battery() {
	get_capacity="$(cat /sys/class/power_supply/BAT1/capacity)"
	printf "^c$blue^   $get_capacity"
}

brightness() {
	printf "^c$red^   "
	printf "^c$red^%.0f\n" $(cat /sys/class/backlight/*/brightness)
}

mem() {
	printf "^c$red^^b$black^  "
	printf "^c$white^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
	case "$(cat /sys/class/net/w*/operstate 2>/dev/null)" in
	up) printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^Connected" ;;
	down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^Disconnected" ;;
	esac
}

clock() {
	printf "^c$black^ ^b$darkblue^ 󱑆  "
	# printf "^c$black^^b$blue^ $(date '+%I:%M %p') "
	printf "^c$black^^b$blue^ $(date '+%d/%m/%Y %H:%M') "
}

dwm_keyboard () {
        printf "^c$blue^^b$black^   ⌨ "
        printf "^c$white^$(setxkbmap -query | awk '/layout/{print $2}')"
}

dwm_audio () {
  STATUS=$(amixer sget Master | tail -n1 | sed -r "s/.*\[(.*)\]/\1/")
  VOL=$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")
  if [ "$STATUS" = "off" ]; then
    printf " 󰖁 "
  else
    #removed this line becuase it may get confusing
    if [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
      printf "^c$green^^b$black^ %s%%" "^c$white^^b$black^$VOL"
    elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
      printf "^c$green^^b$black^󰖀 %s%%" "^c$white^^b$black^$VOL"
    else
      printf "^c$green^^b$black^󰕾 %s%%" "^c$white^^b$black^$VOL"
    fi
  fi
}

while true; do

	# [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
	# interval=$((interval + 1))
        sleep 1 && xsetroot -name "$(dwm_keyboard) $(dwm_audio) $(mem) $(cpu) $(clock)"
done
