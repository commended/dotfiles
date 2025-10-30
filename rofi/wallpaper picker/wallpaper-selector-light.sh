# note: very early development i wouldnt use right now
#!/usr/bin/env bash

CONFIG=~/.config
CACHE=~/.cache

WALLS=~/Pictures/wallpapers
THUMBNAILS=$CACHE/wallpaper-selector/thumbnails
ROFI_CFG=$CONFIG/rofi/wallpaper.rasi

mkdir -p "$WALLS"
mkdir -p "$CACHE"
mkdir -p "$THUMBNAILS" 

for WALL in $WALLS/*; do
    BASENAME=$(basename $WALL)
    THUMBNAIL=$THUMBNAILS/$BASENAME
    if [ ! -f $THUMBNAIL ]; then
        magick convert \
            -strip $WALL \
            -thumbnail x540^ \
            -gravity center \
            -extent 330x500 \
            $THUMBNAIL
    fi
done

WALLPAPER=$(
    for WALL in $WALLS/*; do
        printf "$WALL\0icon\x1f$THUMBNAILS/$(basename $WALL)\n"
    done | rofi -dmenu -config $ROFI_CFG
)

if [ ! -z "$WALLPAPER" ]; then
  
    swww img "$WALLPAPER" \
        --transition-type grow \
        --transition-duration 2 \
        --transition-fps 60

    sleep 0.5
    wal -l -i "$WALLPAPER" -q  
    pkill -SIGUSR2 waybar &
fi%  
