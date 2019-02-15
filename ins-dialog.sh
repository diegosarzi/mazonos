#!/bin/bash
#######################################################
#       install dialog Mazon OS - version 0.0.1       #
#                                                     #
#      @utor: Diego Sarzi <diegosarzi@gmail.com>      #
#      created: 2019/02/15          licence: MIT      #
#######################################################

# primeira tela // helo
##########################
dialog --title 'Mazon OS - beta install' --msgbox '- Welcome to install Mazon OS. B)' 5 45

# escolha a hd a ser instalada // install hd
#########################
partitions=( $(blkid | cut -d: -f1 | sed "s/$/ '*' /") )
part=$(dialog --clear --menu 'Choose partition for installation Mazon:' \
	0 0 0 \
	"${partitions[@]}" \
	2>&1 >/dev/tty )

# deseja formatar?
format=
dialog --title '**** FORMAT ****' \
	--yesno "*(All data will be lost) \nFormat partition $part ?" 6 45 && format='yes'
if [ $format = 'yes' ] ; then
	# WARNING! FORMAT PARTITION
	#######################
	dialog --msgbox "Formating $part (ext4) ..." 5 45
	sleep 2
	########################
	######## mkfs.ext4 $part
fi

# Partition mount
########################
# mount $part /mnt
# cd /mnt

# tela de download // wget
#########################
download=
dialog --yesno 'Would you like to download mazon-lasted.tar.xz?' 5 55 && download='yes'
if [ $download = 'yes' ]; then
	URL="https://sourceforge.net/projects/mazonos/files/mazon_beta-1.2.tar.xz"
	wget "$URL" 2>&1 | \
 	 stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | \
  	 dialog --gauge "Downloading mazon-lasted.tar.xz..." 7 70
fi

# segunda tela // menu
#########################
while : ; do
	resposta=$(
	dialog --stdout                        	       \
           --title 'Instal Configuration'              \
   	   --menu 'Choose your option:'                \
           0 0 0                                                       \
	   full       '*8.2G Free disk (Xfce4 or i3wm)'                \
           minimal    'Minimall install, not desktop enviorement.'     \
           custom     'Choose softwares. (GIMP, QT5, LIBREOFFICE...)'  \
	   quit	      'Exit install')

	# sair com cancelar ou esc
	[ $? -ne 0 ] && break

	case "$resposta" in
		full) resfull=$(dialog --stdout    \
			--title 'FULL INSTALATION' \
			--menu 'Choose your Desktop Enviroment:' \
			0 0 0                       \
			XFCE4 'Classic and powerfull!' \
			i3WM 'Desktop for advanceds guys B).') 
			case "$resfull" in
				# TROCAR POR /MNT *********************
				XFCE4) (pv -n mazon_lasted.tar.xz | tar xJpvf - -C /root/scripts/mazonos/mnt ) \
					2>&1 | dialog --gauge "Extracting files..." 6 50 ;;
				i3WM) (pv -n mazon_lasted.tar.gz | tar xJpvf - -C /root/scripts/mazonos/mnt ) \
					2>&1 | dialog --gauge "Extracting files..." 6 50 ;;
			esac
			;;		
		minimal) dialog --msgbox 'minimal' 0 0
			;;
		custom) rescustom=$(dialog --stdout \
			--separate-output \
			--checklist 'Choose install softwares:' \
			0 0 0                       \
			LIBREOFFICE '...' OFF \
			GIMP 'Classic and powerfull!' OFF  \
			INKSCAPE '...' OFF \
			QT5 'Desktop for advanceds guys B).' OFF \
			SUBLIME_TEXT '...' OFF \
			VLC '...' OFF \
			OPENJDK '...' OFF \
			TELEGRAM '...' OFF \
			SIMPLESCREENRECORDER '...' OFF)
			
			# create choose softwares vars
			libre= ; gimp= ; inkscape= ; qt5= ; sublime_text= ; vlc= ; openjdk= ; telegram=

			echo "$rescustom" | while read LINHA
			do
				if [ $LINHA = "LIBREOFFICE" ]; then
					libre="--exclude-from=/tmp/libre.exclude" 
				elif [ $LINHA = "GIMP" ]; then
					gimp="--exclude-from=/tmp/gimp.exclude"
				elif [ $LINHA = "INKSCAPE" ]; then
					inkscape="--exclude-from=/tmp/inkscape.exclude"
				elif [ $LINHA = "QT5" ]; then
					qt5="--exclude-from=/tmp/qt5.exclude"
				elif [ $LINHA = "SUBLIME_TEXT" ]; then
					sublime_text="--exclude-from=/tmp/sublime_text.exclude"
				elif [ $LINHA = "VLC" ]; then
					vlc="--exclude-from=/tmp/vlc.exclude"
				elif [ $LINHA = "OPENJDK" ]; then
					openjdk="--exclude-from=/tmp/openjdk.exclude"
				elif [ $LINHA = "TELEGRAM" ]; then
					telegram="--exclude-from=/tmp/telegram.exclude"
				elif [ $LINHA = "SIMPLESCREENRECORDER" ]; then
					ssr="--exclude-from=/tmp/ssr.exclude"
				fi				
			done
			;;
		quit) break ;;
	esac
done

clear
