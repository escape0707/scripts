efibootmgr --disk /dev/sda1 --part 1 --create --label "Arch Linux" --loader /vmlinuz-linux --unicode 'root=PARTUUID=4ac11c85-a960-9a42-8eb5-5ae64f141c66 rw initrd=/intel-ucode.img initrd=/initramfs-linux.img' --verbose

