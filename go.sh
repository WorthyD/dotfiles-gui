#!/bin/bash

echo "Installing packages in the system requires sudo permission."
read -rp "Do you want to install packages?: (Y/n): " user_response
if [ "$user_response" = "y" ] || [ "$user_response" = "Y" ] || [ "$user_response" = "" ]; then
    SUDO_VAR="yes"
    # Install requirements and basic apps
    sudo apt update
    sudo apt install -y software-properties-common apt-transport-https curl wget ca-certificates
    sudo apt install -y neofetch

    echo "Do you want to install optional apps?"
    read -rp "(including vim, vscode, tmux, MS edge, etc.): (Y/n): " optional_apps
    if [ "$optional_apps" = "y" ] || [ "$optional_apps" = "Y" ] || [ "$optional_apps" = "" ]; then
        # Install optional software
        bash install_apps.sh $SUDO_VAR
    fi
else
    SUDO_VAR="no"
fi

# Modify desktop appearance and panel
#bash desktop_setup.sh $SUDO_VAR
# Install and configure Conky
bash conky_setup.sh $SUDO_VAR
# Modify general appearance
#bash theme_setup.sh $SUDO_VAR

# Need to log-out
display_banner() {
    echo "*************************************************"
    echo "*                                               *"
    echo "*           Customization completed             *"
    echo "*                                               *"
    echo "*          IT IS NECESSARY TO LOG OUT           *"
    echo "*                                               *"
    echo "*     The current repository can be deleted     *"
    echo "*                                               *"
    echo "*************************************************"
}

# Call the function to display the banner
display_banner

