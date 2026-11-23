# Makes Qt5 and Qt6 applications follow the Cinnamon (GTK3) theme.
#
# /etc/profile.d/qt5ct.sh sets QT_QPA_PLATFORMTHEME=qt5ct, which Qt6 apps
# cannot use and Qt5 apps only partly use. This file sorts after it and
# switches everything to the GTK3 platform theme, so Qt apps inherit the
# same WhiteSur-Dark theme, icons, fonts and cursor as the rest of the desktop.
export QT_QPA_PLATFORMTHEME=gtk3
