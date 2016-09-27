#!/bin/bash
wget -O ./usr/bin/$1.wrapper https://raw.githubusercontent.com/probonopd/AppImageKit/master/desktopintegration
chmod a+x ./usr/bin/$1.wrapper
sed -i -e "s|Exec=$1|Exec=$1.wrapper|g" $1.desktop
