installed_groups="base-devel xfce4 xfce4-goodies"
append_native="git"
echo Native:
(comm -23 <(pacman -Qnqtt) <(pacman -Qqg $installed_groups | sort); printf %"s\n" $append_native $installed_groups) | sort
echo 
echo AUR:
append_foreign="aria2-fast"
(pacman -Qmqtt; printf %"s\n" $append_foreign) | sort
