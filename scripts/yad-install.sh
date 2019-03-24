#!/bin/bash
#########################################
#                                       #
#      install Mazon (YAD) - 2019       #
#  Diego Sarzi  <diegosarzi@gmail.com>  #
#            License: MIT               #
#                                       #
#########################################

# VARS
#######################

## LOCALE VAR
locales=( $( cat /etc/locale.gen | grep _ | sed 's/#//g' | sed 's/  $/!/g' | sed 's/ /./g' | awk 'NR>4' | sed 's/\n/!/g' |  sed ':a;N;s/\n//g;ta'  ) )

## KEYMAP VAR
keymaps=( $( find /usr/share/keymaps/ -name "*.map.gz" | cut -d/ -f7 | sed -e "s/.map.gz/ /g" | sed "s/ /\!/g" | sed 's/windowkeys!/windowkeys/g' | sort | sed ':a;N;s/\n//g;ta' ) )

## HARD DISKS
hd=( $( fdisk -l | egrep -o '/dev/sd[a-x]' | uniq | sed 's/\n/!/g' | sed ':a;N;s/\n/\!/g;ta' ) )

# SCREENS
#######################

## MAIN SCREEN
screnn=$(yad \
	--title="Mazon Install" \
	--width="500" \
	--height="200" \
	--center \
	--image="logo.png" \
	--align="center" \
	--text="\n\n\n\nSeja bem vindo ao instalador da Mazon OS\nwww.mazonos.com\nirc.freenode.com #mazonos" \
	--button="gtk-close:1" --button="gtk-ok:0"
	)
ret=$?
[[ $ret -eq 1 ]] && exit 0


## LANGUAGEM AND KEYBOARD SCREEN
form_lang=$(yad --title"Mazon Install" \
	--width="500" \
	--height="200" \
	--center \
	--image="region.png" \
	--text="\nVamos começar escolhendo a sua linguagem e seu teclado ok?\n" \
	--form \
	--field="Linguagem":CB $locales \
	--field="Teclado":CB $keymaps \
	--button="gtk-close:1" --button="gtk-ok:0"
	)
ret=$?
[[ $ret -eq 1 ]] && exit 0

LANGUAGE=$(echo "$form_lang" | cut -d"|" -f 1)
KEYBOARD=$(echo "$form_lang" | cut -d"|" -f 2)

form_part=$(yad --title="Mazon Install" \
	--width="500" \
	--height="200" \
	--center \
	--image="hd.png" \
	--text="\nQual HD gostaria de instalar a Mazon?\n" \
	--form \
	--field="/dev/sd(x)":CB $hd \
	--field="*Crie e formate pelo menos uma partição root (/) ext4 para instalação.":LBL \
	--field="Ex: / -> 20G (ext4)\n/home -> 40G (ext4)\nswap -> 2G":LBL \
	--button="gtk-close:1" --button="gtk-ok:0"
	)
ret=$?
[[ $ret -eq 1 ]] && exit 0

HD=$(echo "$form_part" | cut -d"|" -f 1)

#gparted $HD &
#wait

partitions=( $( fdisk -l | grep $HD | egrep -o '/dev/sd[a-z][0-9]' | uniq | sed 's/\n/!/g' | sed ':a;N;s/\n/\!/g;ta' ) )

form_part=$(yad --title="Mazon Install" \
	--width="500" \
	--height="200" \
	--center \
	--image="hd.png" \
	--text="\nDefina os principais pontos de montagem:\n" \
	--form \
	--field="(root*) /:":CB $partitions \
	--field="(home) /home:":CB $partitions \
	--field="(swap) :":CB $partitions \
	--button="gtk-close:1" --button="gtk-ok:0"
	)
ret=$?
[[ $ret -eq 1 ]] && exit 0

MOUNTROOT=(echo "$form_part" | cut -d"|" -f 1)
MOUNTHOME=(echo "$form_part" | cut -d"|" -f 2)
MOUNTSWAP=(echo "$form_part" | cut -d"|" -f 3)

mkdir /mnt/mazonos
mount $MOUNTROOT /mnt/mazonos
mkswap $MOUNTSWAP
