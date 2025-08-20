#!/bin/sh

# --- Pick a random wallpaper ---
wall=$(find ~/scp/pywallpaper/ -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)

# --- Set wallpaper ---
xwallpaper --zoom "$wall"

# --- Clear previous Pywal colors and generate new palette ---
wal -c
wal -i "$wall"

# Optional UI refresh
xdotool key super+F5

# --- Ensure directories exist ---
mkdir -p ~/.config/dunst
mkdir -p ~/.config/cava

# --- Extract Pywal colors ---
background=$(jq -r '.special.background' ~/.cache/wal/colors.json)
foreground=$(jq -r '.special.foreground' ~/.cache/wal/colors.json)
frame_color=$(jq -r '.colors.color1' ~/.cache/wal/colors.json)

gradient_color_1=$(jq -r '.colors.color0' ~/.cache/wal/colors.json)
gradient_color_2=$(jq -r '.colors.color1' ~/.cache/wal/colors.json)
gradient_color_3=$(jq -r '.colors.color2' ~/.cache/wal/colors.json)
gradient_color_4=$(jq -r '.colors.color3' ~/.cache/wal/colors.json)
gradient_color_5=$(jq -r '.colors.color4' ~/.cache/wal/colors.json)
gradient_color_6=$(jq -r '.colors.color5' ~/.cache/wal/colors.json)
gradient_color_7=$(jq -r '.colors.color6' ~/.cache/wal/colors.json)
gradient_color_8=$(jq -r '.colors.color7' ~/.cache/wal/colors.json)

# --- Ensure all colors start with # ---
for var in background foreground frame_color \
           gradient_color_1 gradient_color_2 gradient_color_3 gradient_color_4 \
           gradient_color_5 gradient_color_6 gradient_color_7 gradient_color_8; do
    val=$(eval echo \$$var)
    case "$val" in
        \#*) ;;                 # already has #
        *) val="#$val" ;;
    esac
    eval "$var=$val"
done

# --- Write Cava config safely ---
cat <<EOF > ~/.config/cava/config
[color]
background = '$background'
foreground = '$foreground'
gradient = 1
gradient_count = 8
gradient_color_1 = '$gradient_color_1'
gradient_color_2 = '$gradient_color_2'
gradient_color_3 = '$gradient_color_3'
gradient_color_4 = '$gradient_color_4'
gradient_color_5 = '$gradient_color_5'
gradient_color_6 = '$gradient_color_6'
gradient_color_7 = '$gradient_color_7'
gradient_color_8 = '$gradient_color_8'
EOF

# --- Write Dunst config ---
cat <<EOF > ~/.config/dunst/dunstrc
[global]
    font = Monospace 10
    timeout = 10
    origin = top-right
    padding = 9
    frame_width = 4
    separator_height = 2
    background = "$background"
    foreground = "$foreground"
    frame_color = "$frame_color"

[urgency_low]
    background = "#444444"
    foreground = "#bbbbbb"
    frame_color = "#444444"

[urgency_normal]
    background = "$background"
    foreground = "$foreground"
    frame_color = "$frame_color"

[urgency_critical]
    background = "#ff0000"
    foreground = "#ffffff"
    frame_color = "#ff0000"
EOF

# --- Restart services safely ---
pkill dunst && dunst &
pkill cava
sleep 0.2
cava &

echo "Wallpaper, Pywal, Dunst, and Cava updated safely"
