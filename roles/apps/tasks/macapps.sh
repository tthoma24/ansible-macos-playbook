#/bin/bash
clear && rm -rf ~/macapps && mkdir ~/macapps > /dev/null && cd ~/macapps

###############################
#    Print script header      #
###############################
echo $"

 ███╗   ███╗ █████╗  ██████╗ █████╗ ██████╗ ██████╗ ███████╗
 ████╗ ████║██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔════╝
 ██╔████╔██║███████║██║     ███████║██████╔╝██████╔╝███████╗
 ██║╚██╔╝██║██╔══██║██║     ██╔══██║██╔═══╝ ██╔═══╝ ╚════██║
 ██║ ╚═╝ ██║██║  ██║╚██████╗██║  ██║██║     ██║     ███████║╔═════════╗
 ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═ .link ═╝\n"
 

###############################
#    Define worker functions  #
###############################
versionChecker() {
	local v1=$1; local v2=$2;
	while [ `echo $v1 | egrep -c [^0123456789.]` -gt 0 ]; do
		char=`echo $v1 | sed 's/.*\([^0123456789.]\).*/\1/'`; char_dec=`echo -n "$char" | od -b | head -1 | awk {'print $2'}`; v1=`echo $v1 | sed "s/$char/.$char_dec/g"`; done
	while [ `echo $v2 | egrep -c [^0123456789.]` -gt 0 ]; do
		char=`echo $v2 | sed 's/.*\([^0123456789.]\).*/\1/'`; char_dec=`echo -n "$char" | od -b | head -1 | awk {'print $2'}`; v2=`echo $v2 | sed "s/$char/.$char_dec/g"`; done
	v1=`echo $v1 | sed 's/\.\./.0/g'`; v2=`echo $v2 | sed 's/\.\./.0/g'`;
	checkVersion "$v1" "$v2"
}

checkVersion() {
	[ "$1" == "$2" ] && return 1
	v1f=`echo $1 | cut -d "." -f -1`;v1b=`echo $1 | cut -d "." -f 2-`;v2f=`echo $2 | cut -d "." -f -1`;v2b=`echo $2 | cut -d "." -f 2-`;
	if [[ "$v1f" != "$1" ]] || [[ "$v2f" != "$2" ]]; then [[ "$v1f" -gt "$v2f" ]] && return 1; [[ "$v1f" -lt "$v2f" ]] && return 0;
		[[ "$v1f" == "$1" ]] || [[ -z "$v1b" ]] && v1b=0; [[ "$v2f" == "$2" ]] || [[ -z "$v2b" ]] && v2b=0; checkVersion "$v1b" "$v2b"; return $?
	else [ "$1" -gt "$2" ] && return 1 || return 0; fi
}

appStatus() {
  if [ ! -d "/Applications/$1" ]; then echo "uninstalled"; else
    if [[ $5 == "build" ]]; then BUNDLE="CFBundleVersion"; else BUNDLE="CFBundleShortVersionString"; fi
    INSTALLED=`/usr/libexec/plistbuddy -c Print:$BUNDLE: "/Applications/$1/Contents/Info.plist"`
      if [ $4 == "dmg" ]; then COMPARETO=`/usr/libexec/plistbuddy -c Print:$BUNDLE: "/Volumes/$2/$1/Contents/Info.plist"`;
      elif [[ $4 == "zip" || $4 == "tar" ]]; then COMPARETO=`/usr/libexec/plistbuddy -c Print:$BUNDLE: "$3$1/Contents/Info.plist"`;
      elif [ $4 == "pkg" ]; then COMPARETO=1.0 ;fi
    checkVersion "$INSTALLED" "$COMPARETO"; UPDATED=$?;
    if [[ $UPDATED == 1 ]]; then echo "updated"; else echo "outdated"; fi; fi
}
installApp() {
  echo $'\360\237\214\200  - ['$2'] Downloading app...'
  if [ $1 == "dmg" ]; then curl -s -L -o "$2.dmg" $4; yes | hdiutil mount -nobrowse "$2.dmg" -mountpoint "/Volumes/$2" > /dev/null;
    if [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "outdated" && $6 != "noupdate" ]]; then ditto "/Volumes/$2/$3" "/Applications/$3"; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n'
    elif [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "uninstalled" ]]; then cp -R "/Volumes/$2/$3" /Applications; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi
    hdiutil unmount "/Volumes/$2" > /dev/null && rm "$2.dmg"
  elif [ $1 == "zip" ]; then curl -s -L -o "$2.zip" $4; unzip -qq "$2.zip";
    if [[ $(appStatus "$3" "" "$5" "zip" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "" "$5" "zip" "$7") == "outdated" && $6 != "noupdate" ]]; then ditto "$5$3" "/Applications/$3"; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "zip" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "zip" "$7") == "uninstalled" ]]; then mv "$5$3" /Applications; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi;
    rm -rf "$2.zip" && rm -rf "$5" && rm -rf "$3"
  elif [ $1 == "tar" ]; then curl -s -L -o "$2.tar.bz2" $4; tar -zxf "$2.tar.bz2" > /dev/null;
    if [[ $(appStatus "$3" "" "$5" "tar" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "" "$5" "tar" "$7") == "outdated" && $6 != "noupdate" ]]; then ditto "$3" "/Applications/$3"; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n';
    elif [[ $(appStatus "$3" "" "$5" "tar" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "tar" "$7") == "uninstalled" ]]; then mv "$5$3" /Applications; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi
    rm -rf "$2.tar.bz2" && rm -rf "$3"
  elif [ $1 == "pkg" ]; then curl -s -L -o "$2.pkg" $4 > /dev/null;
    if [[ $(appStatus "$3" "" "$2" "pkg" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "" "$2" "pkg" "$7") == "outdated" && $6 != "noupdate" ]]; then installer -pkg "$2.pkg" -target /; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n';
    elif [[ $(appStatus "$3" "" "$2" "pkg" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "" "$2" "pkg" "$7") == "uninstalled" ]]; then installer -pkg "$2.pkg" -target / ; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi
    rm -rf "$2.pkg"; fi
}

###############################
#    Install selected apps    #
###############################
installApp "dmg" "Firefox" "Firefox.app" "http://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US" "" "" ""
installApp "dmg" "Chrome" "Google Chrome.app" "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg" "" "" ""
installApp "dmg" "TorBrowser" "TorBrowser.app" "https://www.torproject.org/dist/torbrowser/8.0.4/TorBrowser-8.0.4-osx64_en-US.dmg" "" "" ""
installApp "zip" "GitHub" "GitHub Desktop.app" "https://central.github.com/deployments/desktop/desktop/latest/darwin" "" "" ""
installApp "zip" "Atom" "Atom.app" "https://atom.io/download/mac" "" "" ""
installApp "dmg" "Android Std" "Android Studio.app" "https://redirector.gvt1.com/edgedl/android/studio/install/4.1.1.0/android-studio-ide-201.6953283-mac.dmg" "" "noupdate" ""
installApp "dmg" "Docker" "Docker.app" "https://download.docker.com/mac/stable/Docker.dmg" "" "" ""
installApp "dmg" "BBEdit" "BBEdit.app" "https://s3.amazonaws.com/BBSW-download/BBEdit_13.5.3.dmg" "" "" ""
installApp "tar" "FileZilla" "FileZilla.app" "https://download.filezilla-project.org/client/FileZilla_latest_macosx-x86.app.tar.bz2" "" "" ""
installApp "dmg" "Viscosity" "Viscosity.app" "http://www.sparklabs.com/downloads/Viscosity.dmg" "" "" ""
installApp "zip" "coconutBattery" "coconutBattery.app" "http://www.coconut-flavour.com/downloads/coconutBattery_3_1_2.zip" "" "" ""
installApp "zip" "Flux" "Flux.app" "https://justgetflux.com/mac/Flux.zip" "" "" "build"
installApp "zip" "Duet" "duet.app" "http://www.duetdisplay.com/mac" "" "" ""
installApp "dmg" "Spotify" "Spotify.app" "http://download.spotify.com/Spotify.dmg" "" "" ""
installApp "dmg" "VLC" "VLC.app" "http://get.videolan.org/vlc/3.0.11.1/macosx/vlc-3.0.11.1.dmg" "" "" ""
installApp "dmg" "GIMP" "Gimp-2.10.app" "http://download.gimp.org/mirror/pub/gimp/v2.10/osx/gimp-2.10.14-x86_64-1.dmg" "" "" ""
installApp "dmg" "HandBrake" "HandBrake.app" "https://download.handbrake.fr/releases/1.1.1/HandBrake-1.1.1.dmg" "" "" ""
installApp "dmg" "Skype" "Skype.app" "http://www.skype.com/go/getskype-macosx.dmg" "" "" ""
# Custom apps
installApp "zip" "Audio Hijack" "Audio Hijack.app" "https://rogueamoeba.com/audiohijack/download/AudioHijack.zip" "" "" ""
installApp "zip" "CertAid" "CertAid.app" "https://downloads.mit.edu/released/certaid/certaid-mac-2_2_6.zip" "" "" ""
installApp "zip" "Fetch" "Fetch.app" "https://fetchsoftworks.com/fetch/download/Fetch_5.8.1.zip" "" "" ""
installApp "zip" "Figma" "Figma.app" "https://desktop.figma.com/mac/Figma.zip" "" "" ""
installApp "zip" "Freeze" "Freeze.app" "https://www.freezeapp.net/download/Freeze.zip" "" "" ""
installApp "zip" "Loopback" "Loopback.app" "https://rogueamoeba.com/loopback/download/Loopback.zip" "" "" ""
installApp "zip" "SD Card Formatter" "SD Card Formatter.app" "https://www.sdcard.org/downloads/formatter/eula_mac/SDCardFormatterv5_Mac.zip" "" "" ""
installApp "zip" "SoundSource" "SoundSource.app" "https://rogueamoeba.com/soundsource/download/SoundSource.zip" "" "" ""
installApp "dmg" "ApacheDirectoryStudio" "ApacheDirectoryStudio.app" "https://apache.osuosl.org/directory/studio/2.0.0.v20200411-M15/ApacheDirectoryStudio-2.0.0.v20200411-M15-macosx.cocoa.x86_64.dmg" "" "" ""
installApp "dmg" "Audacity" "Audacity.app" "https://www.fosshub.com/Audacity.html?dwl=audacity-macos-2.4.2.dmg" "" "" ""
installApp "dmg" "GNS3" "GNS3.app" "https://github.com/GNS3/gns3-gui/releases/download/v2.2.17/GNS3-2.2.17.dmg" "" "" ""
installApp "dmg" "Keybase" "Keybase.app" "https://prerelease.keybase.io/Keybase.dmg" "" "" ""
installApp "dmg" "Kindle" "Kindle.app" "https://www.amazon.com/kindlemacdownload/ref=klp_hz_mac" "" "" ""
installApp "dmg" "Pacifist" "Pacifist.app" "https://www.charlessoft.com/cgi-bin/pacifist_download.cgi?type=dmg" "" "" ""
installApp "dmg" "Raspberry Pi Imager" "Raspberry Pi Imager.app" "https://downloads.raspberrypi.org/imager/imager_1.5.dmg" "" "" ""
installApp "dmg" "Signal" "Signal.app" "https://updates.signal.org/desktop/signal-desktop-mac-1.39.4.dmg" "" "" ""
installApp "dmg" "Webex" "Webex.app" "https://binaries.webex.com/WebexTeamsDesktop-MACOS-Gold/Webex.dmg"
installApp "dmg" "Wireshark" "Wireshark.app" "https://1.na.dl.wireshark.org/osx/Wireshark%203.4.2%20Intel%2064.dmg" "" "" ""
installApp "dmg" "balenaEtcher" "balenaEtcher.app" "https://github.com/balena-io/etcher/releases/download/v1.5.113/balenaEtcher-1.5.113.dmg" "" "" ""
installApp "pkg" "PowerShell" "PowerShell.app" "https://github.com/PowerShell/PowerShell/releases/download/v7.1.0/powershell-7.1.0-osx-x64.pkg" "" "noupdate" ""
installApp "pkg" "Microsoft Office" "Microsoft Word.app" "https://officecdn-microsoft-com.akamaized.net/pr/C1297A47-86C4-4C1F-97FA-950631F94777/MacAutoupdate/Microsoft_Office_16.44.20121301_Installer.pkg" "" "noupdate" ""
installApp "pkg" "RingCentral" "RingCentral.app" "https://app.ringcentral.com/download/RingCentral.pkg" "" "noupdate" ""
installApp "pkg" "UniFi" "UniFi.app" "https://dl.ui.com/unifi/6.0.41/UniFi.pkg" "" "noupdate" ""
installApp "pkg" "WorkSpaces" "WorkSpaces.app" "https://d2td7dqidlhjx7.cloudfront.net/prod/global/osx/WorkSpaces.pkg" "" "noupdate" ""
installApp "pkg" "YubiKey Manager" "YubiKey Manager.app" "https://developers.yubico.com/yubikey-manager-qt/Releases/yubikey-manager-qt-latest-mac.pkg" "" "" ""
installApp "pkg" "Zoom" "zoom.us.app" "https://zoom.us/client/latest/Zoom.pkg" "" "noupdate" ""
installApp "pkg" "cloudLibrary" "cloudLibrary.app" "https://usestrwebaccess.blob.core.windows.net/apps/mac/cloudLibrary-2.3.1708230907.pkg" "" "noupdate" ""


###############################
#    Print script footer      #
###############################
echo $'--------------------------------------------------------------------------------'
echo $'\360\237\222\254  - Thank you for using macapps.link!! Liked it? Recommend us to your friends!'
echo $'\360\237\222\260  - The time is gold. Have I saved you a lot? :) - https://macapps.link/donate'
echo $'--------------------------------------------------------------------------------\n'
rm -rf ~/macapps
