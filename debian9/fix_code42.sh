#!/bin/bash

#Author: Dante Basso
#Github: https://github.com/dcbasso

stopService() {
    echo "stoping service..."
   "$serviceFolder"/service.sh stop
}

startService() {
    echo "starting service..."
    "$serviceFolder"/service.sh start
}

fixLibIssue() {
    echo "Fixing lib issue..."
    cd "$crashplanNlibInstallFolder" || exit
    cp "$libFilename" .
    chmod 744 *
    if [ -f "$crashplanNlibInstallFolder/$libFilename" ]; then
        echo "Lib fixed with sucess..."
    else 
        echo "Could not fix lib issue, please check the process..."
    fi
}

downloadAndProcessFile() {
    echo "Validating Download..."

    if [ -f "$crashPlanFile" ]; 
    then
        echo "Download not necessary..."
    else
        echo "Downloading Crashplan/code42 tar.gz..."
        curl "$crashPlanUrlDownload" -o "$crashPlanFile"
    fi
    if [ ! -d "$tgzCodeInstall" ]; 
    then
        echo "Unpaking..."
        $(tar -xf $crashPlanFile $tgzCpiFile)
        $(gzip -dc "$tgzCpiFile" | cpio -i)
        shopt -s extglob
        $(rm -rf !("$cpiFile"|"nlib"|"fix_code42.sh"))
        libFilename="$(pwd)/nlib/$libUbuntuFolder/$libUbuntuFolder/libuaw.so"
        echo "Unpaking finished..."
    fi
}

process() {
    echo "starting fix process..."
    downloadAndProcessFile
    stopService
    fixLibIssue
    startService
    echo "fix process ended..."
}

# currentFolder=$(pwd)
crashPlanUrlDownload="https://download.code42.com/installs/agent/cloud/10.0.0/303/install/CrashPlanSmb_10.0.0_15252000061000_303_Linux.tgz"
crashPlanFile="crashplan.tgz"
tgzCodeInstall="code42-install/"
cpiFile="CrashPlanSmb_10.0.0.cpi"
tgzCpiFile="$tgzCodeInstall$cpiFile"
libUbuntuFolder="ubuntu18"
crashplanInstallFolder="/usr/local/crashplan/"
crashplanNlibInstallFolder="$crashplanInstallFolder/nlib"
serviceFolder="$crashplanInstallFolder/bin/"

process