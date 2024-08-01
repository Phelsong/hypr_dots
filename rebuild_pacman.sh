#!/bin/bash

arch=x86_64
mirror=https://ca.mirrors.cicku.me/archlinux
pac_ver=pacman-6.1.0-3
pkgname=${pkg}-${arch}.pkg.tar.zst

cd /tmp

if [[ -e /var/cache/pacman/pkg/${pkgname} ]]; then
    ln -sf /var/cache/pacman/pkg/${pkgname} .
else
    wget ${mirror}/core/os/${arch}/${pkgname} || exit 1
fi
sudo tar -xvpf ${pkgname} -C / --exclude .PKGINFO --exclude .INSTALL || exit 1

# now reinstall using pacman to update the local pacman db 
sudo pacman -Sf pacman || exit 1

# now update your system
sudo pacman -Syu
