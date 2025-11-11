case "$1" in
brightness-up)
  brightnessctl set +5%
  brightness=$(brightnessctl get)
  max=$(brightnessctl max)
  percent=$((brightness * 100 / max))
  notify-send -h string:x-canonical-private-synchronous:brightness \
    "Brightness" "$percent%"
  ;;
brightness-down)
  brightnessctl set 5%-
  brightness=$(brightnessctl get)
  max=$(brightnessctl max)
  percent=$((brightness * 100 / max))
  notify-send -h string:x-canonical-private-synchronous:brightness \
    "Brightness" "$percent%"
  ;;
volume-up)
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
  volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
  notify-send -h string:x-canonical-private-synchronous:volume \
    "Volume" "$volume%"
  ;;
volume-down)
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
  volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
  notify-send -h string:x-canonical-private-synchronous:volume \
    "Volume" "$volume%"
  ;;
volume-mute)
  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
  muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o 'MUTED')
  if [ -n "$muted" ]; then
    notify-send -h string:x-canonical-private-synchronous:volume \
      "Volume" "Muted"
  else
    volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
    notify-send -h string:x-canonical-private-synchronous:volume \
      "Volume" "$volume%"
  fi
  ;;
*)
  echo "Usage: $0 {brightness-up|brightness-down|volume-up|volume-down|volume-mute}"
  exit 1
  ;;
esac
