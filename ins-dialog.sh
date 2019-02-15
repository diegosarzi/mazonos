#!/bin/bash
#
#
#

# functions
#########################
# tar full
fulltar(){
clear
echo "teste"
sleep 2
clear
}

# tar minimal
tarminimal(){
	break
}

# custom tar
customtar(){
 	break
}

# primeira tela // helo
##########################
dialog --msgbox '- Welcome to install Mazon OS. B)' 5 40

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
				XFCE4) fulltar ;;
				i3WM) clear ; echo "ola" ; sleep 2 ;;
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
			
			# create vars
			libre= ; gimp= ; inkscape= ; qt5= ; sublime_text= ; vlc= ; openjdk= ; telegram=

			echo "$rescustom" | while read LINHA
			do
				if [ $LINHA = "LIBREOFFICE" ]; then
					libre="--exclude-from=/tmp/libre.exclude" 
					clear ; echo "$LINHA" ; sleep 1 
				elif [ $LINHA = "GIMP" ]; then
					gimp="--exclude-from=/tmp/gimp.exclude"
					clear ; echo "$LINHA" ; sleep 1 
				elif [ $LINHA = "INKSCAPE" ]; then
					inkscape="--exclude-from=/tmp/inkscape.exclude"
					clear ; echo "$LINHA" ; sleep 1 
				elif [ $LINHA = "QT5" ]; then
					qt5="--exclude-from=/tmp/qt5.exclude"
					clear ; echo "$LINHA" ; sleep 1 
				elif [ $LINHA = "SUBLIME_TEXT" ]; then
					sublime_text="--exclude-from=/tmp/sublime_text.exclude"
					clear ; echo "$LINHA" ; sleep 1 
				elif [ $LINHA = "VLC" ]; then
					vlc="--exclude-from=/tmp/vlc.exclude"
					clear ; echo "$LINHA" ; sleep 1 
				elif [ $LINHA = "OPENJDK" ]; then
					openjdk="--exclude-from=/tmp/openjdk.exclude"
					clear ; echo "$LINHA" ; sleep 1 
				elif [ $LINHA = "TELEGRAM" ]; then
					telegram="--exclude-from=/tmp/telegram.exclude"
					clear ; echo "$LINHA" ; sleep 1 
				elif [ $LINHA = "SIMPLESCREENRECORDER" ]; then
					ssr="--exclude-from=/tmp/ssr.exclude"
					clear ; echo "$LINHA" ; sleep 1 
				fi				
			done
			;;
		quit) break ;;
	esac
done

clear
