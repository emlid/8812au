#!/bin/bash

if [[ "$(mokutil --sb-state)" == *enabled ]]; then

    if [ ! -d ".ssl" ]; then
        mkdir .ssl
    fi

    cd .ssl

    if [[ ! -f "MOK.der" || ! -f "MOK.priv" || "$(mokutil --test-key MOK.der)" == *"not enrolled" ]]; then

        echo -e "\n Creating X.509 key pair"
        openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=local_rtl8812au/"

        # Add key to trusted list
        echo -e "\n\t ATTENTION"
        echo -e " MOK manager ask you to enter input password."
        echo " This password will be needed once after first reboot."
        
        sudo mokutil --import ./MOK.der

        echo ""
        echo " System requires reboot."
        echo " UEFI key manager will appear during the boot."
        echo " Select 'Enroll MOK' and 'Continue. Then enter input password."
    fi

    SIGN=/usr/src/linux-headers-$(uname -r)/scripts/sign-file
    MODULE=$(modinfo -n 8812au)

    echo -e "\n Signing the following module"
    echo " $MODULE"

    sudo $SIGN sha256 ./MOK.priv ./MOK.der $MODULE
    
fi
