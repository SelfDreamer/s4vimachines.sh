#!/usr/bin/env bash
debian_distros=$(lsb_release -d | grep -oP "Parrot|Kali")

if [[ "$debian_distros" ]]; then
  # Para distribuciones basadas en Debian
  sudo apt update
  sudo apt install coreutils util-linux npm nodejs bc moreutils -y
  sudo apt install node-js-beautify -y 
else
  # Para distribuciones basadas en arch
  sudo pacman -Sy
  sudo pacman -S coreutils npm nodejs bc moreutils --noconfirm
  sudo npm install -g js-beautify 
fi

rm -rf node_modules
rm -rf *.json
