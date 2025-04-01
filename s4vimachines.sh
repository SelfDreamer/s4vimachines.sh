#!/bin/bash

ruta=$(realpath $0 | rev | cut -d'/' -f2- | rev)
cd $ruta
# Colors
source Colors.sh

# Variables globales
export url='https://infosecmachines.io/api/machines'
PATH_ARCHIVE='/tmp/bundle.js'
TMP_ARCHIVE='/tmp/bundle.js.tmp'
declare -i parameter_counter=0
verbose_mode=false
confirm_act=false
help=false
results="/tmp/results.tmp"
htb_results="/tmp/htb_results"
vulnhub_results="/tmp/vulnhub_results"
exclude_banner=false
browser='firefox'
open_browser=false
show_output_translate=false
language='en'

function def_handler(){
  echo -e "\n${bright_red}[!] Saliendo del programa...${end}\n\n"
  [[ -f $results  ]] && rm $results
  [[ -f $TMP_ARCHIVE ]] && rm $TMP_ARCHIVE
  [[ -f $vulnhub_results ]] && rm $vulnhub_results
  [[ -f $htb_results ]] && rm $vulnhub_results
  tput cnorm
  exit 1
}
# Ctrl + C
trap def_handler INT

if ! ping -c 1 8.8.8.8 &>/dev/null; then
  echo -e "\n${bright_black}[!] Al no disponer de internet, este script estara limitado!!"
fi

function helpPanel(){
  local info=$(echo; cat $PATH_ARCHIVE | tail -n 6 | grep -Pi "totalMachines.*" -A 3 | sed 's/htb/HackTheBox (htb)/' | sed 's/vuln/VulnHub (vuln)/' | sed 's/swigger/PortSwigger (swigger)/' | tail -n3  | sed 's/^ *//'; echo)
  local total_machines=$(cat $PATH_ARCHIVE  | grep -i Total -A 4 | grep -oP "\d{1,3}" | xargs | sed 's/ /+/g' | bc)
    if [[ ! $exclude_banner == true ]]; then

    echo -e "${bright_green}
                    .
                 %%%%%%%.
             %%%%%%.  %%%%%%.
        %%%%%%           *%%%%%%.
     %%%%%                   .%%%%%%    
     %%%%%%%%               %%%%%%%%
     %%   %%%%%%%      .%%%%%%%  %%%
     %%       #%%%%%%%%%%%#      %%%    ${bright_white}$0 - Terminal Client${bright_green}
     %%           %%%%#          %%%    ${bright_blue}\t\t        by Flick${bright_red} <3${end}${bright_green}
     %%            %%%           %%%
     %%            %%%           %%%
     %%%%%         %%%          %%%%
       %%%%%%%     %%%     %%%%%%.
           #%%%%%%%%%%%%%%%%%
                %%%%%%%%#
                    .${end}\n"
      echo; echo $info | awk '{for(i=1;i<=NF;i++){printf "%s%s", $i, ($i ~ /^[0-9]+$/ ? "\n" : " ")}}'; echo
      echo "Máquinas totales: $total_machines"

  for i in $(seq 1 80); do echo -ne "${bright_red}-"; done; echo -ne "${end}"
    fi

    echo -e "\n${bright_white}Modo de uso: [$(realpath $0)] [PARAMETROS] [ARGUMENTOS]${end}"
  echo -e "\t${bright_white}-h(help): Mostrar el manual de ayuda.${end}"

  echo -e "\n${bright_white}Actualizaciones y dependencias${end}"
  echo -e "\t${bright_white}-u(update): Actualizar dependencias${end}"

  echo -e "\n${bright_white}Extras${end}"
  echo -e "\t${bright_white}-v(verbose): Activar el modo verbose${end}"
  echo -e "\t${bright_white}-r(random): Modo de elección aleatorio. El script elegira una máquina al azar por ti.${end}"
  echo -e "\t${bright_white}-t(translate): Traducir el output a un idioma especifico.${end}"

  echo -e "\n${bright_white}Listar máquinas y propiedades.${end}"
  echo -e "\t${bright_white}-m(machine): Mostrar las propiedades de una máquina.${end}"
  echo -e "\t${bright_white}-i(ip_addr): Mostrar máquinas por la dirección IP.${end}"
  echo -e "\t${bright_white}-d(difficulty): Mostrar máquinas por una dificultad dada.${end}"
  echo -e "\t${bright_white}-o(osSystem): Mostrar máquinas por un sistema operativo dado.${end}"
  echo -e "\t${bright_white}-w(writeup): Mostrar el enlace a la resolución de una máquina${end}"
  echo -e "\t${bright_white}-s(skill): Listar máquinas por skill${end}"

}

function searchMachine(){

  function helpMachine(){
  
    echo -e "\n${bright_cyan}[+]${bright_white} Opciones disponibles:\n"
    echo -e "\t${bright_magenta}-m${bright_white} Buscar máquinas/s (Ejemplo: $0 -m 'Multimaster')"
    echo -e "\t${bright_magenta}-t${bright_white} Traducir el output (Ejemplo: $0 -m 'Multimaster' -t 'es')${end}\n"
    exit 
  }

  machineName="$1"
  if [[ "$help" == true ]]; then
    helpMachine
  fi

  if ! cat $PATH_ARCHIVE | grep -i "name: $machineName" &>/dev/null; then
    echo -e "${bright_red}\n[!] Error fatal: Máquina no encontrada ${end}${bg_bright_red}\"$machineName\"\n${end}"
    exit 1
  fi

 
  if [[ $show_output_translate == false ]]; then
  output=$(cat $PATH_ARCHIVE| grep -i "name: $machineName" -A 6 -B 1  | sed 's/^ *//g'; echo)

    echo "$output" | while IFS= read -r line; do
      first_column=$(echo $line | awk '{print $1}')
      rest_columns=$(echo $line | cut -d' ' -f2-)
      if [[ -n "$rest_columns" ]]; then
        echo -e "${bright_yellow}${first_column}${end} ${bright_white}${rest_columns}${end}" >> $results
      fi

    done

    echo -e "\n${bright_cyan}[+]${end} ${bright_white}Maquina encontrada:${end} ${bright_magenta}$machineName${end}${bright_white}, listando sus propiedades:${end}"
    echo; /bin/cat $results | sed 's/--.*//'; rm $results
  else
    output=$(cat $PATH_ARCHIVE| grep -i "name: $machineName" -A 6 -B 1  | sed 's/^ *//g' | trans -b -t $language; echo)

    echo "$output" | while IFS= read -r line; do
      first_column=$(echo $line | awk '{print $1}')
      rest_columns=$(echo $line | cut -d' ' -f2-)
      if [[ -n "$rest_columns" ]]; then
        echo -e "${bright_yellow}${first_column}${end} ${bright_white}${rest_columns}${end}" >> $results
      fi

    done

    echo -e "\n${bright_cyan}[+]${end} ${bright_white}Maquina encontrada:${end} ${bright_magenta}$machineName${end}${bright_white}, listando sus propiedades:${end}"
    echo; /bin/cat $results | sed 's/--.*//'; rm $results
      
  fi
}

function searchForIp(){
  ip_addr="$1"
  if ! cat $PATH_ARCHIVE | grep -oP "ip: $ip_addr" &>/dev/null; then
    echo -e "\n${bright_red}[!] Dirección IP no encontrada en la base de datos.\n${end}"
    exit 1
  fi
  
  output=$(cat $PATH_ARCHIVE | grep "ip: $ip_addr" -A 1 -B 6  | sed 's/^ *//')
  machineName=$(cat $PATH_ARCHIVE | grep "ip: $ip_addr" -A 1 -B 6  | sed 's/^ *//' | grep "name: *" | sed 's/name://' | sed 's/^ *//')
  
  echo -e "\n${bright_green}[+]${end} ${bright_white}La dirección IP: ${bright_yellow}$ip_addr${end} ${bright_white}le pertenece a la máquina${bright_blue} $machineName${end}"; true
  [[ $confirm_act == true ]] && searchMachine "$machineName"
}

function showAllDifficulty(){
  echo -e "\n[+] Dificultades existentes: \n"
  echo -e "\t${bright_blue} Dificultad: easy"
  echo -e "\t${bright_yellow} Dificultad: medium"
  echo -e "\t${bright_cyan} Dificultad: hard"
  echo -e "\t${bright_red} Dificultad: insane"
}

function searchDifficulty(){
  difficulty="$1"
  difficulty=$(echo $difficulty | tr '[:upper:]' '[:lower:]')
  
  # Validar que la dificultad exista
  if ! cat $PATH_ARCHIVE | grep -i "state: $difficulty" &>/dev/null; then
    echo -e "\n${bright_red}[!] Dificultad no encontrada.${end}\n"
    showAllDifficulty
    exit 1
  fi
  
  local total_machines=$(cat $PATH_ARCHIVE | grep -i "state: $difficulty" -B 3  | grep -oP "name: .*" | sed 's/name://' | wc -l)

  [[ $help == true ]] && showAllDifficulty && exit 

  [[ $difficulty == "easy" ]] && echo -e "${bright_magenta}[+]${end} ${bright_white}Listando máquinas cuya dificultad es${end}${bright_blue} $difficulty: \n${end}"
  [[ $difficulty == "medium" ]] && echo -e "${bright_magenta}[+]${end} ${bright_white}Listando máquinas cuya dificultad es${end}${bright_yellow} $difficulty: \n${end}"
  [[ $difficulty == "hard" ]] && echo -e "${bright_magenta}[+]${end} ${bright_white}Listando máquinas cuya dificultad es${end}${bright_cyan} $difficulty: \n${end}"
  [[ $difficulty == "insane" ]] && echo -e "${bright_magenta}[+]${end} ${bright_white}Listando máquinas cuya dificultad es${end}${bright_red} $difficulty: \n${end}"
  echo -e "[+] Máquinas totales: $total_machines"

  if cat $PATH_ARCHIVE | grep -i "state: $difficulty" -B 3 | grep -i "platform: HackTheBox" -A 1 | grep -oP "name: .*" | sed 's/name://' &>/dev/null; then
    echo -e "\n${bright_yellow}[+]${bright_white} Plataforma HackTheBox:${end}"
    tput setaf 2; echo; cat $PATH_ARCHIVE | grep -i "state: $difficulty" -B 3 | grep -i "platform: HackTheBox" -A 1 | grep -oP "name: .*" | sed 's/name://' | column 
  fi


  if [[ -n $(cat $PATH_ARCHIVE | grep -i "state: $difficulty" -B 3 | grep -i "platform: VulnHub" -A 1 | grep -oP "name: .*" | sed 's/name://' &>/dev/null) ]]; then
    echo -e "\n${bright_yellow}[+]${bright_white} Plataforma VulnHub:${end}"
    tput setaf 3; echo; cat $PATH_ARCHIVE | grep -i "state: $difficulty" -B 3 | grep -i "platform: VulnHub" -A 1 | grep -oP "name: .*" | sed 's/name://' | column 
  else
    echo -e "\n${bright_black}[!] Máquinas de dificultad $difficulty de plataforma VulnHub no encontradas.${end}\n"
  fi
}

searchOsSystem(){
  osSystem="$1"
  osSystem="$(echo "$osSystem" | tr '[:upper:]' '[:lower:]')"
  if ! cat $PATH_ARCHIVE | grep -i "os: $osSystem" &>/dev/null; then
    echo -e "\n${bright_red}[!] Sistema operativo no encontrado.${end}\n"
    echo -e "\t${bright_white}Sistemas operativos disponibles:${end} ${bright_cyan}Linux${end} ${bright_white}-${end} ${bright_blue}Windows${end}"
    exit 1
  fi
  echo -e "\n${bright_green}[+] Listando máquinas de Sistema Operativo: $osSystem\n${end}"
  echo -e "${bright_cyan}[+]${bright_white} Máquinas de la plataforma HackTheBox:${end}"
  tput setaf 2; echo; cat $PATH_ARCHIVE | grep -i "os: $osSystem" -B 2 | grep -i "platform: HackTheBox" -A 1 | grep -oP "name: .*" | sed 's/name://' | column; echo
  
  echo -e "${bright_cyan}[+]${bright_white} Máquinas de la plataforma VulnHub:${end}"
  tput setaf 3; echo; cat $PATH_ARCHIVE | grep -i "os: $osSystem" -B 2 | grep -i "platform: VulnHub" -A 1 | grep -oP "name: .*" | sed 's/name://' | column; echo

}

function showLink(){
  if [[ $help == true ]]; then
    echo -e "\n${bright_white}Argumentos disponibles: \n"
    echo -e "\t-w (writeup) Buscar el enlace a el writeup de una máquina."
    echo -e "\tEjemplo: $0 -w Tentacle \n\tOutput: https://www.youtube.com/watch?v=hFIWuWVIDek\n"
    echo -e "\t-b (browser) Abrir writeup en un navegador, puedes pasarle como parametro una cadena vacia o 'default' para que en ambos casos sea firefox el navegador"
    echo -e "\tEjemplo: $0 -w Tentacle -b ''\n\tOutput: firefox https://www.youtube.com/watch?v=hFIWuWVIDek${end}\n"
    echo -e "\t"
    exit 
  fi
  writeup="$1"
  writeup=$(echo "$writeup" | tr '[:upper:]' '[:lower:]')
  if ! cat $PATH_ARCHIVE | grep -i "name: $writeup" -A  6 | grep -i "video: https:" | sed 's/video://' | sed 's/^ *//' &>/dev/null; then
    echo -e "\n[!] Máquina no encontrada: $writeup\n\n"
    exit 1
  fi
  link=$(cat $PATH_ARCHIVE | grep -i "name: $writeup" -A  6 | grep -i "video: https:" | sed 's/video://' | sed 's/^ *//')

  echo -e "\n${bright_cyan}[+]${end} ${bright_white}Writeup de la máquina${end} ${bright_green}$writeup${bright_white}: ${bright_blue}$link${end}" 
  
  if [[ $open_browser == true ]]; then
    if ! command -v $browser &>/dev/null; then
      echo -e "\n${bg_bright_red}[!] Navegador invalido: $browser!${end}\n"
      exit 1
    fi
    echo -e "\n${bright_cyan}[+]${bright_white} Abriendo el enlace:${bright_blue} $link en el navegador${bright_magenta} $browser${bright_white}...${end}\n"
    $browser $link &>/dev/null & disown
  fi

  path_writeup="Writeups/$writeup"
}

function updatefiles(){

  if [[ ! -f $PATH_ARCHIVE ]]; then
    [[ $verbose_mode == true ]] && echo -e "${bright_green}[+]${end} ${bright_white} el archivo necesario no existe, se enviara una petición a ${bright_blue}$url${end} por el metodo get\n${bright_magenta}[+]${bright_white}  la información acerca de las máquinas se guardara en ${bright_blue}$PATH_ARCHIVE${end}"
    curl -s -X GET $url | js-beautify > $PATH_ARCHIVE
    /bin/cat $PATH_ARCHIVE | sed 's|\\n| |g' | tr -d "'" | tr -d '"' | tr -d ',' | sponge $PATH_ARCHIVE
    [[ $verbose_mode == true ]] && echo -e "${bright_green}[+]  archivo exitosamente guardado, código de estado $(echo $?), exitoso :)"
  else
    [[ $verbose_mode == true ]] && echo -e "${bright_green}[+]${end}  ${bright_white}el archivo${end} ${bright_yellow}$PATH_ARCHIVE${end}${bright_white} existe ya en el sistema, por lo que estaremos buscando actualizaciones.${end}"
    curl -s -X GET $url | js-beautify > $TMP_ARCHIVE
    [[ $verbose_mode == true ]] && echo -e "${bright_green}[+]  el archivo temporal, extraido de ${bright_yellow}$url${bright_green} se guardara en ${bright_black}$TMP_ARCHIVE${bright_green} de momento"
    sleep 1
    /bin/cat $TMP_ARCHIVE | sed 's|\\n| |g' | tr -d "'" | tr -d '"' | tr -d ',' | sponge $TMP_ARCHIVE
    [[ $verbose_mode == true ]] && echo -e "${bright_green}[+]${end} ${bright_white} verificando si ${bright_black}$TMP_ARCHIVE${end}${bright_white} y ${bright_yellow}$PATH_ARCHIVE${bright_white} son identicos o diferentes."
    md5_temp=$(md5sum $TMP_ARCHIVE | awk '{print $1}')
    original=$(md5sum $PATH_ARCHIVE | awk '{print $1}')
    if [[ ! $original == $md5_temp ]]; then
      if [[ $confirm_act == false ]]; then
        echo -ne "${bright_green}[+]${bright_white}  Se detectaron algunas actualizaciones, deseas continuar? (Y/n) ${end}" && read -n 1 yes_or_no
        if [[ $yes_or_no =~ ^[Yy]$ ]]; then
          rm $PATH_ARCHIVE
          mv $TMP_ARCHIVE $PATH_ARCHIVE
          echo -e "\n${bright_green}[+] ${bright_white} Actualizaciones finalizadas.${end}"
        else
          echo -e "\n${bright_red}[-]${bright_white} Actualizaciones rechazadas${end}"
          rm $TMP_ARCHIVE
          return 1
        fi
      else
          rm $PATH_ARCHIVE
          mv $TMP_ARCHIVE $PATH_ARCHIVE
          echo -e "\n${bright_green}[+] ${bright_white} Actualizaciones finalizadas.${end}"  
      fi
    else
      rm $TMP_ARCHIVE
      echo -e "${bright_green}[+]${bright_white}  No se detectaron actualizaciones, estas al día.${end}"
    fi
  fi
}


function Get_cert(){
    certificate="$1"
    output=$(echo "./addFuncs/getCertificates.sh" "$certificate" | bash)  # Captura la salida del script

    if [[ -z "$output" ]]; then  # Verifica si la salida no está vacía
      echo -e "\n${bright_red}[!] No se encontraron matches: $certificate${end}"
      return 1
    fi
  
    echo -e "\n${bright_blue}[+]${end} ${bright_white}Listando máquinas que dispongan de los certificados ${bright_cyan}$certificate${bright_white}.${end}\n"
    echo "./addFuncs/getCertificates.sh ""$certificate" | bash
}

function random_machine(){
  tput civis
    local value=0
    while [[ $value -le 100 ]]; do
        machineName=$(cat $PATH_ARCHIVE | grep -i 'name: .*' | sed 's/name: //' | sed 's/^ *//' | shuf -n 1)
        echo -ne "\r\033[K${bright_blue}[+]${bright_white} Tu máquina elegida es: ${bright_cyan}\"$machineName\"${end}"
        ((value++))
    done

  if ! cat $PATH_ARCHIVE | grep -i "name: $machineName" &>/dev/null; then
    echo -e "${bright_red}\n[!] Error fatal: Máquina no encontrada ${end}${bg_bright_red}\"$machineName\"\n${end}"
    exit 1
  fi

  output=$(cat $PATH_ARCHIVE| grep -iP "name: ${machineName}$" -A 6 -B 1  | sed 's/^ *//g'; echo) 
  echo "$output" | while IFS= read -r line; do
    first_column=$(echo $line | awk '{print $1}')
    rest_columns=$(echo $line | cut -d' ' -f2-)
    if [[ -n "$rest_columns" ]]; then
      echo -e "${bright_yellow}${first_column}${end} ${bright_white}${rest_columns}${end}" >> $results
    fi

  done

  echo -e "\n${bright_cyan}[+]${end} ${bright_white}Maquina encontrada:${end} ${bright_magenta}$machineName${end}${bright_white}, listando sus propiedades:${end}"
  echo; /bin/cat $results | sed 's/--.*//'; rm $results
  tput cnorm && exit
}

function searchPlatform(){
  platform="$1"
  
  if ! cat $PATH_ARCHIVE | grep -i "platform: $platform" &>/dev/null; then
    echo -e "\n[!] Error fatal, no se enctontro la plataforma: $platform"
    exit 1
  fi

  if [[ "$confirm_act" == false ]]; then 
    if [[ "$platform" =~ ^[Hh] ]]; then
      tput setaf 2; echo; cat /tmp/bundle.js | grep -i "platform: $platform" -A 1 | grep -oP "name: .*" | sed 's/name://' | column; echo
    elif [[ "$platform" =~ ^[Pp] ]]; then
      tput setaf 3 && tput bold; echo; cat /tmp/bundle.js | grep -i "platform: $platform" -A 1 | grep -oP "name: .*" | sed 's/name://' | column; echo
    else
       tput setaf 2; echo; cat /tmp/bundle.js | grep -i "platform: $platform" -A 1 | grep -oP "name: .*" | sed 's/name://' | column; echo   
    fi
  fi

  if [[ "$confirm_act" == true ]]; then
    cat $PATH_ARCHIVE | grep -i "platform: $platform" -A 1 | grep -o 'name: .*' | sed 's/name: //' | while read machineName; do
          searchMachine "$machineName"
    done
  fi

}

function searchSkill(){
  skill="$1"
  output=$(echo "./addFuncs/getSkills.sh" "$skill" | bash)  # Captura la salida del script

  if [[ -z "$output" ]]; then  # Verifica si la salida no está vacía
    echo -e "\n${bright_red}[!] No se encontraron matches: $skill${end}"
    return 1
  fi

  echo -e "\n${bright_blue}[+]${end} ${bright_white}Listando máquinas que dispongan de skill ${bright_cyan}$skill${bright_white}.${end}\n"
  echo "./addFuncs/getSkills.sh ""$skill" | bash

}

while getopts 'w:o:b:d:i:m:c:huvyxrp:t:s:' arg; do
  case $arg in
    x) exclude_banner=true;;
    v) verbose_mode=true;;
    y) confirm_act=true;;
    m) machineName=$OPTARG; let parameter_counter+=1;;
    t) language="$OPTARG"; show_output_translate=true;;
    b) browser="${OPTARG:-firefox}"; open_browser=true;[[ "$browser" == 'default' ]] && browser='firefox';;
    u) let parameter_counter+=2;;
    i) ip_addr=$OPTARG; let parameter_counter+=3;;
    d) difficulty=$OPTARG; let parameter_counter+=4;;
    o) osSystem=$OPTARG; let parameter_counter+=5;;
    w) writeup=$OPTARG; let parameter_counter+=6;;
    c) certificate="$OPTARG"; let parameter_counter+=7;;
    r) random_machine;;
    p) platform="$OPTARG"; let parameter_counter+=8;;
    s) skill="$OPTARG"; let parameter_counter+=9;;
    h) help=true;;
  esac
done


if [[ $parameter_counter -eq 1 ]]; then
  searchMachine "$machineName"
elif [[ $parameter_counter -eq 2 ]]; then
  updatefiles
elif [[ $parameter_counter -eq 3 ]]; then
  searchForIp "$ip_addr"
elif [[ $parameter_counter -eq 4 ]]; then
  searchDifficulty "$difficulty"
elif [[ $parameter_counter -eq 5 ]]; then
  searchOsSystem "$osSystem"
elif [[ $parameter_counter -eq 6 ]]; then
  showLink "$writeup"
elif [[ "$parameter_counter" -eq 7 ]]; then
  Get_cert "$certificate"
elif [[ "$parameter_counter" -eq 8 ]]; then
  searchPlatform "$platform"
elif [[ "$parameter_counter" -eq 9 ]]; then
  searchSkill "$skill"
else
  helpPanel
fi


