#!/bin/bash

VER="rapid-2.5.1" # Нельзя двигать эту строчку, к ней привязан upgrade()

# Чувствительность/громкость интерфейсов UDKA:
vstr_mic=60      # Встроенный микрофон. Используется в sp_j()
UDKA_Mic=70      # Микрофон (хз какой). Используется в set_volume_UDKA()
UDKA_PCM=85      # Трубка.              Используется в set_volume_UDKA()
UDKA_Bal_in=30   # Балансный вход.      Используется в xlr_j()
UDKA_Bal_out=30  # Балансный выход.     Используется в j_xlr() и xlr_wav()
UDKA_Headset=70  # Гарнитура.           Используется в set_volume_UDKA()
UDKA_Speaker=90  # Динамики.            Используется в set_volume_UDKA()
UDKA_left=85     # Левая трубка.        Используется в left_sine() left_wav()
UDKA_right=85    # Правая трубка.       Используется в right_sine() right_wav()

# Чувствительность микрофона встроенной КАМЕРЫ. Используется в basis_for_the_audio_test()
CAMERA_Mic=90

# Чувствительность/громкость интерфейсов LAZURIT, AGAT, LAVA:
LAZURIT_Mic=85
LAZURIT_Headset=85
LAZURIT_PCM=85
LAZURIT_Speaker=85
AGAT_Speaker=80
LAVA_Mic=85

# Для Гранатов 4К:
sound_output_device=2           # Порядковый номер USB-гарнитуры в aplay -l для вывода звука. Используется в set_volume_granat4k_output()
volume_sound_output_device=80   # Уровень громкости USB-гарнитуры для вывода звука.           Используется в set_volume_granat4k_output()
BAL_INPUT=30                    # Уровень чувствительности балансных входов.                  Используется в set_volume_granat4k_input()
BAL_OUTPUT=30                   # Уровень громкости балансных выходов.                        Используется в set_volume_granat4k_output()

show_software() # Thanks to Ivan Kanshin
{
	clear
	echo -e "${BLUE}*** BIOS ***${NORMAL}"
	echo -en "${YELLOW}Vendor:  ${NORMAL}"
	if [[ -e /sys/devices/virtual/dmi/id/bios_vendor ]]; then cat /sys/devices/virtual/dmi/id/bios_vendor 2>/dev/null
	else echo -e "[${RED}Not found${NORMAL}]"
	fi

	echo -en "${YELLOW}Version: ${NORMAL}"
	if [[ -e /sys/devices/virtual/dmi/id/bios_version ]]; then cat /sys/devices/virtual/dmi/id/bios_version 2>/dev/null
	else echo -e "[${RED}Not found${NORMAL}]"
	fi

	echo -en "${YELLOW}Release: ${NORMAL}"
	if [[ -e /sys/class/dmi/id/bios_release ]]; then cat /sys/class/dmi/id/bios_release 2>/dev/null
	else echo -e "[${RED}Not found${NORMAL}]"
	fi
	
	echo -en "${YELLOW}Config:  ${NORMAL}"
	if [[ -e /sys/class/dmi/id/board_name ]]; then cat /sys/class/dmi/id/board_name 2>/dev/null
	else echo -e "[${RED}Not found${NORMAL}]"
	fi
	
	echo -en "${YELLOW}Build Date: ${NORMAL}"
	if [[ -e /sys/class/dmi/id/bios_date ]]; then cat /sys/class/dmi/id/bios_date 2>/dev/null
	else echo -e "[${RED}Not found${NORMAL}]"
	fi

	echo -e "${BLUE}*** OS ***${NORMAL}"
	os=`lsb_release -d 2>/dev/null | awk -F : '{print $2}' | sed 's/\t*//'`
	echo -e "${YELLOW}Version: ${NORMAL}"$os""
	if [[ -e /etc/astra_update_version ]]; then astraupdate=`grep Update /etc/astra_update_version 2>/dev/null | awk '{print $2}'`
		elif [[ -e /etc/astra_version ]]; then astraupdate=`cat /etc/astra_version 2>/dev/null`
	fi
	if [[ -z $astraupdate ]]; then echo -e "${YELLOW}Update:${NORMAL} [${RED}Not found${NORMAL}]"
	else echo -e "${YELLOW}Update: ${NORMAL} "$astraupdate""
	fi
	echo -en "${YELLOW}Edition: ${NORMAL}"
	if [[ -e /etc/astra_license ]]; then cat /etc/astra_license | egrep -i 'orel|smolensk' | awk -F = {'print $2'}
	else echo -e "[${RED}Not found${NORMAL}]"
	fi

	echo -en "${YELLOW}Kernel:  ${NORMAL}"; uname -sro

	echo -e "${BLUE}*** Software ***${NORMAL}"
	if [[ -e /home/protei/Protei-MFAT-V/version ]]; then echo -en "${YELLOW}MFAT-V: ${NORMAL}"; /home/protei/Protei-MFAT-V/version | grep -iE 'Protei|ELIOS'; fi
	if [[ -e /opt/protei/Protei-MFAT-V/bin/version.sh ]]; then echo -en "${YELLOW}MFAT-V: ${NORMAL}"; /opt/protei/Protei-MFAT-V/bin/version.sh | grep -iE 'Protei|ELIOS'; fi
	if [[ -e /home/protei/Protei-VCSM-Client/version ]]; then echo -en "${YELLOW}VCSM-CLIENT: ${NORMAL}"; /home/protei/Protei-VCSM-Client/version | grep -iE 'RELEASE|ELIOS'; fi
	if [[ -e /home/protei/Protei-VCSM-Server/version ]]; then echo -en "${YELLOW}VCSM-SERVER: ${NORMAL}"; /home/protei/Protei-VCSM-Server/version | grep -iE 'RELEASE|ELIOS'; fi

	echo -en "${YELLOW}IGB-driver:  ${NORMAL}"
	if modinfo igb &>/dev/null; then modinfo igb 2>/dev/null | grep -m1 version: | awk '{print $2}'
	else echo -en "[${RED}Not found${NORMAL}]\n"
	fi

	echo -en "${YELLOW}EDKA-driver: ${NORMAL}"
	if modinfo edka &>/dev/null; then modinfo edka 2>/dev/null | grep -m1 version: | awk '{print $2}'
	else echo -en "[${RED}Not found${NORMAL}]\n"
	fi

	echo -en "${YELLOW}protei-i2c:  ${NORMAL}"; pi2c=`dpkg -l 2>/dev/null | grep i2c | awk '{print $3}'`
	if [[ -z $pi2c ]]; then echo -en "[${RED}Not found${NORMAL}]\n"
	else echo "$pi2c"
	fi

	echo -en "${YELLOW}protei-pvc:  ${NORMAL}"
	if modinfo pvc &>/dev/null; then modinfo pvc 2>/dev/null | grep -m1 version: | awk '{print $2}'
	else echo -en "[${RED}Not found${NORMAL}]\n"
	fi

	echo -en "Press <Enter> to see Protei packages..."; read A

	echo -en "${BLUE}*** Protei packages ***${NORMAL}\n"
	if dpkg --help &>/dev/null; then dpkg -l 2>/dev/null | grep -i protei | awk '{print $2, $3}'
	else echo -en "[${RED}dpkg - Not installed${NORMAL}]\n"
	fi
}

show_id_i350()
{
	id_i350=`grep PCI_S /sys/class/net/*/device/uevent 2>/dev/null | awk -F "/" '{print $7}' | sed 's/uevent://; s/ *//; s/=/ /'`
	if [[ -z $id_i350 ]]; then grep PCI_S /sys/class/net/*/device/uevent | awk -F = '{print $2}'
		else echo "$id_i350"
	fi
}

show_hardware() # Thanks to Alexey Vasiliev, Andrey Pirogov, Igor Lisovsky
{
	clear
	echo -en "${YELLOW}Date: ${NORMAL}"; date
	
	echo -en "${YELLOW}Platform: ${NORMAL}"
	Platform=`cat /sys/class/dmi/id/board_name 2>/dev/null`
		if [[ -z $Platform ]]; then echo -e "[${RED}Not found${NORMAL}]"
		else echo -e "$Platform"
		fi
	
	echo -en "${YELLOW}STM: ${NORMAL}"; stm=`lsusb 2>/dev/null | grep 276c:0100 2>/dev/null | awk '{print $6}'`
	if [[ -z $stm ]]; then echo -e "[${RED}Not found${NORMAL}]"
	else
		echo -n "$stm"
		stmiprod=`lsusb -v -d 276c:0100 2>/dev/null | grep iProd | awk '{print $3,$4}' | sed 's/ *//; s/can*//'`
		if [[ -z $stmiprod ]]; then echo -e "[${RED}IProduct Not found${NORMAL}]"
		else echo " $stmiprod"
		fi
	fi

	if v4l2-ctl --help &>/dev/null; then
	echo -en "${YELLOW}CXM-firmware: ${NORMAL}"; v4l2-ctl --all | egrep -i "card type" | awk '{print $7}'
	elif dmesg | grep "pvc" | grep -q "working with"; then
	echo -en "${YELLOW}CXM-firmware: ${NORMAL}"; dmesg | grep "pvc" | grep "working with" | awk {'print $10'}
	fi

	echo -en "${YELLOW}CPU: ${NORMAL}"
	CPU=`cat /proc/cpuinfo 2>/dev/null | grep -iE 'имя|name' | awk -F : '{print $2}' | sed 's/ *//' | uniq`
		if [[ -z $CPU ]]; then echo -en "[${RED}Not found${NORMAL}]\n"
		else echo "$CPU"
		fi
	
	echo -en "${YELLOW}TurboBoost: ${NORMAL}"
	TurboBoost=`cat /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null`
		if [[ -z $TurboBoost ]]; then echo -en "[${RED}Not found${NORMAL}]\n"
		elif [[ $TurboBoost == 0 ]]; then echo "ON"
                elif [[ $TurboBoost == 1 ]]; then echo "OFF"
		fi

	echo -en "${BLUE}*** RAM ***${NORMAL}\n"
	if dmidecode --help &>/dev/null; then Memory=`dmidecode -t 17 2>/dev/null | grep -iE 'size|разм' | egrep -i 'GB|MB|KB' | sed 's/\t*//'`
		if [[ -z $Memory ]]; then echo -en "[${RED}Not found${NORMAL}]\n"
		else echo "$Memory"
		fi
	else echo -en "[${RED}dmidecode - Not installed${NORMAL}]\n"
	fi

	echo -en "${BLUE}*** ROM *** ${NORMAL}\n"
	if lshw --help &>/dev/null; then SSD=`lshw -c disk 2>/dev/null | grep -E 'produ|проду|size:|размер:' | sed 's/ *//' | uniq`
		if [[ -z $SSD ]]; then echo -en "Model and size: [${RED}Not found${NORMAL}]\n"
		else echo "$SSD"
		fi
	else echo -en "[${RED}lshw - Not installed${NORMAL}]\n"
	fi

	echo -en "SATA-speed: "
	SATAspeed=`cat /sys/class/ata_link/link*/sata_spd 2>/dev/null | grep 'Gbps'`
	if [[ -z $SATAspeed ]]; then echo -en "[${RED}Not found${NORMAL}]\n"
	else echo "$SATAspeed"
	fi

	echo -en "${BLUE}*** UDKA ***${NORMAL}\n"
	udka=`lsusb 2>/dev/null | grep -E '276c:0004|276c:0009' | awk '{print $6}'`
	if [[ -z $udka ]]; then echo -en "[${RED}Not found${NORMAL}]\n"
	else echo -en "${YELLOW}ID:${NORMAL} "$udka"\n"
		config=`lsusb -v -d "$udka" 2>/dev/null | grep -i iSerial | awk /Embedded/'{print $6}'`
		if [[ -z $config ]]; then config=`lsusb -v -d "$udka" 2>/dev/null | grep -i iSerial | awk '{print $3}'`
		fi
		echo -en "${YELLOW}Config:${NORMAL} "$config"\n"
		versionold=`lsusb -v -d "$udka" 2>/dev/null | grep iProdu | awk '{print $3}'`
		echo -en "${YELLOW}Old style version:${NORMAL} "$versionold"\n"
		versionnew=`lsusb -v -d "$udka" 2>/dev/null | grep -i bcdDevice | awk '{print $2}'`
		echo -en "${YELLOW}New style version:${NORMAL} "$versionnew"\n"
	fi
	if lsusb 2>/dev/null | grep -q "276c:000b"; then
		MTT=`lsusb 2>/dev/null | grep -E '276c:000b' | awk '{print $6}'`
		echo -en "${YELLOW}ID:${NORMAL} "$MTT"\n"
		config=`lsusb -v -d "$MTT" 2>/dev/null | grep -i iSerial | awk '{print $3}'`
		echo -en "${YELLOW}Config:${NORMAL} "$config"\n"
		versionold=`lsusb -v -d "$MTT" 2>/dev/null | grep iProdu | awk '{print $3}'`
		echo -en "${YELLOW}Old style version:${NORMAL} "$versionold"\n"
		versionnew=`lsusb -v -d "$MTT" 2>/dev/null | grep -i bcdDevice | awk '{print $2}'`
		echo -en "${YELLOW}New style version:${NORMAL} "$versionnew"\n"
	fi
	if lsusb 2>/dev/null | grep -q "276c:0005"; then
		External_UDKA=`lsusb 2>/dev/null | grep -E '276c:0005' | awk '{print $6}'`
		echo -en "${YELLOW}ID:${NORMAL} "$External_UDKA"\n"
		config=`lsusb -v -d "$External_UDKA" 2>/dev/null | grep -i iSerial | awk '{print $3}'`
		echo -en "${YELLOW}Config:${NORMAL} "$config"\n"
		versionold=`lsusb -v -d "$External_UDKA" 2>/dev/null | grep iProdu | awk '{print $3}'`
		echo -en "${YELLOW}Old style version:${NORMAL} "$versionold"\n"
		versionnew=`lsusb -v -d "$External_UDKA" 2>/dev/null | grep -i bcdDevice | awk '{print $2}'`
		echo -en "${YELLOW}New style version:${NORMAL} "$versionnew"\n"
	fi

	if lspci | grep -qi i210; then echo -en "${BLUE}*** I210 ***${NORMAL}\n"; lspci 2>/dev/null | grep -i i210
	fi

#	echo -en "Press <Enter> to see ID I350..."; read A
	echo -en "${BLUE}*** ID-I350 ***${NORMAL}\n"
	show_id_i350

	echo -en "Press <Enter> to see active displays..."; read A
	if xrandr --help &>/dev/null; then DISPLAY=:0 xrandr 2>/dev/null
	else echo -en "[${RED}xrandr - Not installed${NORMAL}]\n"
	fi
}

set_volume_UDKA() { # Thanks to Alexey Vasiliev
	# Устанавливаем уровень громкости/чувствительности интерфейсов UDKA:
	amixer -c $card -qM set Mic "$UDKA_Mic"% &>/dev/null
	amixer -c $card -qM set Headset "$UDKA_Headset"% &>/dev/null
	amixer -c $card -qM set PCM "$UDKA_PCM"% &>/dev/null
	amixer -c $card -qM set Speaker "$UDKA_Speaker"% &>/dev/null
	amixer -c $camera -qM set Mic "$CAMERA_Mic"% &>/dev/null
}

set_volume_granat4k_output() {
	# Устанавливаем уровень громкости/чувствительности интерфейсов UDKA для Граната 4К:
	amixer -c $card -qM set Mic "$BAL_OUTPUT"% &>/dev/null
	amixer -c $card -qM set Headset "$BAL_OUTPUT"% &>/dev/null
	amixer -c $card -qM set PCM "$BAL_OUTPUT"% &>/dev/null
	amixer -c $card -qM set Speaker "$BAL_OUTPUT"% &>/dev/null
	amixer -c $card -qM set Balanced "$BAL_OUTPUT"% &>/dev/null
}

set_volume_granat4k_input() {
	# Устанавливаем уровень громкости/чувствительности интерфейсов UDKA для Граната 4К:
	amixer -c $card -qM set Mic "$BAL_INPUT"% &>/dev/null
	amixer -c $card -qM set Headset "$BAL_INPUT"% &>/dev/null
	amixer -c $card -qM set PCM "$BAL_INPUT"% &>/dev/null
	amixer -c $card -qM set Speaker "$BAL_INPUT"% &>/dev/null
	amixer -c $card -qM set Balanced "$BAL_INPUT"% &>/dev/null
	amixer -c $sound_output_device -qM set Speaker "$volume_sound_output_device"% &>/dev/null
}

prepare_for_audiotest() # Определяем из-под каких пользователя и подсистемы запускать тесты:
{
	# Проверяем, что пакет alsa-utils установлен:
	if arecord --help &>/dev/null; then
		# Определяем из-под какого пользователя будем запускать аудиотесты (для тестов через pasuspender):
		if ps aufx | grep pulse | grep -q protei; then user="protei"; else user="support"; fi

		# Определяем из-под какой подсистемы будем запускать аудиотесты:
		if ls -l /usr/share/pulseaudio/alsa-mixer/profile-sets/ 2>/dev/null | grep -q Embedded; then
			if ps aufx | grep pulse | grep -qE 'protei|support'; then audiotest="pasuspender"; else audiotest="alsa"; fi
		else audiotest="alsa"
		fi

		# ${CUNNING} - оптимизируем код, чтобы не дублировать функции для тестов через alsa и pasuspender:
		if [[ "$audiotest" == "pasuspender" ]]; then CUNNING="sudo -u "$user" pasuspender --"; else CUNNING=``; fi
	else echo -en "[${RED}alsa-utils - Not installed${NORMAL}]\n"; return 1
	fi
}

table() # Отладочная таблица. Запускается при ./rapid-test.sh -d после basis_for_the_audio_test()
{
	if [[ -z $audiotest ]]; then return 1; fi
	if [[ "$audiotest" == "alsa" ]]; then usr=`whoami`; else usr="$user"; fi
	echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Тесты запустятся через "$audiotest" из-под "$usr""
	echo " ID UDKA: 	"$udka"
 Номер UDKA:	"$card"
 Конфиг UDKA:	"$configudka"
 Соответствие интерфейса и порядкового номера из arecord/aplay:
  ====================================================================================
 |       | Трубка | Гарнитура | Балансный | Встроенный | Левая трубка | Правая Трубка |
 |-------|--------|-----------|-----------|------------|--------------|---------------|
 | Вход  |   "$handsetin"    |     "$jackin"     |     "$xlrin"     |     "$speakerin"      |      "$left_h_in"       |       "$right_h_in"       |
 |-------|--------|-----------|-----------|------------|--------------|---------------|
 | Выход |   "$handsetout"    |     "$jackout"     |     "$xlrout"     |     "$speakerout"      |      "$left_h_out"       |       "$right_h_out"       |
  ===================================================================================="
	echo "Меню: 
"${menu[@]}""
}

table_4k() # Отладочная таблица Гранат-4К. Запускается при ./rapid-test.sh -g после basis_for_the_audio_test()
{
	if [[ -z $audiotest ]]; then return 1; fi
	if [[ "$audiotest" == "alsa" ]]; then usr=`whoami`; else usr="$user"; fi
	echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Тесты запустятся через "$audiotest" из-под "$usr""
	echo " ID UDKA: 	"$udka"
 Номер UDKA:	"$card"
 Конфиг UDKA:	"$configudka"
 Соответствие интерфейса и порядкового номера из arecord/aplay:
  ===============================================================
 |       | Балансный 0 | Балансный 1 | Балансный 2 | Балансный 3 |
 |-------|-------------|-------------|-------------|-------------|
 | Вход  |      "$balin0"      |      "$balin1"      |      "$balin2"      |      "$balin3"      |
 |-------|-------------|-------------|-------------|-------------|
 | Выход |      "$balout0"      |      "$balout1"      |      "$balout2"      |      "$balout3"      |
  ==============================================================="
	echo "Меню: 
"${menu[@]}""
}

speak() {
	set_volume_UDKA
	${CUNNING} speaker-test -D plughw:"$card","$out" -t w -c 2
}

audio_loop() {
	set_volume_UDKA
	${CUNNING} arecord -D plughw:"$card","$inp" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card",0 -c 2 -V stereo
}

research_unknown_config_udka() # Запускается после unknown_config_udka()
{
	# research_unknown_config_udka - Исследование неизвестного конфига UDKA.
	# В результате формируется файл research_audio.txt с соответствием названия интерфейса на шелкографии и номером интерфейса в списке arecord/aplay.
	# Упрощает процесс добавления нового конфига в аудиотесты
	# Файл research_audio.txt появится в той же директории, в которой находится rapid-test.sh

	out="0"
	inp="0"

	if [[ -z $udka ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Не удалось найти UDKA"; return 1; fi
	echo "Конфиг: ["$configudka"]" >> config_"$configudka".txt
	# Считаем кол-во аудио-входов:
	inputss=`arecord -l 2>/dev/null | grep -icE 'topaz|udka|granat|malahit|embedded'`
	# Считаем кол-во аудио-выходов:
	outputss=`aplay -l 2>/dev/null | grep -icE 'topaz|udka|granat|malahit|embedded'`
	echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Тесты запускаются через "$audiotest""
	echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Обнаружено звуковых входов UDKA:  "$inputss""
	echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Обнаружено звуковых выходов UDKA: "$outputss""

	echo "Выходы:" >> config_"$configudka".txt
	for outputs in `aplay -l 2>/dev/null | grep -iE 'topaz|udka|granat|malahit|embedded' | awk '{print $1}'`
		do speak
		echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Введите название аудио-выхода, который был задействован:"; read outs
		echo -en " "$out" - "$outs"\n" >> config_"$configudka".txt
		let "out = $out + 1"
		done

	echo "Входы:" >> config_"$configudka".txt
	for inputs in `arecord -l 2>/dev/null | grep -iE 'topaz|udka|granat|malahit|embedded' | awk '{print $1}'`
		do audio_loop
		echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Введите название аудио-входа, который был задействован:"; read inps
		echo -en " "$inp" - "$inps"\n" >> config_"$configudka".txt
		let "inp = $inp + 1"
		done

	echo -en "[${BLUE} INFO ${NORMAL}]"; echo " config_"$configudka".txt сформирован и находится в "$way"
Отправьте config_"$configudka".txt в uc.protei.ru пользователю @gajnullin. Он добавит тесты для этого конфига UDKA в rapid-test.sh"
}

actions_for_unknown_config_udka() {
	echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Попробуйте 'sudo ./rapid-test.sh --audio' или 'sudo ./rapid-test.sh --speak'"
}

unknown_config_udka() # Запускается в случае, когда конфиг UDKA отсутствует в функции basis_for_the_audio_test в перечне "case "$configudka" in"
{
	echo -en "[ ${YELLOW}WARN${NORMAL} ]"; echo -n " Неизвестный кофиг UDKA: ["$configudka"]. Запустить research-udka? (Y/n) "; read e
	case "$e" in
		"y" | "Y") research_unknown_config_udka; exit 0;;
		"n" | "N") actions_for_unknown_config_udka;;
		*) research_unknown_config_udka; exit 0;;
		esac
}

# Ниже перечисленны функции для audio_test_menu_actions()
h_h() {
	echo -e "\n ${BLUE}##### Трубка ---------> Трубка #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$handsetin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$handsetout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$handsetin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$handsetout" -c 2 -V stereo
}
xlr_h() {
	echo -e "\n ${BLUE}##### Бал.вх ---------> Трубка #####${NORMAL}"
	set_volume_UDKA; amixer -c "$card" -qM set Balanced "$UDKA_Bal_in"% &>/dev/null
	echo -e "${CUNNING} arecord -D plughw:"$card","$xlrin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$handsetout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$xlrin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$handsetout" -c 2 -V stereo
}
sp_h() {
	echo -e "\n ${BLUE}##### Встр -----------> Трубка #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$speakerin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$handsetout" -c 2 -V stereo" 
	${CUNNING} arecord -D plughw:"$card","$speakerin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$handsetout" -c 2 -V stereo
}
h_xlr() {
	echo -e "\n ${BLUE}##### Трубка -------> Бал.вых. #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$handsetin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$xlrout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$handsetin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$xlrout" -c 2 -V stereo
}
h_sp() {
	echo -e "\n ${BLUE}##### Трубка --------> Динамик #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$handsetin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$speakerout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$handsetin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$speakerout" -c 2 -V stereo
}
h_j() {
	echo -e "\n ${BLUE}##### Трубка -----------> Jack #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$handsetin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$handsetin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo
}
j_j() {
	echo -e "\n ${BLUE}##### Jack -------------> Jack #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$jackin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$jackin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo
}
j_sp() {
	echo -e "\n ${BLUE}##### Jack ----------> Динамик #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$jackin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$speakerout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$jackin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$speakerout" -c 2 -V stereo
}
sp_j() {
	echo -e "\n ${BLUE}##### Встр -------------> Jack #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$speakerin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo"
	amixer -c $card -qM set Speaker "$vstr_mic"% &>/dev/null
	${CUNNING} arecord -D plughw:"$card","$speakerin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo
	amixer -c $card -qM set Speaker "$UDKA_Speaker"% &>/dev/null
}
xlr_j() { 
	echo -e "\n ${BLUE}##### Бал.вх. ----------> Jack #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$xlrin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo"
	amixer -c "$card" -qM set Balanced "$UDKA_Bal_in"% &>/dev/null
	${CUNNING} arecord -D plughw:"$card","$xlrin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo
}
j_xlr() {
	echo -e "\n ${BLUE}##### Jack ---------> Бал.вых. #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$jackin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$xlrout" -c 2 -V stereo"
	amixer -c "$card" -qM set Balanced "$UDKA_Bal_out"% &>/dev/null
	${CUNNING} arecord -D plughw:"$card","$jackin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$xlrout" -c 2 -V stereo
}
j_wav() {
	echo -e "\n ${BLUE}##### Jack --------------- WAV #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} speaker-test -D plughw:"$card","$jackout" -c 2 -t wav"
	${CUNNING} speaker-test -D plughw:"$card","$jackout" -c 2 -t wav
}
sp_wav() {
	echo -e "\n ${BLUE}##### Динамик ------------ WAV #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} speaker-test -D plughw:"$card","$speakerout" -c 2 -t wav"
	${CUNNING} speaker-test -D plughw:"$card","$speakerout" -c 2 -t wav
}
sp_sine() {
	echo -e "\n ${BLUE}##### Динамик ----------- SINE #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} speaker-test -D plughw:"$card","$speakerout" -c 2 -t sine"
	${CUNNING} speaker-test -D plughw:"$card","$speakerout" -c 2 -t sine; amixer -c $card -qM set Speaker 99% &>/dev/null
	${CUNNING} speaker-test -D plughw:"$card","$speakerout" -c 2 -t sine; amixer -c $card -qM set Speaker "$UDKA_Speaker"% &>/dev/null
}
xlr_wav() {
	echo -e "\n ${BLUE}##### Бал.вых. ----------- WAV #####${NORMAL}"
	echo -e "${CUNNING} speaker-test -D plughw:"$card","$xlrout" -c 2 -t wav"
	amixer -c "$card" -qM set Balanced "$UDKA_Bal_out"% &>/dev/null
	${CUNNING} speaker-test -D plughw:"$card","$xlrout" -c 2 -t wav
}
h_wav() {
	echo -e "\n ${BLUE}##### Трубка ------------- WAV #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} speaker-test -D plughw:"$card","$handsetout" -c 2 -t wav"
	${CUNNING} speaker-test -D plughw:"$card","$handsetout" -c 2 -t wav
}
h_sine() {
	echo -e "\n ${BLUE}##### Трубка ------------ SINE #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} speaker-test -D plughw:"$card","$handsetout" -c 2 -t sine"
	${CUNNING} speaker-test -D plughw:"$card","$handsetout" -c 2 -t sine; amixer -c $card -qM set PCM 100% &>/dev/null
	${CUNNING} speaker-test -D plughw:"$card","$handsetout" -c 2 -t sine; amixer -c $card -qM set PCM "$UDKA_PCM"% &>/dev/null
}
left_left() {
	echo -e "\n ${BLUE}##### Левая Трубка ---------> Левая Трубка #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$left_h_in" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$left_h_out" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$left_h_in" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$left_h_out" -c 2 -V stereo
}
right_right() {
	echo -e "\n ${BLUE}##### Правая Трубка ---------> Правая Трубка #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$right_h_in" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$right_h_out" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$right_h_in" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$right_h_out" -c 2 -V stereo
}
left_speaker() {
	echo -e "\n ${BLUE}##### Левая Трубка ---------> Встроенный динамик #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$left_h_in" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$speakerout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$left_h_in" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$speakerout" -c 2 -V stereo
}
right_speaker() {
	echo -e "\n ${BLUE}##### Правая Трубка ---------> Встроенный динамик #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$right_h_in" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$speakerout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$right_h_in" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$speakerout" -c 2 -V stereo
}
speaker_left() {
	echo -e "\n ${BLUE}##### Встроенный микрофон ---------> Левая Трубка #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$speakerin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$left_h_out" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$speakerin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$left_h_out" -c 2 -V stereo
}
speaker_right() {
	echo -e "\n ${BLUE}##### Встроенный микрофон ---------> Правая Трубка #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} arecord -D plughw:"$card","$speakerin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$right_h_out" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$speakerin" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$right_h_out" -c 2 -V stereo
}
left_wav() {
	echo -e "\n ${BLUE}##### Левая Трубка ------------- WAV #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} speaker-test -D plughw:"$card","$left_h_out" -c 2 -t wav"
	amixer -c $card -qM set PCM "$UDKA_left"% &>/dev/null; amixer -c $card -qM set Headset "$UDKA_left"% &>/dev/null
	${CUNNING} speaker-test -D plughw:"$card","$left_h_out" -c 2 -t wav
}
right_wav() {
	echo -e "\n ${BLUE}##### Правая Трубка ------------- WAV #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} speaker-test -D plughw:"$card","$right_h_out" -c 2 -t wav"
	amixer -c $card -qM set PCM "$UDKA_right"% &>/dev/null; amixer -c $card -qM set Headset "$UDKA_right"% &>/dev/null
	${CUNNING} speaker-test -D plughw:"$card","$right_h_out" -c 2 -t wav
}
left_sine() {
	echo -e "\n ${BLUE}##### Левая Трубка ------------ SINE #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} speaker-test -D plughw:"$card","$left_h_out" -c 2 -t sine"
	amixer -c $card -qM set PCM "$UDKA_left"% &>/dev/null; amixer -c $card -qM set Headset "$UDKA_left"% &>/dev/null
	${CUNNING} speaker-test -D plughw:"$card","$left_h_out" -c 2 -t sine; amixer -c $card -qM set PCM 100% &>/dev/null; amixer -c $card -qM set Headset 100% &>/dev/null
	${CUNNING} speaker-test -D plughw:"$card","$left_h_out" -c 2 -t sine; amixer -c $card -qM set PCM "$UDKA_left"% &>/dev/null; amixer -c $card -qM set Headset "$UDKA_left"% &>/dev/null
}
right_sine() {
	echo -e "\n ${BLUE}##### Правая Трубка ------------ SINE #####${NORMAL}"
	set_volume_UDKA
	echo -e "${CUNNING} speaker-test -D plughw:"$card","$right_h_out" -c 2 -t sine"
	amixer -c $card -qM set PCM "$UDKA_right"% &>/dev/null; amixer -c $card -qM set Headset "$UDKA_right"% &>/dev/null
	${CUNNING} speaker-test -D plughw:"$card","$right_h_out" -c 2 -t sine; amixer -c $card -qM set PCM 100% &>/dev/null; amixer -c $card -qM set Headset 100% &>/dev/null
	${CUNNING} speaker-test -D plughw:"$card","$right_h_out" -c 2 -t sine; amixer -c $card -qM set PCM "$UDKA_right"% &>/dev/null; amixer -c $card -qM set Headset "$UDKA_right"% &>/dev/null
}
balout0_wav() {
	echo -e "\n ${BLUE}##### Выход 0 Бал. ------- WAV #####${NORMAL}"
	set_volume_granat4k_output
	echo "${CUNNING} speaker-test -D plughw:"$card","$balout0" -c 2 -t wav"
	${CUNNING} speaker-test -D plughw:"$card","$balout0" -c 2 -t wav
}
balout1_wav() {
	echo -e "\n ${BLUE}##### Выход 1 Бал. ------- WAV #####${NORMAL}"
	set_volume_granat4k_output
	echo -e "${CUNNING} speaker-test -D plughw:"$card","$balout1" -c 2 -t wav"
	${CUNNING} speaker-test -D plughw:"$card","$balout1" -c 2 -t wav
}
balout2_wav() {
	echo -e "\n ${BLUE}##### Выход 2 Бал. ------- WAV #####${NORMAL}"
	set_volume_granat4k_output
	echo -e "${CUNNING} speaker-test -D plughw:"$card","$balout2" -c 2 -t wav"
	${CUNNING} speaker-test -D plughw:"$card","$balout2" -c 2 -t wav
}
balout3_wav() {
	echo -e "\n ${BLUE}##### Выход 3 Бал. ------- WAV #####${NORMAL}"
	set_volume_granat4k_output
	echo -e "${CUNNING} speaker-test -D plughw:"$card","$balout3" -c 2 -t wav"
	${CUNNING} speaker-test -D plughw:"$card","$balout3" -c 2 -t wav
}
balin0_to_sound_output_device() {
	echo -e "\n ${BLUE}##### Вход 0 Бал. ------> USB-гарнитура #####${NORMAL}"
	set_volume_granat4k_input
	echo -e "${CUNNING} arecord -D plughw:"$card","$balin0" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$sound_output_device" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$balin0" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$sound_output_device" -c 2 -V stereo
}
balin1_to_sound_output_device() {
	echo -e "\n ${BLUE}##### Вход 1 Бал. ------> USB-гарнитура #####${NORMAL}"
	set_volume_granat4k_input
	echo -e "${CUNNING} arecord -D plughw:"$card","$balin1" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$sound_output_device" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$balin1" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$sound_output_device" -c 2 -V stereo
}
balin2_to_sound_output_device() {
	echo -e "\n ${BLUE}##### Вход 2 Бал. ------> USB-гарнитура #####${NORMAL}"
	set_volume_granat4k_input
	echo -e "${CUNNING} arecord -D plughw:"$card","$balin2" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$sound_output_device" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$balin2" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$sound_output_device" -c 2 -V stereo
}
balin0_to_sound_output_device() {
	echo -e "\n ${BLUE}##### Вход 0 Бал. ------> USB-гарнитура #####${NORMAL}"
	set_volume_granat4k_input
	echo -e "${CUNNING} arecord -D plughw:"$card","$balin0" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$sound_output_device" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$balin0" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$sound_output_device" -c 2 -V stereo
}
balin2_to_sound_output_device() {
	echo -e "\n ${BLUE}##### Вход 2 Бал. ------> USB-гарнитура #####${NORMAL}"
	set_volume_granat4k_input
	echo -e "${CUNNING} arecord -D plughw:"$card","$balin2" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$sound_output_device" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$balin2" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$sound_output_device" -c 2 -V stereo
}
balin3_to_sound_output_device() {
	echo -e "\n ${BLUE}##### Вход 3 Бал. ------> USB-гарнитура #####${NORMAL}"
	set_volume_granat4k_input
	echo -e "${CUNNING} arecord -D plughw:"$card","$balin3" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$sound_output_device" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$balin3" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$sound_output_device" -c 2 -V stereo
}
cam_j() {
	if [ -z $camera ]; then echo -e "\n ${BLUE}Camera not found${NORMAL}"
	set_volume_UDKA
	else echo -e "\n ${BLUE}##### Camera -----------> Jack #####${NORMAL}"
	echo -e "${CUNNING} arecord -D plughw:"$camera" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$camera" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo
	fi
}
cam_h() {
	if [ -z $camera ]; then echo -e "\n ${BLUE}Camera not found${NORMAL}"
	set_volume_UDKA
	else echo -e "\n ${BLUE}##### Camera ---------> Трубка #####${NORMAL}"
	echo -e "${CUNNING} arecord -D plughw:"$camera" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$handsetout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$camera" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$card","$handsetout" -c 2 -V stereo
	fi
}
hdmi_audio() {
	echo -e "\n ${BLUE}##### HDMI-1 --------- Stereo #####${NORMAL}"
	echo -e "${CUNNING} speaker-test -D plughw:PCH,3 -c 2 -t wav"
	${CUNNING} speaker-test -D plughw:PCH,3 -c 2 -t wav; echo -en "[${BLUE} INFO ${NORMAL}]"; echo -n " Press <Enter>..."; read A
	echo -e " ${BLUE}##### HDMI-2 --------- Stereo #####${NORMAL}"
	echo -e "${CUNNING} speaker-test -D plughw:PCH,7 -c 2 -t wav"
	${CUNNING} speaker-test -D plughw:PCH,7 -c 2 -t wav
}
# Выше перечисленны функции для audio_test_menu_actions()

all_audio_tests() # Запускается, когда мы выбираем пункт "Все" в меню аудиотеста #Thanks to Leonid Timofeev
{
	case "$configudka" in
		"MALAHIT") j_wav; sleep 1; sp_wav; sleep 1; sp_sine; sleep 1; j_j; sleep 1; j_sp; sleep 1; cam_j;;
		"GRANAT") j_wav; sleep 1; j_j; sleep 1; xlr_j; sleep 1; hdmi_audio;;
		"TOPAZ") j_wav; sleep 1; xlr_wav; sleep 1; j_j; sleep 1; xlr_j; sleep 1; j_xlr; sleep 1; hdmi_audio;;
		"A") h_wav; sleep 1; h_sine; sleep 1; sp_wav; sleep 1; sp_sine; sleep 1; h_h; sleep 1; j_wav; sleep 1; j_j; sleep 1; j_sp; sleep 1; cam_h; sleep 1; hdmi_audio;;
		"B") h_wav; sleep 1; h_sine; sleep 1; sp_wav; sleep 1; sp_sine; sleep 1; xlr_wav; sleep 1; h_h; sleep 1; xlr_h; sleep 1; h_xlr; sleep 1; cam_h; sleep 1; hdmi_audio;;
		"D") xlr_wav; sleep 1; j_wav; sleep 1; j_j; sleep 1; xlr_j; sleep 1; j_xlr; sleep 1; hdmi_audio ;;
		"E") sp_wav; sleep 1; sp_sine; sleep 1; xlr_wav; sleep 1; j_wav; sleep 1; j_j; sleep 1; j_sp; sleep 1; xlr_j; sleep 1; j_xlr; sleep 1; cam_j; sleep 1; hdmi_audio;;
		"F") sp_wav; sleep 1; sp_sine; sleep 1; j_wav; sleep 1; j_j; sleep 1; j_sp; sleep 1; xlr_j; sleep 1; cam_j; sleep 1; hdmi_audio;;
		"I") sp_wav; sleep 1; sp_sine; sleep 1; xlr_wav; sleep 1; j_wav; sleep 1; j_j; sleep 1; j_sp; sleep 1; sp_j; sleep 1; xlr_j; sleep 1; j_xlr; sleep 1; cam_j; sleep 1; hdmi_audio;;
		"H") sp_wav; sleep 1; sp_sine; sleep 1; j_wav; sleep 1; j_j; sleep 1; sp_j; sleep 1; j_sp; sleep 1; hdmi_audio;;
		"J") sp_wav; sleep 1; sp_sine; sleep 1; j_wav; sleep 1; j_j; sleep 1; sp_j; sleep 1; j_sp; sleep 1; hdmi_audio;;
		"S") h_wav; sleep 1; h_sine; sleep 1; sp_wav; sleep 1; sp_sine; sleep 1; h_h; sleep 1; j_wav; sleep 1; j_j; sleep 1; cam_j; sleep 1; sp_j; sleep 1; j_sp; sleep 1; hdmi_audio;;
		"L") h_wav; sleep 1; h_sine; sleep 1; sp_wav; sleep 1; sp_sine; sleep 1; xlr_wav; sleep 1; h_h; sleep 1; h_xlr; sleep 1; h_sp; sleep 1; sp_h; sleep 1; xlr_h;;
		"M") h_wav; sleep 1; h_sine; sleep 1; sp_wav; sleep 1; sp_sine; sleep 1; xlr_wav; sleep 1; h_h; sleep 1; h_xlr; sleep 1; h_sp; sleep 1; xlr_h; sleep 1; hdmi_audio;;
		"N") h_wav; sleep 1; h_sine; sleep 1; xlr_wav; sleep 1; h_h; sleep 1; h_xlr; sleep 1; xlr_h; sleep 1; hdmi_audio;;
		"O") left_wav; sleep 1; left_sine; sleep 1; left_left; sleep 1; right_wav; sleep 1; right_sine; sleep 1; right_right; sleep 1; left_speaker; sleep 1; right_speaker; sleep 1; speaker_left; sleep 1; speaker_right;;
		"T") h_wav; sleep 1; h_sine; sleep 1; sp_wav; sleep 1; sp_sine; sleep 1; h_h; sleep 1; h_sp; sleep 1; sp_h; sleep 1; h_j; sleep 1; j_wav; sleep 1; j_j; sleep 1; sp_j; sleep 1; j_sp;;
		"U") h_wav; sleep 1; h_sine; sleep 1; sp_wav; sleep 1; sp_sine; sleep 1; h_h; sleep 1; h_sp; sleep 1; sp_h; sleep 1; h_j; sleep 1; j_wav; sleep 1; j_j; sleep 1; sp_j; sleep 1; j_sp;;
		"R") balout0_wav; sleep 1; balout1_wav; sleep 1; balout2_wav; sleep 1; balin0_balout2; sleep 1; balin1_balout2; sleep 1; balin2_balout2; sleep 1; hdmi_audio;;
		"Q") balout1_wav; sleep 1; balout2_wav; sleep 1; balout3_wav; sleep 1; balin0_balout3; sleep 1; balin2_balout3; sleep 1; balin3_balout3; sleep 1; hdmi_audio;;
		*) echo -en "[${RED}FAILED${NORMAL}]"; echo " Неизвестный кофиг UDKA: ["$configudka"]. Рекомендуется тестировать вручную";;
	esac
}
set_volume_periphery () {
	# Устанавливаем уровень громкости/чувствительности интерфейсов Lazurit и AGAT:
	amixer -c $laz -qM set Mic "$LAZURIT_Mic"% &>/dev/null
	amixer -c $laz -qM set Headset "$LAZURIT_Headset"% &>/dev/null
	amixer -c $laz -qM set PCM "$LAZURIT_PCM"% &>/dev/null
	amixer -c $laz -qM set Speaker "$LAZURIT_Speaker"% &>/dev/null
	amixer -c $agat -qM set Speaker "$AGAT_Speaker"% &>/dev/null
	amixer -c $LAVA -qM set Mic "$LAVA_Mic"% &>/dev/null
}

# Ниже перечисленны функции для lazurit_audio_test()
agat_wav() {
	if [[ -z $agat ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Agat not found"; return 1; fi
	echo -e "\n ${BLUE}##### Agat ------- WAV #####${NORMAL}"
	set_volume_periphery
	echo -e "${CUNNING} speaker-test -D plughw:"$agat" -c 2 -t wav -l 1"
	${CUNNING} speaker-test -D plughw:"$agat" -c 2 -t wav -l 1
}
agat_sine() {
	if [[ -z $agat ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Agat not found"; return 1; fi
	echo -e "\n ${BLUE}##### Agat ------ SINE #####${NORMAL}"
	set_volume_periphery
	echo -e "${CUNNING} speaker-test -D plughw:"$agat" -c 1 -t sine -l 2"
	${CUNNING} speaker-test -D plughw:"$agat" -c 1 -t sine -l 2; amixer -c $agat -qM set Speaker 100% &>/dev/null
	${CUNNING} speaker-test -D plughw:"$agat" -c 1 -t sine -l 2; amixer -c $agat -qM set Speaker "$AGAT_Speaker"% &>/dev/null
}
lj_wav() {
	if [[ -z $laz ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Lazurit not found"; return 1; fi
	echo -e "\n ${BLUE}##### Jack ------- WAV #####${NORMAL}"
	set_volume_periphery
	echo -e "${CUNNING} speaker-test -D plughw:"$laz","$lazjackout" -c 2 -t wav -l 1"
	${CUNNING} speaker-test -D plughw:"$laz","$lazjackout" -c 2 -t wav -l 1
}
lj_lj() {
	if [[ -z $laz ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Lazurit not found"; return 1; fi
	echo -e "\n ${BLUE}##### Jack ------> Jack #####${NORMAL}"
	set_volume_periphery
	echo -e "${CUNNING} arecord -D plughw:"$laz","$lazjackin" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$laz","$lazjackout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$laz","$lazjackin" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$laz","$lazjackout" -c 2 -V stereo
}
vm_lj() {
	if [[ -z $laz ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Lazurit not found"; return 1; fi
	echo -e "\n ${BLUE}##### ВМ   ------> Jack #####${NORMAL}"
	set_volume_periphery
	echo -e "${CUNNING} arecord -D plughw:"$laz","$vm" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$laz","$lazjackout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$laz","$vm" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$laz","$lazjackout" -c 2 -V stereo
}
lj_judka() {
	if [[ -z $laz ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Lazurit not found"; return 1; fi
	echo -e "\n ${BLUE}##### Jack ------> Jack_UDKA #####${NORMAL}"
	set_volume_periphery
	echo -e "${CUNNING} arecord -D plughw:"$laz","$lazjackin" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$laz","$lazjackin" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo
}
vm_judka() {
	if [[ -z $laz ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Lazurit not found"; return 1; fi
	echo -e "\n ${BLUE}##### ВМ --------> Jack_UDKA #####${NORMAL}"
	set_volume_periphery
	echo -e "${CUNNING} arecord -D plughw:"$laz","$vm" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$laz","$vm" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo
}
lxlr1_judka() {
	if [[ -z $laz ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Lazurit not found"; return 1; fi
	echo -e "\n ${BLUE}##### Бал.1 -----> Jack_UDKA #####${NORMAL}"
	set_volume_periphery
	echo -e "${CUNNING} arecord -D plughw:"$laz","$lazxlr1" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$laz","$lazxlr1" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo
}
lxlr2_judka() {
	if [[ -z $laz ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Lazurit not found"; return 1; fi
	echo -e "\n ${BLUE}##### Бал.2 -----> Jack_UDKA #####${NORMAL}"
	set_volume_periphery
	echo -e "${CUNNING} arecord -D plughw:"$laz","$lazxlr2" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$laz","$lazxlr2" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo
}
vm_agat() {
	if [[ -z $agat ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Agat not found"; return 1; fi
	echo -e "\n ${BLUE}##### ВМ ----------> AGAT #####${NORMAL}"
	set_volume_periphery
	echo -e "${CUNNING} arecord -D plughw:"$laz","$vm" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$agat" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$laz","$vm" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$agat" -c 2 -V stereo
}
judka_agat() {
	if [[ -z $agat ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Agat not found"; return 1; fi
	echo -e "\n ${BLUE}##### Jack_UDKA ------> AGAT #####${NORMAL}"
	set_volume_periphery
	echo -e "${CUNNING} arecord -D plughw:"$card","$jackout" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$agat" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$card","$jackout" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$agat" -c 2 -V stereo
}
lavavm_judka() {
	if [[ -z $LAVA ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " LAVA not found"; return 1; fi
	echo -e "\n ${BLUE}##### LAVA -----> Jack_UDKA #####${NORMAL}"
	set_volume_periphery
	echo -e "${CUNNING} arecord -D plughw:"$LAVA","$lavavm" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo"
	${CUNNING} arecord -D plughw:"$LAVA","$lavavm" -f s16_le -r 48000 | ${CUNNING} aplay -D plughw:"$card","$jackout" -c 2 -V stereo
}
# Выше перечисленны функции для lazurit_audio_test()

lazurit_audio_test() # Формирует меню для тестов Лазурита, Агата, LAVA. Запускается после audio_test_menu_actions()
{
	# Вычитываем номер звуковой карты Lazurit:
	laz=`arecord -l 2>/dev/null | grep -iE 'lazurit' | cut -c6 | head -n1`
	if [[ -n $laz ]]; then echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Lazurit found"
	else echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Lazurit not found"
	fi
	# Вычитываем номер звуковой карты AGAT:
	agat=`aplay -l 2>/dev/null | grep -iE 'agat' | cut -c6 | head -n1`
	if [[ -n $agat ]]; then echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Agat found"
	else echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Agat not found"
	fi
	# Вычитываем номер звуковой карты LAVA:
	LAVA=`arecord -l 2>/dev/null | grep -iE 'lava' | cut -c6 | head -n1`
	if [[ -n $LAVA ]]; then echo -en "[${BLUE} INFO ${NORMAL}]"; echo " LAVA found"
	else echo -en "[${BLUE} INFO ${NORMAL}]"; echo " LAVA not found"
	fi

	# Вычитываем конфиг звуковой карты Lazurit:
	configlaz=`cat /sys/class/sound/*/id 2>/dev/null | grep -i lazurit`

	# Формируем пункты меню и корректируем значения переменных в зависимости от кофига Lazurit:
	case "$configlaz" in
	"LazuritV2") menulaz=("Выход" "Restart-pulseaudio" "Jack-WAV" "Jack->Jack" "ВМ->Jack" "ВМ->Agat" "Agat--WAV" "Agat--SINE" "LAVA->Jack_UDKA");\
		lazjackin="1"; vm="0"; lazjackout="1"; lavavm="0";;
	"LazuritV2A") menulaz=("Выход" "Restart-pulseaudio" "ВМ->Jack_UDKA" "ВМ->Agat" "Agat--WAV" "Agat--SINE" "LAVA->Jack_UDKA");\
		lazjackin="-"; vm="0"; lazjackout="-"; lavavm="0";;
	"LazuritV2B") menulaz=("Выход" "Restart-pulseaudio" "ВМ->Jack_UDKA" "Бал.1->Jack_UDKA" "Бал.2->Jack_UDKA" "ВМ->Agat" "Agat--WAV" "Agat--SINE" "LAVA->Jack_UDKA");\
		lazjackin="-"; vm="0"; lazxlr1="1"; lazxlr2="2"; lazjackout="-"; lavavm="0";;
	"LazuritV2C") menulaz=("Выход" "Restart-pulseaudio" "Jack-WAV" "Jack->Jack" "ВМ->Jack" "ВМ->Agat" "Agat--WAV" "Agat--SINE" "LAVA->Jack_UDKA");\
		lazjackin="1"; vm="0"; lazjackout="1"; lavavm="0";;
	*) echo -en "[${YELLOW} WARN ${NORMAL}]"; echo " Неизвестный конфиг Лазурита ["$laz"]";\
		menulaz=("Выход" "Restart-pulseaudio" "LAVA->Jack_UDKA" "Jack_UDKA->Agat" "Agat--WAV" "Agat--SINE"); lavavm="0";;
		esac

	# Описываем действия при выборе пунктов меню:
	PS3='Выберите вход и/или выход для аудиотеста: '
	echo
	select laz_loop in ${menulaz[@]}
	do
		case "$laz_loop" in
		"ВМ->Jack") vm_lj;;
		"Jack-WAV") lj_wav;;
		"ВМ->Agat") vm_agat;;
		"Jack->Jack") lj_lj;;
		"Agat--WAV") agat_wav;;
		"Agat--SINE") agat_sine;;
		"ВМ->Jack_UDKA") vm_judka;;
		"Jack_UDKA->Agat") judka_agat;;
		"LAVA->Jack_UDKA") lavavm_judka;;
		"Бал.1->Jack_UDKA") lxlr1_judka;;
		"Бал.2->Jack_UDKA") lxlr2_judka;;
		"Restart-pulseaudio") if [[ "$audiotest" == "alsa" ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo "Тест работает через alsa"; else killall pulseaudio; sleep 2; fi;;
		"Выход") break;;
		*) echo -en "[${RED}FAILED${NORMAL}]"; echo " Такого варианта нет";;
		esac
	done
}

for_vismut() { # Звуковая петля для Висмута:
	echo -en "[${BLUE} INFO ${NORMAL}] В конфиге UDKA ["$configudka"] не предусмотрен аудиовыход.
         Подключите звуковое устройство с аудиовыходом и нажмите <Enter>..."; read A; clear
	echo -e "\n[${BLUE} INFO ${NORMAL}] Введите номер звуковой карты для вывода звука:\n"
	aplay -l 2>/dev/null | egrep 'card|карта'
	echo -en "\n${YELLOW}card${NORMAL} "
	read c_out; clear; if [[ -z $c_out ]]; then echo -e "[${RED}FAILED${NORMAL}] Пусто\n"; return 2; fi
	echo -e "[${BLUE} INFO ${NORMAL}] Введите номер аудиовыхода для вывода звука:\n"
	aplay -l 2>/dev/null | grep "card "$c_out"|карта "$c_out"" | awk -F , '{print $2}'
	echo -en "\n${YELLOW} device${NORMAL} "
	read d_out; clear; if [[ -z $d_out ]]; then echo -e "[${RED}FAILED${NORMAL}] Пусто\n"; return 2; fi
	echo -e " ${BLUE}##### ${CUNNING} Бал.вх. -----> ${CUNNING} plughw:${YELLOW}"$c_out","$d_out"${BLUE} -c 2 -V stereo #####${NORMAL}"
	${CUNNING} arecord -D plughw:"$card" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$c_out","$d_out" -c 2 -V stereo
}

audioloop_for_any_device() { # Звуковая петля с любого входа на любой выход:

	# Определяем из-под каких пользователя и подсистемы запускать тесты:
	prepare_for_audiotest
	
	echo -e "[${BLUE} INFO ${NORMAL}] Введите ${YELLOW}номер звуковой карты${NORMAL} для захвата звука:"
	echo -e "[${BLUE} INFO ${NORMAL}] Обнаружены следующие звуковые карты с аудиовходами:\n"
	arecord -l 2>/dev/null | egrep 'card|карта'
	echo -en "\n${YELLOW}card${NORMAL} "
	read c_in; clear; if [[ -z $c_in ]]; then echo -e "[${RED}FAILED${NORMAL}] Пусто\n"; return 2; fi
	echo -e "[${BLUE} INFO ${NORMAL}] Введите ${YELLOW}номер входа${NORMAL}, с которого будем захватывать звук:\n"
	arecord -l 2>/dev/null | egrep "card "$c_in"|карта "$c_in"" | awk -F , '{print $2}'
	echo -en "\n${YELLOW} device${NORMAL} "
	read d_in; clear; if [[ -z $d_in ]]; then echo -e "[${RED}FAILED${NORMAL}] Пусто\n"; return 2; fi
	
	echo -e "[${BLUE} INFO ${NORMAL}] Введите ${YELLOW}номер звуковой карты${NORMAL} для вывода звука:"
	echo -e "[${BLUE} INFO ${NORMAL}] Обнаружены следующие звуковые карты с аудиовыходами:\n"
	aplay -l 2>/dev/null | egrep 'card|карта'
	echo -en "\n${YELLOW}card${NORMAL} "
	read c_out; clear; if [[ -z $c_out ]]; then echo -e "[${RED}FAILED${NORMAL}] Пусто\n"; return 2; fi
	echo -e "[${BLUE} INFO ${NORMAL}] Введите ${YELLOW}номер аудиовыхода${NORMAL} для вывода звука:\n"
	aplay -l 2>/dev/null | egrep "card "$c_out"|карта "$c_out"" | awk -F , '{print $2}'
	echo -en "\n${YELLOW} device${NORMAL} "
	read d_out; clear; if [[ -z $d_out ]]; then echo -e "[${RED}FAILED${NORMAL}] Пусто\n"; return 2; fi
	echo -e "${BLUE}${CUNNING} arecord -D plughw:${YELLOW}"$c_in","$d_in"${BLUE} -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:${YELLOW}"$c_out","$d_out"${BLUE} -c 2 -V stereo ${NORMAL}"
	${CUNNING} arecord -D plughw:"$c_in","$d_in" -f s16_le -r 48000 -c 2 | ${CUNNING} aplay -D plughw:"$c_out","$d_out" -c 2 -V stereo
}

speakertest_for_any_device() { # speaker-test для любого выхода:

	# Определяем из-под каких пользователя и подсистемы запускать тесты:
	prepare_for_audiotest

	echo -e "[${BLUE} INFO ${NORMAL}] Введите ${YELLOW}номер звуковой карты${NORMAL} для вывода звука:"
	echo -e "[${BLUE} INFO ${NORMAL}] Обнаружены следующие звуковые карты с аудиовыходами:\n"
	aplay -l 2>/dev/null | egrep 'card|карта'
	echo -en "\n${YELLOW}card${NORMAL} "
	read c_out; clear; if [[ -z $c_out ]]; then echo -e "[${RED}FAILED${NORMAL}] Пусто\n"; return 2; fi
	echo -e "[${BLUE} INFO ${NORMAL}] Введите ${YELLOW}номер аудиовыхода${NORMAL} для вывода звука:\n"
	aplay -l 2>/dev/null | egrep "card "$c_out"|карта "$c_out"" | awk -F , '{print $2}'
	echo -en "\n${YELLOW} device${NORMAL} "
	read d_out; clear; if [[ -z $d_out ]]; then echo -e "[${RED}FAILED${NORMAL}] Пусто\n"; return 2; fi
	echo -e "${BLUE} ${CUNNING} speaker-test -D plughw:${YELLOW}"$c_out","$d_out"${BLUE} -t wav -c 2 ${NORMAL}"
	${CUNNING} speaker-test -D plughw:"$c_out","$d_out" -t wav -c 2; sleep 2
	echo -e "${BLUE}${CUNNING} speaker-test -D plughw:${YELLOW}"$c_out","$d_out"${BLUE} -t sine -c 2 ${NORMAL}"
	${CUNNING} speaker-test -D plughw:"$c_out","$d_out" -t sine -c 2
}

basis_for_the_audio_test() # Основная функция, с которой начинается аудитест
{
	clear
	# Проверяем, что пакет alsa-utils установлен и вычитываем номер микрофона камеры:
	if arecord --help &>/dev/null; then
		camera=`arecord -l 2>/dev/null | grep -iE 'brio|c920' | cut -c6 | head -n1`
		# Вычитываем ID камеры для вывода в информационном сообщении:
		id_camera=`cat /sys/class/sound/card*/id 2>/dev/null | grep -iE 'brio|c920'`
		else echo -en "[${RED}alsa-utils - Not installed${NORMAL}]\n"; return 1
	fi

	if [[ -z $camera ]]; then echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Camera not found"
		else echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Camera "$id_camera" found"
	fi

	# Определяем из-под каких пользователя и подсистемы запускать тесты:
	prepare_for_audiotest

	# Вычитываем номер звуковой карты UDKA:
	card=`arecord -l 2>/dev/null | grep -iE 'topaz|udka|granat|malahit|embedded' | cut -c6 | head -n1`

	# Вычитываем ID UDKA (для вычитывания configudka):
	udka=`lsusb 2>/dev/null | grep -E '276c:0004|276c:0009' | awk '{print $6}'`
	if [[ -z $udka ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Не удалось найти UDKA"; audioloop_for_any_device; return 1; fi

	# Вычитываем конфиг звуковой карты UDKA:
	configudka=`lsusb -v -d "$udka" 2>/dev/null | grep iSerial | awk /Embedded/'{print $6}' | cut -c 4`
	if [[ -z $configudka ]]; then configudka=`lsusb -v -d "$udka" 2>/dev/null | grep iSerial | awk '{print $3}'`; fi

	# Для отладочной таблицы:
	left_h_in=" "; left_h_out=" "; right_h_in=" "; right_h_out=" "
	handsetin=" "; jackin=" "; xlrin=" "; speakerin=" "
	handsetout=" "; jackout=" "; xlrout=" "; speakerout=" "
	balin0=" "; balin1=" ";  balin2=" "; balin3=" "
	balout0=" "; balout1=" "; balout2=" "; balout3=" "

	# Формируем пункты меню и присваиваем значения переменных в зависимости от кофига UDKA:
	case "$configudka" in
    "MALAHIT") menu=("Выход" "Restart-pulseaudio" "Все" "Динамики-WAV" "Динамики-SINE" "Jack-WAV" "Jack->Jack" "Jack->Динамики" "Camera->Jack" "Lazurit/AGAT");\
		jackin=0; jackout=1; speakerout=0;;
    "GRANAT-12C") menu=("Выход" "Restart-pulseaudio" "Все" "Jack-WAV" "Jack->Jack" "Бал.вх.->Jack" "HDMI-WAV" "Lazurit/AGAT");\
		jackin=0; jackout=0; xlrin=1;;
    "TOPAZ") menu=("Выход" "Restart-pulseaudio" "Все" "Бал.вых.-WAV" "Jack-WAV" "Jack->Jack" "Бал.вх.->Jack" "Jack->Бал.вых." "HDMI-WAV" "Lazurit/AGAT");\
		jackin=0; xlrin=1; jackout=0; xlrout=1;; 
    "A") menu=("Выход" "Restart-pulseaudio" "Все" "Трубка-WAV" "Трубка-SINE" "Динамики-WAV" "Динамики-SINE" "Трубка->Трубка" "Camera->Трубка" "Jack-WAV" "Jack->Jack" "Jack->Динамики" "HDMI-WAV" "Lazurit/AGAT");\
		handsetin=0; handsetout=0; jackin=1; jackout=1; speakerout=2;;
    "B") menu=("Выход" "Restart-pulseaudio" "Все" "Трубка-WAV" "Трубка-SINE" "Динамики-WAV" "Динамики-SINE" "Бал.вых.-WAV" "Трубка->Трубка" "Бал.вх.->Трубка" "Трубка->Бал.вых." "Camera->Трубка" "HDMI-WAV" "Lazurit/AGAT");\
		handsetin=0; handsetout=0; xlrin=1; xlrout=1; speakerout=2;;
    "D") menu=("Выход" "Restart-pulseaudio" "Все" "Бал.вых.-WAV" "Jack-WAV" "Jack->Jack" "Бал.вх.->Jack" "Jack->Бал.вых." "HDMI-WAV" "Lazurit/AGAT");\
		jackin=0; xlrin=1; jackout=0; xlrout=1;;
    "E") menu=("Выход" "Restart-pulseaudio" "Все" "Динамики-WAV" "Динамики-SINE" "Бал.вых.-WAV" "Jack-WAV" "Jack->Jack" "Jack->Динамики" "Бал.вх.->Jack" "Jack->Бал.вых." "Camera->Jack" "HDMI-WAV" "Lazurit/AGAT");\
		jackout=0; xlrout=1; speakerout=2; jackin=0; xlrin=1;;
    "F") menu=("Выход" "Restart-pulseaudio" "Все" "Динамики-WAV" "Динамики-SINE" "Jack-WAV" "Jack->Jack" "Jack->Динамики" "Бал.вх.->Jack" "Camera->Jack" "HDMI-WAV" "Lazurit/AGAT");\
		jackout=0; speakerout=1; jackin=0; xlrin=1;;
    "I") menu=("Выход" "Restart-pulseaudio" "Все" "Динамики-WAV" "Динамики-SINE" "Бал.вых.-WAV" "Jack-WAV" "Jack->Jack" "Jack->Динамики" "Встр.мик.->Jack" "Бал.вх.->Jack" "Jack->Бал.вых." "Camera->Jack"\
 "HDMI-WAV" "Lazurit/AGAT");\
		jackout=0; xlrout=1; speakerout=2; jackin=0; xlrin=1; speakerin=2;;
    "H") menu=("Выход" "Restart-pulseaudio" "Все" "Динамики-WAV" "Динамики-SINE" "Jack-WAV" "Jack->Jack" "Встр.мик.->Jack" "Jack->Динамики" "HDMI-WAV" "Lazurit/AGAT");\
		jackout=0; speakerout=1; jackin=0; speakerin=1;;
    "J") menu=("Выход" "Restart-pulseaudio" "Все" "Динамики-WAV" "Динамики-SINE" "Jack-WAV" "Jack->Jack" "Встр.мик.->Jack" "Jack->Динамики" "HDMI-WAV" "Lazurit/AGAT");\
		jackout=0; speakerout=1; jackin=0; speakerin=1;;
    "S") menu=("Выход" "Restart-pulseaudio" "Все" "Трубка-WAV" "Трубка-SINE" "Динамики-WAV" "Динамики-SINE" "Трубка->Трубка" "Jack-WAV" "Jack->Jack" "Camera->Jack" "Встр.мик.->Jack" "Jack->Динамики" "HDMI-WAV" "Lazurit/AGAT");\
		handsetin=1; jackin=0; speakerin=2; handsetout=1; jackout=0; speakerout=2;;
    "L") menu=("Выход" "Restart-pulseaudio" "Все" "Трубка-WAV" "Трубка-SINE" "Динамики-WAV" "Динамики-SINE" "Бал.вых.-WAV" "Трубка->Трубка" "Трубка->Бал.вых." "Трубка->Динамик" "Встр.мик.->Трубка" "Бал.вх.->Трубка"\
 "HDMI-WAV" "Lazurit/AGAT");\
		handsetin=1; xlrin=2; speakerin=3; handsetout=1; xlrout=2; speakerout=3;;
    "M") menu=("Выход" "Restart-pulseaudio" "Все" "Трубка-WAV" "Трубка-SINE" "Динамики-WAV" "Динамики-SINE" "Бал.вых.-WAV" "Трубка->Трубка" "Трубка->Бал.вых." "Трубка->Динамик" "Бал.вх.->Трубка" "HDMI-WAV" "Lazurit/AGAT");\
		handsetin=1; xlrin=2; handsetout=1; xlrout=2; speakerout=3;;
    "N") menu=("Выход" "Restart-pulseaudio" "Все" "Трубка-WAV" "Трубка-SINE" "Бал.вых.-WAV" "Трубка->Трубка" "Трубка->Бал.вых." "Бал.вх.->Трубка" "HDMI-WAV" "Lazurit/AGAT");\
		handsetin=1; xlrin=2; handsetout=1; xlrout=2;;
    "O") menu=("Выход" "Restart-pulseaudio" "Все" "Левая_Трубка-WAV" "Левая_Трубка-SINE" "Правая_Трубка-WAV" "Правая_Трубка-SINE" "Динамики-WAV" "Динамики-SINE" "Левая_Трубка-->Левая_Трубка" "Правая_Трубка-->Правая_Трубка"\
 "Левая_Трубка-->Динамик" "Правая_Трубка-->Динамик" "Встр.мик.-->Правая_Трубка" "Встр.мик.-->Левая_Трубка" "HDMI-WAV");\
		left_h_in=0; left_h_out=0; right_h_in=1; right_h_out=1; speakerin=2; speakerout=2;;
	"T") menu=("Выход" "Restart-pulseaudio" "Все" "Трубка-WAV" "Трубка-SINE" "Динамики-WAV" "Динамики-SINE" "Трубка->Трубка" "Трубка->Динамик" "Встр.мик.->Трубка" "Jack-WAV" "Jack->Jack" "Встр.мик.->Jack" "Jack->Динамики" "Camera->Jack"\
 "HDMI-WAV" "Lazurit/AGAT");\
		jackout=0; handsetout=1; speakerout=2; jackin=0; handsetin=1; speakerin=2;;
	"U") menu=("Выход" "Restart-pulseaudio" "Все" "Трубка-WAV" "Трубка-SINE" "Динамики-WAV" "Динамики-SINE" "Трубка->Трубка" "Трубка->Динамик" "Встр.мик.->Трубка" "Трубка->Jack" "Jack-WAV" "Jack->Jack" "Встр.мик.->Jack" "Jack->Динамики");\
		jackout=2; handsetout=1; speakerout=3; jackin=2; handsetin=1; speakerin=3;;
    "R") menu=("Выход" "Restart-pulseaudio" "Все" "Бал.вых.0--WAV" "Бал.вых.1--WAV" "Бал.вых.2--WAV" "Бал.вх.0-->USB-гарнитура" "Бал.вх.1-->USB-гарнитура" "Бал.вх.2-->USB-гарнитура" "HDMI-WAV");\
		balin0="0"; balout0="0"; balin1="1"; balout1="1"; balin2="2"; balout2="2";;
    "Q") menu=("Выход" "Restart-pulseaudio" "Все" "Бал.вых.1--WAV" "Бал.вых.2--WAV" "Бал.вых.3--WAV" "Бал.вх.0-->USB-гарнитура" "Бал.вх.2-->USB-гарнитура" "Бал.вх.3-->USB-гарнитура" "HDMI-WAV");\
		balin0="2"; balout1="2"; balin2="0"; balout2="0"; balin3="1"; balout3="1";;
	"K") for_vismut; return 1;;
      *) unknown_config_udka;;
    esac
}

audio_test_menu_actions() # Запускается после run_audio_test()
{
	# Описываем действия при выборе пунктов меню:
	PS3='Выберите вход и/или выход для аудиотеста: '
	echo
    select loop in ${menu[@]}
	do
		case "$loop" in
		"Все") all_audio_tests;;
		"Jack-WAV") j_wav;;
		"Jack->Jack") j_j;;
		"Трубка-WAV") h_wav;;
		"Трубка-SINE") h_sine;;
		"Трубка->Jack") h_j;;
		"Трубка->Трубка") h_h;;
		"Camera->Jack") cam_j;;
		"Jack->Динамики") j_sp;;
		"Бал.вх.->Jack") xlr_j;;
		"Jack->Бал.вых.")j_xlr;;
		"Динамики-WAV") sp_wav;;
		"HDMI-WAV") hdmi_audio;;
		"Трубка->Динамик") h_sp;;
		"Встр.мик.->Jack") sp_j;;
		"Бал.вых.-WAV") xlr_wav;;
		"Camera->Трубка") cam_h;;
		"Бал.вх.->Трубка") xlr_h;;
		"Трубка->Бал.вых.") h_xlr;;
		"Динамики-SINE") sp_sine;;
		"Встр.мик.->Трубка") sp_h;;
		"Lazurit/AGAT") lazurit_audio_test;;
		"Левая_Трубка-WAV") left_wav;;
		"Левая_Трубка-SINE") left_sine;;
		"Правая_Трубка-WAV") right_wav;;
		"Правая_Трубка-SINE") right_sine;;
		"Левая_Трубка-->Динамик") left_speaker;;
		"Правая_Трубка-->Динамик") right_speaker;;
		"Встр.мик.-->Левая_Трубка") speaker_left;;
		"Встр.мик.-->Правая_Трубка") speaker_right;;
		"Левая_Трубка-->Левая_Трубка") left_left;;
		"Правая_Трубка-->Правая_Трубка") right_right;;
		"Бал.вых.0--WAV") balout0_wav;;
		"Бал.вых.1--WAV") balout1_wav;;
		"Бал.вых.2--WAV") balout2_wav;;
		"Бал.вых.3--WAV") balout3_wav;;
		"Бал.вх.0-->USB-гарнитура") balin0_to_sound_output_device;;
		"Бал.вх.1-->USB-гарнитура") balin1_to_sound_output_device;;
		"Бал.вх.2-->USB-гарнитура") balin2_to_sound_output_device;;
		"Бал.вх.0-->USB-гарнитура") balin0_to_sound_output_device;;
		"Бал.вх.2-->USB-гарнитура") balin2_to_sound_output_device;;
		"Бал.вх.3-->USB-гарнитура") balin3_to_sound_output_device;;
		"Restart-pulseaudio") if [[ "$audiotest" == "alsa" ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo "Тест работает через alsa"; else killall pulseaudio; sleep 2; fi;;
		"Выход") PS3='Select test: '; break;;
		*) echo -en "[${RED}FAILED${NORMAL}]"; echo " Такого варианта нет";;
		esac
    done
}

run_audio_test() # Запускается сразу после basis_for_the_audio_test() и запускает аудиотесты
{
	if [[ $? == 1 ]]; then PS3='Select test: '; return 1; fi
	if [[ -z $audiotest ]]; then PS3='Select test: '; return 1; fi
	echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Тесты запускаются через "$audiotest""; audio_test_menu_actions
}

backlight_test() # Крутим яркость дисплея. Запускается после search_backlight_control()  #Thanks to Boris Misliwsky 
{
	if [[ -z $light ]]; then echo -en "[${RED}FAILED${NORMAL}]"; echo " Can not set brightness on this device"; return 1; fi
	let "max_b = $max_b - 1" # На всякий случай берём значение на 1 меньше, чем максимальное
	let "step_b = $max_b / 10" # Считаем шаг для изменения яркости в цикле "for ((i=0;i<=$max_b;i=i+$step_b))"
	echo -en "[${BLUE} INFO ${NORMAL}] Даже если экран погаснет, продолжайте нажимать <Enter>
[${BLUE} INFO ${NORMAL}] Even if the screen goes blank, keep pressing <Enter>"; read A
	for ((j=1; j<=2 ;j++))
		do
		for ((i=0;i<=$max_b;i=i+$max_b));
		do
			echo $i > "$light"
			echo -en "[${BLUE} INFO ${NORMAL}] Current brightness $i; Press <Enter>"
			read A
		done
	done
	for ((j=1; j<=1; j++))
		do
		for ((i=0;i<=$max_b;i=i+$step_b));
			do
			echo $i > "$light"
			echo -en "[${BLUE} INFO ${NORMAL}] Current brightness $i; Press <Enter>"
			read A
		done
    done
}

search_backlight_control() # Ищем путь до файла с текущим значением уровня яркости и максимальным значением уровня яркости
{
	clear
	if [[ -e /sys/class/backlight/acpi_video0/brightness ]]; then light="/sys/class/backlight/acpi_video0/brightness"
	max_b=`cat /sys/class/backlight/acpi_video0/max_brightness`; backlight_test
		elif [[ -e /sys/class/backlight/ptn3460_backlight/brightness ]]; then light="/sys/class/backlight/ptn3460_backlight/brightness"
		max_b=`cat /sys/class/backlight/ptn3460_backlight/max_brightness`; backlight_test
			elif [[ -e /sys/class/backlight/intel_backlight/brightness ]]; then light="/sys/class/backlight/intel_backlight/brightness"
			max_b=`cat /sys/class/backlight/intel_backlight/max_brightness`; backlight_test
	else echo -en "[${RED}FAILED${NORMAL}]"; echo " Can not set brightness on this device"; return 1
	fi
}

link_test() # Запускается после выбора пункта Eth-Indication в основном меню
{
	clear
	# Проверяем, что ethtool установлен:
	if ethtool -h &>/dev/null; then echo -en "[${GREEN}  OK  ${NORMAL}]"; echo " ethtool found"
		else echo -en "[${RED}FAILED${NORMAL}]"; echo " ethtool not installed"; PS3='Select test: '; return 1
	fi

	# Проверяем, что brctl установлен:
	if brctl show &>/dev/null; then
		# Проверяем, что есть бридж LAN и удаляем из него все интерфейсы:
		if brctl show | grep -q LAN; then echo -en "[${BLUE} INFO ${NORMAL}]"; echo " All interfaces would be deleted from LAN. Press <Enter> to continue..."; brctl show; read A
			# Бэкапим список интерфейсов в бридже и устанавливаем флаг для дальнейшего восстановления бриджа:
			brctl show > LAN_bridge; check_br=1
			# Вычисляем первый интерфейс в бридже:
			eth=`brctl show | awk '{print $4}' | head -n 2 | tail -n 1`
			# Считаем количество интерфейсов в бридже и формируем счётчик:
			bcount=`brctl show | awk '{print $4}' | wc -l`; bcount=($bcount - 2)
			# Убираем все интерфейсы из бриджа кроме первого:
			brctl show | awk '{print $1}' | tail -n "$bcount" | while read b; do brctl delif LAN "$b"&>/dev/null; done
			# Убираем первый интерфейс из бриджа:
			brctl delif LAN "$eth"&>/dev/null; clear; brctl show
		else echo -en "[${BLUE} INFO ${NORMAL}]"; echo " LAN-bridge not found"
		fi
	else echo -en "[${RED}FAILED${NORMAL}]"; echo " brctl not installed"; PS3='Select test: '; return 1
	fi
	# Начинаем тест:
	echo -en "[${BLUE} INFO ${NORMAL}]"; echo -n " Connect the ethernet interfaces with loops and press <Enter>..."; read A; clear
	ip a | grep mtu | grep -iE 'eth|ge|enp' | awk '{print $2}' | tr -d ':' | while read c; do ethtool -s "$c" speed 10 duplex full; echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Set "$c""; sleep 3; done
	clear; dmesg -T 2>/dev/null | grep "10 Mbps"; echo -en "[ ${GREEN}CHECK${NORMAL} ]"; echo -n " Current speed is 10Mb/s. Check indication, check dmesg and press <Enter>..."; read A; clear
	ip a | grep mtu | grep -iE 'eth|ge|enp' | awk '{print $2}' | tr -d ':' | while read c; do ethtool -s "$c" speed 100 duplex full; echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Set "$c""; sleep 3; done
	clear; dmesg -T 2>/dev/null | grep "100 Mbps"; echo -en "[ ${GREEN}CHECK${NORMAL} ]"; echo -n " Current speed is 100Mb/s. Check indication, check dmesg and press <Enter>..."; read A; clear
	ip a | grep mtu | grep -iE 'eth|ge|enp' | awk '{print $2}' | tr -d ':' | while read c; do ethtool -s "$c"  autoneg on; echo -en "[${BLUE} INFO ${NORMAL}]"; echo " Set "$c""; sleep 1; done; sleep 3
	clear; dmesg -T 2>/dev/null | grep "1000 Mbps"; echo -en "[ ${GREEN}CHECK${NORMAL} ]"; echo -n " Current speed is 1000Mb/s. Check indication, check dmesg and press <Enter>..."; read A; clear
		# Проверяем флаг для восстановления бриджа:
		if [[ -n $check_br ]]; then echo -en "[${BLUE} INFO ${NORMAL}]"; echo -n " LAN-bridge will be restored. Disconnect the ethernet loops and press <Enter>..."; read A; clear
			# Возвращаем все интерфейсы в бридж кроме первого:
			cat LAN_bridge | awk '{print $1}' | tail -n "$bcount" | while read d; do brctl addif LAN "$d"&>/dev/null; done
			# Возвращаем первый интерфейс в бридж:
			brctl addif LAN "$eth"&>/dev/null; clear; brctl show; rm LAN_bridge
		fi
	echo -en "[${GREEN} DONE ${NORMAL}]"; echo " Test completed."
}

statistic_after_load() {
	clear
	echo "-----------------------------------------------------------------------------------------
UPTIME:"
	uptime -p
	echo "-----------------------------------------------------------------------------------------"
	sensors
	echo "Temperature i350:"
	cat /sys/class/hwmon/hwmon*/device/temp*_input 2>/dev/null | while read t; do let "t=$t/1000"; echo ""$t"°C"; done
	echo
	echo -n "-----------------------------------------------------------------------------------------
Press <Enter>..."; read A; clear
	echo "ifconfig -s"
	ifconfig -s
	echo -n "Press <Enter>..."; read A; clear
	echo "dmesg -T | egrep --color 'NIC|SATA|EDKA'"
	dmesg -T | egrep --color 'NIC|SATA|EDKA'
	echo -n "Press <Enter>..."; read A; clear
	echo "dmesg -T"
	dmesg -T
}

lcd_test2 () # Thanks to Boris Misliwsky
{
	clear
    echo -n "Menu: "
    echo  "Press q to exit"
    echo  "Press x to grid"
    echo  "Press w to white"
    echo  "Press k to black"
    echo  "Press g to green"
    echo  "Press r to red"
    echo  "Press b to blue"
    echo  "Press y to yellow"
    read menu

    j=0

    while [ $j -le 1 ]
    do
    case $menu in

      q)
        clear
        setterm -foreground white -background black
        echo -n ""
        j=2
        ;;
      x)
        clear
        setterm -foreground white -background black
        for ((i=0;i<90000;i++))
        do
            printf "|¯_¯|"
        done
        read menu
        clear
        setterm -foreground white -background black
        ;;
      w)
        clear
        setterm -foreground white -background black
        echo -e "[${BLUE} INFO ${NORMAL}] Press any key to set white"
        read A
        setterm -foreground white -background white
        clear
        read menu
        clear
        setterm -foreground white -background black
        ;;
      k)
        clear
        setterm -foreground white -background black
        echo -e "[${BLUE} INFO ${NORMAL}] Press any key to set black"
        read A
        setterm -foreground black -background black
        clear
        read menu
        clear
        setterm -foreground white -background black
        ;;
      r)
        clear
        setterm -foreground white -background black
        echo -e "[${BLUE} INFO ${NORMAL}] Press any key to set red"
        read A
        setterm -foreground red -background red
        clear
        read menu
        clear
        setterm -foreground white -background black
        ;;
      b)
        clear
        setterm -foreground white -background black
        echo -e "[${BLUE} INFO ${NORMAL}] Press any key to set blue"
        read A
        setterm -foreground blue -background blue
        clear
        read menu
        clear
        setterm -foreground white -background black
        ;;
      y)
        clear
        setterm -foreground white -background black
        echo -e "[${BLUE} INFO ${NORMAL}] Press any key to set yellow"
        read A
        setterm -foreground yellow -background yellow
        clear
        read menu
        clear
        setterm -foreground white -background black
        ;;
      g)
        clear
        setterm -foreground white -background black
        echo -e "[${BLUE} INFO ${NORMAL}] Press any key to set green"
        read A
        setterm -foreground green -background green
        clear
        read menu
        clear
        setterm -foreground white -background black
        ;;
      *)
        clear
        setterm -foreground white -background black
        echo  "Unknown key"
        echo  "Menu: "
        echo  "Press q to exit"
        echo  "Press x to grid"
        echo  "Press w to white"
        echo  "Press k to black"
        echo  "Press g to green"
        echo  "Press r to red"
        echo  "Press b to blue"
        echo  "Press y to yellow"
        read menu
        ;;
esac
done
}

usb_for_rapid () { # Thanks to Vladimir Leshchenko

LIGHT_CYAN='\033[1;36m'
YELLOW1='\033[1;33m'
GREEN1='\033[0;32m'
RED1='\033[0;31m'


# Бесконечный цикл, запускающий функцию check_connection

function usb_start {
	clear
	do_usb_check=1
	while [ $do_usb_check == 1 ]
	do
	clear
	trap "do_usb_check=0" SIGINT # trap для перехвата кода "Ctrl+C", чтобы выйти из бесконечного цикла, а не из скрипта
	check_connection; sleep 1
	done

}

# Опредение наличия подключения USB Flash
# Если подключение есть - запустится функция "how_connection" для определения количества подключений

function check_connection {
	echo -e "Use 'Ctrl+C' for exit\n"
	usb_connect_check=`lsusb -t | grep usb-storage`
	if [[ -n $usb_connect_check ]]
	then how_connection
	else echo -e "${RED1}Usb Flash not found${NORMAL}"
	fi
}

# Определяет количество подключенных USB Flash
# На основании этого определяется сколько раз запустится функция "usb_speed", вычивающая скорость подключенных USB

function how_connection {
	kolv=`lsusb -t | grep usb-storage | awk '{print $3}' | cut -c1 | wc -l` # вычитываем количество подключенных USB Flash
	raz=0 # переменная, меняющаяся в зависимости от количества подключенных USB Flash, на ее основании решается скорость какого именно USB устройства вычитывать
	for ((i=1;i<15;i++)) 
	do
	raz=$((raz + 1))
	usb_speed
	if [[ i -eq $kolv ]]
	then break
	elif [[ $do_usb_check == 0 ]]
	then break
	fi
	done
}

# Опеределие скорости подключенного USB Flash

function usb_speed {
	usb_port=`lsusb -t | grep usb-storage | awk '{print $3}' | cut -c1 | tail -n $raz | head -1`
	echo "USB port: $usb_port"
	usb_speed=`lsusb -t | grep usb-storage | awk '{print $11}' | tail -n $raz | head -1`;
	date_connection=`dmesg -T | grep "usb.*new.*number" | tail -n 1 | awk '{print $1,$2,$3,$4,$5}'`
	    if [[ $usb_speed == "5000M" ]]; then 
	        echo -e "${LIGHT_CYAN}USB-type:${NORMAL}  ${GREEN1}USB 3.0 (Super-Speed)${NORMAL}\n"
	    elif [[ $usb_speed == "480M" ]]; then 
	        echo -e "${LIGHT_CYAN}USB-type:${NORMAL}  ${YELLOW1}USB 2.0 (High-Speed)${NORMAL}\n"
	    elif [[ $usb_speed == "12M" ]]; then 
	        echo -e "${LIGHT_CYAN}USB-type:${NORMAL}  ${YELLOW1}USB 1.0 (Low-Speed)${NORMAL}\n"
	    fi
}

# Тело скрипта

	usb_start
	trap SIGINT # возвращаем "Ctrl+C" сигнал выхода из скрипта

}

reference() # Справка. Выводится при вводе невереного параметра или -h
{
	echo -e ${GREEN}"$VER"${NORMAL}
	echo -e " Предназначен для проверки основных функциональных возможностей и комплектности устройств.
 Необходимо запускать с правами суперпользователя sudo.
 Для повторного вывода меню нажмите <Enter>.
 Часть информационных сообщений переведена на английский язык для корректного отображения при отсутствии кодировки для русского языка.
 После запуска скрипта выводится меню со следующими пунктами:
 
 1) Hardware-Info        - информация по железу
 2) Software-Info        - информация по BIOS, софту, драйверам
 3) Audio-test           - тест UDKA. Если UDKA отсутствует, предлагается вручную выбрать вход и выход
    Configs: "$configs_supported"
    Devices: LazuritV2, LazuritV2A, LazuritV2B, LazuritV2C, Agat, LAVA
 4) Backlight            - работа экрана на разных уровнях яркости (для устройств со встроенным дисплеем)
 5) Eth-Indication       - проверка индикации сетевых интерфейсов (10Mb/s, 100Mb/s, 1000Mb/s)
 6) Lcd-test             - Lcd-test для консоли
 7) USB-test             - показывает скорость подключенного USB-устройства
 8) Statistic_after_load - показать статистику после нагрузочного теста (uptime, sensors, temp_i350, ifconfig, dmesg)
 9) Exit                 - выход
 10) Help                 - справка

 Options:
 -1	show Hardware-Info
 -2	show Software-Info
 -3	run Audio-test
 -4	run Backlight
 -5	run Eth-Indication
 -6	run Lcd-test for console
 -7	run USB-test
 -v	show version
 -d	checking audio-test variables
 -g	checking audio-test variables for Granat-4K
 -i	show id i350
 -s	show statistic after load-test
 -h	print this help and exit
 
 --upgrade   upgrade rapid-test.sh
 --audio     audioloop between selected input and output interfaces
 --speak     speaker-test for selected device
 
 -- С вопросами и предложениями обращайтесь в uc.protei.ru к @gajnullin --"
}

upgrade() # Обновление rapid-test.sh по сети. Необходим доступ до cloud.protei.ru #Thanks to Boris Misliwsky 
{
	# Бэкапим:
	cp -a rapid-test.sh rapid-test-backup.sh
	# Скачиваем версию из cloud.protei.ru:
	curl https://cloud.protei.ru/s/0fex7lxRSy3sbwQ/download > rapid-test.sh
	# Вычитываем версию скачанного скрипта:
	v=`head -n 3 rapid-test.sh | grep VER | cut -c 6-16`
	# Если поле с версией пусто, то возвращаем из бэкапа. Если всё ОК, то удаляем бэкап:
	if [[ -z $v ]]; then
		mv rapid-test-backup.sh rapid-test.sh; echo -e "[${RED}FAILED${NORMAL}] Что-то пошло не так, проверьте настройки сети"
		else rm rapid-test-backup.sh
		echo -e "[${GREEN}UPDATED${NORMAL}] rapid-test.sh обновлён с "$VER" до "$v""
	fi
}

# ТЕЛО СКРИПТА rapid-test.sh:

configs_supported="MALAHIT, GRANAT-12С, TOPAZ, A, B, D, E, F, H, I, J, K, L, M, N, O, T, Q, R, S, U"
BLUE='\033[36m'     # [${BLUE} INFO ${NORMAL}]
GREEN='\033[0;32m'  # [${GREEN}  OK  ${NORMAL}]
RED='\033[0;31m'    # [${RED}FAILED${NORMAL}]
YELLOW='\033[0;33m' # [${YELLOW} WARN ${NORMAL}]
NORMAL='\033[0m'

cd `dirname $0` # Переходим в директорию с rapid-test.sh. Необходимо для upgrade() и research-udka()
way=`pwd` # Задействован в research-udka()
usr=`whoami`; if [[ "$usr" != "root" ]]; then echo -e "[${RED}FAILED${NORMAL}] Use: sudo ./rapid-test.sh"; exit 1; fi

if [[ -n $1 ]]; then
    case "$1" in
    "-1" | "1") show_hardware; exit 0;;
    "-2" | "2") show_software; exit 0;;
    "-3" | "3") basis_for_the_audio_test; run_audio_test; exit 0;;
    "-4" | "4") search_backlight_control; exit 0;;
    "-5" | "5") link_test; exit 0;;
    "-6" | "6") lcd_test2; exit 0;;
    "-7" | "7") usb_for_rapid; exit 0;;
    "-i" | "i") show_id_i350; exit 0;;
    "-v" | "v") echo -e "\n"$VER"\n"; exit 0;;
    "-d" | "d") basis_for_the_audio_test; table; exit 0;;
    "-g" | "g") basis_for_the_audio_test; table_4k; exit 0;;
    "-s" | "s") statistic_after_load; exit 0;;
    "-h" | "h" | "--help") reference; exit 0;;
    "--upgrade") upgrade; exit 0;;
	"--audio") clear; audioloop_for_any_device; exit 0;;
	"--speak") clear; speakertest_for_any_device; exit 0;;
    *) echo -e "[${RED}FAILED${NORMAL}] rapid-test: Unkown option "$1""; reference; exit 0;;
    esac
fi

# Формируем основное меню для rapid-test.sh и описываем действия при выборе пунктов меню:
clear
PS3='Select test: '
select te in "Hardware-Info" "Software-Info" "Audio-test" "Backlight" "Eth-Indication" "Lcd-test" "USB-test" "Statistic_after_load" "Exit" "Help"
    do
    case "$te" in
		"Hardware-Info") show_hardware;;
		"Software-Info") show_software;;
		"Audio-test") basis_for_the_audio_test; run_audio_test;;
		"Backlight") search_backlight_control;;
		"Eth-Indication") link_test;;
		"Lcd-test") lcd_test2;;
		"USB-test") usb_for_rapid;;
		"Help") reference;;
		"Statistic_after_load") statistic_after_load; exit 0;;
		"Exit") break;;
		*) echo -en "[${RED}FAILED${NORMAL}] Item not found. Please try again\n";;
	esac
    done
exit 0

