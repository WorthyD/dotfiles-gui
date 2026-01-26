#!/bin/bash

# Check if the variable is passed
if [ -z "$1" ]; then
    SUDO_VAR=""
else
    SUDO_VAR=$1
fi

# Extract the value of the NAME field from /etc/os-release
OS_NAME=$(grep "^NAME=" /etc/os-release | cut -d "=" -f 2- | tr -d '"')
if [ "$OS_NAME" != "Linux Mint" ] && [ "$XDG_CURRENT_DESKTOP" != "cinnamon" ]; then
    echo "This script only works in Linux Mint Cinnamon systems"
    exit 1
fi

DIR=$PWD

# Remove unused startup applications
if [ "$SUDO_VAR" = "yes" ]; then
    sudo rm /etc/xdg/autostart/mintwelcome.desktop
    sudo rm /etc/xdg/autostart/mintupdate.desktop
fi


# Customize the panel
## Modify the panel's position
gsettings set org.cinnamon panels-enabled "['1:0:bottom', '2:3:bottom', '3:1:bottom', '4:2:bottom']"
gsettings set org.cinnamon panels-height "['1:40', '2:40', '3:40', '4:40']"
# https://forums.linuxmint.com/viewtopic.php?t=285940

## Install favorite applets ===================================================
cd ~/.local/share/cinnamon/applets/
#wget https://cinnamon-spices.linuxmint.com/files/applets/CinnVIIStarkMenu@NikoKrause.zip && unzip CinnVIIStarkMenu@NikoKrause.zip && rm CinnVIIStarkMenu@NikoKrause.zip
wget https://cinnamon-spices.linuxmint.com/files/applets/weather@mockturtl.zip && unzip weather@mockturtl.zip && rm weather@mockturtl.zip
wget https://cinnamon-spices.linuxmint.com/files/applets/color-picker@fmete.zip && unzip color-picker@fmete.zip && rm color-picker@fmete.zip
cd $DIR

## Set applets layout
APPLETS="[\
'panel1:left:0:menu@cinnamon.org', \
'panel1:left:1:separator@cinnamon.org',\
'panel1:left:2:grouped-window-list@cinnamon.org',\
'panel1:right:0:workspace-switcher@cinnamon.org', \
'panel1:right:1:network@cinnamon.org', \
'panel1:right:2:sound@cinnamon.org', \
'panel1:right:3:color-picker@fmete', \
'panel1:right:4:xapp-status@cinnamon.org', \
'panel1:right:5:sound@cinnamon.org', \
'panel1:right:6:notifications@cinnamon.org', \
'panel1:right:7:weather@mockturtl',\
'panel1:right:99:calendar@cinnamon.org', \
'panel2:left:0:grouped-window-list@cinnamon.org', \
'panel3:left:0:grouped-window-list@cinnamon.org', \
 'panel4:left:0:grouped-window-list@cinnamon.org' \
"
if [ -d "/sys/class/power_supply" ]; then
    # This is a laptop. Include battery applet
    # 'panel1:right:XX:power@cinnamon.org:XX'
    APPLETS="$APPLETS, 'panel1:right:98:power@cinnamon.org'"
fi
APPLETS="$APPLETS]"

## Enabled applets: 'panel_name:left|center|right:position:applet_name<: optional id>'
gsettings set org.cinnamon enabled-applets "$APPLETS"

FAVORITES="[\
 'google-chrome.desktop', \
 'steam.desktop', 'discord.desktop', \
 'mintinstall.desktop', \
 'cinnamon-settings.desktop', \
 'org.gnome.Terminal.desktop', \
 'nemo.desktop']"

gsettings set org.cinnamon favorite-apps "$FAVORITES"

## Change applets settings
sleep 2
### calendar
sed -i '/use-custom-format/,/custom-format/ s/value": false/value": true/' ~/.config/cinnamon/spices/calendar@cinnamon.org/*.json
# This sed command recursively replaces the date/time format string in Cinnamon calendar 
# widget configuration files. It changes the timestamp format from "%A, %B %e, %H:%M" 
# (full weekday name, full month name, day, 24-hour time) to "%b %e, %I:%M %p" 
# (abbreviated month name, day, 12-hour time with AM/PM). The -i flag performs 
# in-place editing on all JSON configuration files in the Cinnamon calendar spice directory.
sed -i 's/value": "%A, %B %e, %H:%M/value": "%b %e, %I:%M %p/g' ~/.config/cinnamon/spices/calendar@cinnamon.org/*.json
gsettings set org.cinnamon.desktop.interface clock-use-24h false

#PINNED= "['nemo.desktop','org.gnome.Terminal.desktop','google-chrome.desktop', 'code.desktop','discord.desktop', 'steam.desktop']"
#sed -i "/pinned-apps/ s|value\": \"\\['nemo.desktop','org.gnome.Terminal.desktop','google-chrome.desktop', 'code.desktop','discord.desktop', 'steam.desktop'\\]\"|value\": \"['nemo.desktop','org.gnome.Terminal.desktop','google-chrome.desktop', 'code.desktop','discord.desktop', 'steam.desktop']\"|g" ~/.config/cinnamon/spices/grouped-window-list@cinnamon.org/*.json
# Updates the pinned applications in Cinnamon's grouped-window-list spice configuration.
# Replaces the "value" array for "pinned-apps" with a predefined list of desktop applications
# (Nemo, GNOME Terminal, Google Chrome, VS Code, Discord, and Steam).
# Modifies all JSON configuration files in the grouped-window-list spice directory.
#sed -i '/pinned-apps/ s/"value": \[.*\]/"value": ["nemo.desktop","org.gnome.Terminal.desktop","google-chrome.desktop", "code.desktop","discord.desktop", "steam.desktop"]/' ~/.config/cinnamon/spices/grouped-window-list@cinnamon.org/*.json
#sed -i '/pinned-apps/ s/"value": "*"/"value": "blah/' ~/.config/cinnamon/spices/grouped-window-list@cinnamon.org/*.json
sed -i '/"value": \[/,/\]/{s/"nemo\.desktop",//; s/"firefox\.desktop",//; s/"org\.gnome\.Terminal\.desktop"//; /^\s*\]/i "nemo.desktop","org.gnome.Terminal.desktop","google-chrome.desktop", "code.desktop","discord.desktop", "steam.desktop"
}' /home/worthyd/.config/cinnamon/spices/grouped-window-list@cinnamon.org/*.json

#sed -i 's/"value": \[.*\]/"value": ["neo.desktop", "firefox.desktop", "org.gnome.Terminal.desktop"]/g' /home/worthyd/.config/cinnamon/spices/grouped-window-list@cinnamon.org/292.json


### workspace-switcher
sed -i 's/value": "visual/value": "buttons/g' ~/.config/cinnamon/spices/workspace-switcher@cinnamon.org/*.json
### CinnVIIStarkMenu
#sed -i 's/value": "stark/value": "mate/g' ~/.config/cinnamon/spices/CinnVIIStarkMenu@NikoKrause/*.json

# Install favorite extensions =================================================
cd ~/.local/share/cinnamon/extensions/

wget https://cinnamon-spices.linuxmint.com/files/extensions/transparent-panels@germanfr.zip && unzip transparent-panels@germanfr.zip && rm transparent-panels@germanfr.zip
wget https://cinnamon-spices.linuxmint.com/files/extensions/gTile@shuairan.zip && unzip gTile@shuairan.zip && rm gTile@shuairan.zip
## Enabled extensions
gsettings set org.cinnamon enabled-extensions "['transparent-panels@germanfr', 'gTile@shuairan']"
cd $DIR


# Wallpaper
## Copy resources
IMGDIR=~/Images/

cp -r wallpapers $IMGDIR

gsettings set org.cinnamon.desktop.background picture-uri "file:///$IMGDIR/wallpapers/arcade.png"

# Set keyboard shortcuts for workspace switching
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-left "['<Alt>1']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-right "['<Alt>2']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-up "['<Super><Tab>', '<Alt>F1']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-down "['<Super><Shift><Tab>', '<Alt>F2']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-1 "['<Super>1']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-2 "['<Super>2']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-3 "['<Super>3']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-4 "['<Super>4']"

gsettings set org.cinnamon.desktop.keybindings.media-keys screensaver "['<Super>l', 'XF86ScreenSaver']"

# todo Find lock screen command and set Super+L shortcut

#gsettings set org.cinnamon.desktop.wm.preferences button-layout 'close,maximize,minimize:'
#gsettings set org.cinnamon.desktop.wm.preferences button-layout ':minimize,maximize,close'
