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

## CURRENT LOCALE
localechange=$(cat /etc/locale.gen | grep -v "#")

## KEYMAP VAR
keymaps=( $( find /usr/share/keymaps/ -name "*.map.gz" | cut -d/ -f7 | sed -e "s/.map.gz/ /g" | sed "s/ /\!/g" | sed 's/windowkeys!/windowkeys/g' | sort | sed ':a;N;s/\n//g;ta' ) )

## HARD DISKS
hd=( $( fdisk -l | egrep -o '/dev/sd[a-x]' | uniq | sed 's/\n/!/g' | sed ':a;N;s/\n/\!/g;ta' ) )


# FUNCTIONS
######################
installok(){
	yad \
	--title="Mazon Install" \
	--width="500" \
	--height="200" \
	--center \
	--image="sucess.png" \
	--align="center" \
	--text="\n\nSua instalação está completa! Obrigado por utilizar a Mazon OS - dúvidas? visite nosso fórum em: \nhttp://mazonos.com/forum\n\nGood Vibes B)" \
	--button="gtk-close:0" --button="REBOOT!:1"
	rt=$?
	[[ $rt -eq 1 ]] && reboot

	exit 0
}


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

gparted $HD &
wait

partitions=( $( fdisk -l | grep $HD | egrep -o '/dev/sd[a-z][0-9]' | uniq | sed 's/\n/!/g' | sed ':a;N;s/\n/\!/g;ta' ) )

form_part=$(yad --title="Mazon Install" \
	--width="500" \
	--height="200" \
	--center \
	--image="hd.png" \
	--text="\nDefina os principais pontos de montagem:\n" \
	--form \
	--field="(root*) /:":CB  "not mounted"!$partitions \
	--field="(home) /home:":CB "not mounted"!$partitions \
	--field="(swap) :":CB "not mounted"!$partitions \
	--button="gtk-close:1" --button="gtk-ok:0"
	)
ret=$?
[[ $ret -eq 1 ]] && exit 0

MOUNTROOT=$(echo "$form_part" | cut -d"|" -f 1)
MOUNTHOME=$(echo "$form_part" | cut -d"|" -f 2)
MOUNTSWAP=$(echo "$form_part" | cut -d"|" -f 3)

if [[ $MOUNTROOT == "not mounted" ]] ; then
	yad --title="Error" \
		--text "Sem partição / não podemos instalar!" \
		--button="gtk-close:1"
	exit 0
else
	mkdir /mnt/mazonos
	mount $MOUNTROOT /mnt/mazonos
fi

if [[ $MOUNTSWAP != "not mounted" ]] ; then
	swapon $MOUNTSWAP
fi

form_user=$(yad --title="Mazon Install" \
	--width="500" \
	--height="200" \
	--center \
	--image="user.png" \
	--text="\nCrie um usuário:\n" \
	--form \
	--field="Usuário :" \
	--field="Senha :":H \
	--button="gtk-close:1" --button="gtk-ok:0"
	)
ret=$?
[[ $ret -eq 1 ]] && exit 0

MUSER=$(echo "$form_user" | cut -d"|" -f 1)
MPASSWD=$(echo "$form_user" | cut -d"|" -f 2)

form_resumo=$(yad --title="Mazon Install" \
	--width="500" \
	--height="200" \
	--center \
	--image="resume.png" \
	--text="\n\nResumo...\n\n\Linguagem: $LANGUAGE\nKeyboard: $KEYBOARD\nPonto de montagem /: $MOUNTROOT\nPonto de montagem /home: $MOUNTHOME\nPonto de montagem swap: $MOUNTSWAP\nUser: $MUSER" \
	--form \
	--field="Deseja instalar?":LBL \
	--button="gtk-close:1" --button="gtk-ok:0"
)

ret=$?
[[ $ret -eq 1 ]] && exit 0

rsync -ravp --info=progress2 /lib/initramfs/system/ /mnt/mazonos/ | grep -o "[0-9]*%" | tr -d '%' | \
	yad --progress \
	--title="Mazon Install" \
	--width="500" \
	--height="100" \
	--center \
	--text="\nAguardem enquanto instalamos a Mazon para você.\n" \
	--progress-text="installing..." \
	--pulsate \
	--percentage=1 \
	--auto-close \
	--auto-kill


### INSTALL COMPLETE
### FSTAB CONFIGURATION
#####################################

bl=$(blkid $MOUNTROOT | cut -d"\"" -f2)
echo "UUID=$bl / ext4 defaults 1 1" >> /mnt/mazonos/etc/fstab

if [[ $MOUNTSWAP != "not mounted" ]] ; then
	blswap=$(blkid $MOUNTSWAP | cut -d"\"" -f2)
	echo "UUID=$blswap swap swap pri=1 0 0" >> /mnt/mazonos/etc/fstab
fi

if [[ $MOUNTHOME != "not mounted" ]] ; then
	mount $MOUNTHOME /mnt/mazonos/home
	blhome=$(blkid $MOUNTHOME | cut -d"\"" -f2)
	echo "UUID=$blhome /home ext4 defaults 0 0" >> /mnt/mazonos/etc/fstab
fi

### USER CREATION
chroot /mnt/mazonos/ /bin/bash -c "useradd -m -G audio,video $MUSER -p $MPASSWD > /dev/null 2>&1"
chroot /mnt/mazonos/ /bin/bash -c "(echo $MUSER:$MPASSWD) | chpasswd -m > /dev/null 2>&1"

### REMOVE LIGHTDM
chroot /mnt/mazonos/ /bin/bash -c "banana -r lightdm -y > /dev/null ; banana -r lightdm_gtk_greeter -y > /dev/null ; banana -r sudo -y > /dev/null ; userdel mazon > /dev/null ; rm -rf /home/mazon" | \
yad --progress \
	--title="Mazon Install" \
	--width="500" \
	--height="100" \
	--center \
	--text="\nRemovendo pacotes temporários...\n" \
	--progress-text="removing..." \
	--pulsate \
	--auto-close \
	--auto-kill

### SETING LOCALE
chroot /mnt/mazonos/ /bin/bash -c "sed 's/LANG=.*/LANG=$LANGUAGE/g' /etc/profile.d/i18n.sh > /etc/profile.d/i18n.sh.change ; mv /etc/profile.d/i18n.sh.change /etc/profile.d/i18n.sh ; sed 's/$localechange/#$localechange/g' /etc/locale.gen > /etc/locale.gen.change ; sed 's/#$LANGUAGE/$LANGUAGE/g' /etc/locale.gen.change > /etc/locale.gen ; locale-gen" | \
yad --progress \
	--title="Mazon Install" \
	--width="500" \
	--height="100" \
	--center \
	--text="\nAjustando linguagens...\n" \
	--progress-text="ajusting..." \
	--pulsate \
	--auto-close \
	--auto-kill

### SETING KEYBOARD
chroot /mnt/mazonos/ /bin/bash -c "sed 's/KEYMAP=\".*\"/KEYMAP=\"$KEYBOARD\"/g' /etc/sysconfig/console > /etc/sysconfig/console.change ; mv /etc/sysconfig/console.change /etc/sysconfig/console " | \
yad --progress \
	--title="Mazon Install" \
	--width="500" \
	--height="100" \
	--center \
	--text="\nAjustando keyboard...\n" \
	--progress-text="ajusting..." \
	--pulsate \
	--auto-close \
	--auto-kill

### GRUB FORM
form_grub=$(yad --title="Mazon Install" \
	--width="500" \
	--height="200" \
	--center \
	--image="question.png" \
	--text="\nVocê gostaria de instalar o GRUB?\n" \
	--button="gtk-close:1" --button="gtk-ok:0"
)

ret=$?
[[ $ret -eq 1 ]] && installok

### GRUB INSTALL
cd /mnt/mazonos/
mount --rbind /dev dev/
mount --rbind /sys sys/	
mount --rbind /run run/
mount --type proc /proc proc/
cd -
chroot /mnt/mazonos/ bin/bash -c "grub-install $HD > /dev/null 2>&1" | \
	yad --progress \
	--title="Mazon Install" \
	--width="500" \
	--height="100" \
	--center \
	--text="\nInstalando GRUB\n" \
	--progress-text="installing..." \
	--pulsate \
	--auto-close \
	--auto-kill

chroot /mnt/mazonos/ bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1" | \
	yad --progress \
	--title="Mazon Install" \
	--width="500" \
	--height="100" \
	--center \
	--text="\nCriando /boot/grub/grub.cfg\n" \
	--progress-text="installing..." \
	--pulsate \
	--auto-close \
	--auto-kill

umount -Rl /mnt/mazonos
installok
