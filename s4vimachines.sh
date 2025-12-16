#!/bin/bash
# Script de bash para buscar máquinas que s4vitar va resolviendo.
# Puedes meter este script en tu PATH para mas comodidad, deah. 
 
ruta=$(realpath "${0}" | rev | cut -d'/' -f2- | rev)
cd "${ruta}" || exit 1 

SELF=${0##*/}
# Colors
source Colors.sh
source ./variables/global_variables.sh
source ./config/appareance.sh

# utils 
source ./utils/ask_yes_no.sh
source ./utils/messagebox.sh

[[ ! -d "${DIRECTORY}" ]] && mkdir -p "${DIRECTORY}"

function def_handler(){ 
  exec 3>&-
  echo -e "\n${bright_red}[!] Saliendo del programa...${end}\n\n"
  [[ -f $results  ]] && rm $results
  [[ -f $TMP_ARCHIVE ]] && rm $TMP_ARCHIVE
  [[ -f $vulnhub_results ]] && rm $vulnhub_results
  [[ -f $htb_results ]] && rm $vulnhub_results
  [[ -f "${p}" ]] && rm "${p}"
  tput cnorm
  exit 1
}
# Ctrl + C
trap def_handler INT

blink_text () {
	text="${1:?This parameter is required!}" 
	echo -e "\e[5m${text}\e[0m"
}

function beautifiul_text(){ 

  text="${1:-♥ https://www.textualize.io}"

  r1=170; g1=110; b1=230
  r2=90;  g2=60;  b2=150

  len=${#text}

  printf "\033[1m"

  for ((i=0; i<len; i++)); do
      ch=${text:i:1}
      r=$((r1 + (r2 - r1) * i / (len - 1)))
      g=$((g1 + (g2 - g1) * i / (len - 1)))
      b=$((b1 + (b2 - b1) * i / (len - 1)))
      printf "\033[38;2;%d;%d;%dm%s" "$r" "$g" "$b" "$ch"
  done

  echo -e "\033[0m"
}


function banner(){
      echo -e "${bright_green}
                    .
                 %%%%%%%.
             %%%%%%.  %%%%%%.
        %%%%%%           *%%%%%%.
     %%%%%                   .%%%%%%    
     %%%%%%%%               %%%%%%%%
     %%   %%%%%%%      .%%%%%%%  %%%
     %%       #%%%%%%%%%%%#      %%%    ${bright_white}s4vimachines - (infosec) Terminal Client${bright_green}
     %%           %%%%#          %%%    ${bright_blue}\t\t        by dreamer${bright_red} <3${end}${bright_green}
     %%            %%%           %%%     
     %%            %%%           %%%
     %%%%%         %%%          %%%%
       %%%%%%%     %%%     %%%%%%.
           #%%%%%%%%%%%%%%%%%
                %%%%%%%%#
                    .${end}\n"


                    # Este banner no fue copiado jeje 
}

function helpPanel(){
  content=(

    " ${green_water}-m${reset} ${light_blue} --machine${reset} ${opt}MACHINE${reset}                 ${birght_white}Mostrar las propiedades de una ${subrayado}máquina${reset}${birght_white}.${reset}"
    " ${green_water}-i${reset} ${light_blue} --ip-adress${reset} ${opt}ADRESS${reset}                ${birght_white}Filtrar por máquinas a las que se les haya asignado dicha ${subrayado}IP${birght_white}.${reset}"
    " ${green_water}-d${reset} ${light_blue} --difficulty${reset} ${opt}DIFFICULTY${reset}           ${birght_white}Mostrar todas las máquinas de cierta ${subrayado}dificultad${birght_white}.${reset} ${comment}Fácil, Media, Díficil e Insane.${reset}"
    " ${green_water}-o${reset} ${light_blue} --os${reset} ${opt}SYSTEM${reset}                       ${birght_white}Mostrar todas las máquinas por un determinado ${subrayado}sistema operativo${birght_white}.${reset} ${comment}Linux, Windows, Otros${reset}"
    " ${green_water}-w${reset} ${light_blue} --writeup${reset} ${opt}MACHINE${reset}                 ${birght_white}Obtener solo el ${subrayado}writeup${birght_white} de una máquina.${reset}"
    " ${green_water}-s${reset} ${light_blue} --skill${reset} ${opt}SKILLS${reset}                    ${birght_white}Listar máquinas por ${subrayado}skill${birght_white} o ténicas que se requieran para resolver la máquina.${reset} ${comment}e.g: 'Unicode SQLI Waf Bypass Kerberos'${reset}"
    " ${green_water}-c${reset} ${light_blue} --cert${reset} ${opt}CERTS${reset}                      ${birght_white}Listar todas las máquinas que te preparen para uno o mas ${subrayado}certificados${birght_white}.${reset} ${comment} e.g: 'OSCP eJPT eWPTxv2'${reset}"
    " ${green_water}  ${reset} ${light_blue} --preview${reset} ${opt}POSITION${reset}                ${birght_white}Indicar la posisión en la que saldra la ${underline}preview${end}${bright_wite} de fzf.${ed}${comment} Parametros: ${bold}up|down|right|left${end}"

    " ${green_water}-A${reset} ${light_blue} --Advanced-search${reset} ${opt}OBJECTS${reset}         ${birght_white}Realizar una ${subrayado}busqueda avanzada${birght_white}.${reset} ${comment}e.g: 'OSCP Windows Insane SQLI'${reset}"
    " ${green_water}-a${reset} ${light_blue} --all-machines${reset}                    ${birght_white}Mostrar todas las máquinas existentes en la base de datos.${reset}"
    " ${green_water}-u${reset} ${light_blue} --update-db${reset} ${opt}OPTIONAL${reset}              ${birght_white}Actualizar o descargar dependencias faltantes.${reset}"
    " ${green_water}-r${reset} ${light_blue} --random-machine${reset} ${opt}OPTIONAL${reset}         ${birght_white}Obtener una máquina al ${subrayado}azar${birght_white} de todas las que hay.${reset} ${comment}Este metodo acepta parametros.${reset}"
    " ${green_water}-v${reset} ${light_blue} --verbose${reset}                         ${birght_white}Habilitar el modo ${subrayado}verbose${birght_white}, el cual sirve para mostrar mas información de lo habitual.${reset}"
    " ${green_water}-y${reset} ${light_blue} --no-confirm${reset}                      ${birght_white}Saltarse prompts que requieran de confirmación de usuario.${reset}"
    "    ${light_blue} --recoils${reset} ${opt}RECOILS${reset}                 ${birght_white}Definir cuantas iteraciones dara el modo aleatorio para la elección de máquinas.${reset} ${comment}Por defecto seran 100 iteraciones. ${reset}"
    "    ${light_blue} --color-matches${reset}                   ${birght_white}Colorear las lineas donde salgan las palabras clave.${reset} ${comment}Funcion de busqueda avanzada, por certificado o skill${reset}"
    " ${green_water}-h${reset} ${light_blue} --help${reset}                            ${birght_white}Mostrar este mensaje y salir.${reset}"
  )

  cols=$(tput cols)
  ((inner_width = cols - 3))

  maxlen=0
  for line in "${content[@]}"; do
    clean=$(printf "%b" "$line" | sed 's/\x1b\[[0-9;]*m//g')
    len=${#clean}
    (( len > maxlen )) && maxlen=$len
  done

  if (( maxlen > inner_width )); then
    maxlen=$inner_width
  fi

    function print_line() {
      local text="$1"
      local clean=$(printf "%b" "$text" | sed 's/\x1b\[[0-9;]*m//g')
      local spaces=$((inner_width - ${#clean}))
      (( spaces < 0 )) && spaces=0
      printf "${border}│${reset}%b%${spaces}s${border}│${reset}\n" "$text" ""
    }

  printf "${border}╭─${header} Options ${border}$(printf '─%.0s' $(seq 1 $((inner_width - 10))))╮${reset}\n"

  for line in "${content[@]}"; do
    print_line "$line"
  done

  printf "${border}╰$(printf '─%.0s' $(seq 1 $inner_width))╯${reset}\n"

  beautifiul_text "♥ https://SelfDreamer.github.io" 

  printf "\n"

}

function searchMachine(){
  # ╭─────────────╮
  # │ Hola Mundo! │
  # ╰─────────────╯

  machineName="${1}"

  if [[ -z "${machineName}" ]]; then 
    messagebox -title "Error" -Type "Error" -message "Esta función require de un parametro, el cual no se ha indicado!"
    helpPanel
    exit 1 
  fi

  if [[ "${machineName}" == "%{random}%" ]]; then 
    machineName=$(jq -r '.tutorials[]["nombre"]' < "${PATH_ARCHIVE}" | shuf -n1) 
  fi 

  results=$(jq -r --arg icon_color "${icon_color}" --arg name "${machineName}" --arg icon "${icon}" --arg blue "${bright_blue}" --arg end "${end}" --arg bright_cyan "${bright_cyan}" --arg bright_magenta "${bright_magenta}" --arg bright_white "${bright_white}" '

  .tutorials[]
  | select((.nombre | ascii_downcase) == ($name | ascii_downcase))
  | 
  (
    "\(.nombre)" as $n |
    "\(.certificaciones)" as $c |
    "\(.tecnicas)" as $t |
    "\(.videoUrl)" as $writeup |
    "\(.ip)" as $addr |
    "Nombre: \(.nombre)" as $line1 |
    "IP: \(.ip)" as $line2 |
    "SO: \(.sistemaOperativo)" as $line3 |
    "Dificultad: \(.dificultad)" as $line4 |

    [$line1, $line2, $line3, $line4] 

    | map(length) 
    | max as $maxLen |

    def pad($text): $text + (" " * ($maxLen - ($text | length))) ;

    def paint($text):
      ($text | split(":") | .[0] as $k | .[1] as $v |
        "\($bright_magenta)\($k):\($bright_white)\($v)\($blue)") ;

    "\($blue)╭" +
    "\\033]8;;\($writeup)\\033\\\\\($bright_cyan)\($n)\\033[0m\\033]8;;\\033\\\\" + "\($blue)─" + ("─" * (($maxLen + 2) - ($n | length))) + "─╮\n" +

    "│ " + "\($bright_magenta)▌\($blue)" + paint(pad($line2)) + " " + " │\n" +
    "│ " + "\($bright_magenta)▌\($blue)" + paint(pad($line3)) + " " + " │\n" +
    "│ " + "\($bright_magenta)▌\($blue)" + paint(pad($line4)) + " " + " │\n" +
    "╰" + ("─" * ($maxLen + 2)) + "──" + "╯\n" + 
    "\u001b[35mCertificaciones:\u001b[0m\n" +
    (($c // "") 
    | split("\n") 
    | map("\($icon_color)\($icon) \u001b[97m" + . + "\u001b[0m") 
    | join("\n")) +
    "\n\n\u001b[35mTécnicas:\u001b[0m\n" +

    (($t // "")
        | split("\n")
        | map("\($icon_color)\($icon) \u001b[97m" + . + "\u001b[0m")
        | join("\n")
      ) +
      "\n\n\u001b[35mVideo:\u001b[0m \u001b[97m\($writeup)\u001b[0m"
  )

  ' "${PATH_ARCHIVE:?Fatal error, variable PATH_ARCHIVE not exists!}") 

  if [[ -z "${results}" ]]; then 

    messagebox -title "Error" -message "${bright_white}No se encontro la máquina ${bold}${machineName}${end}${bright_white}, intentalo de nuevo mas tarde!${end}" -type Error

    helpPanel

    exit 1

  fi

  printf "\n%b[+]%b Listando las propiedades de la máquina %b%s%b:%b\n" "${bright_green}" "${bright_white}" "${bright_magenta}" "${machineName^}" "${bright_white}" "${end}"
  
  printf "\n%b\n\n" "${results}"


}

function searchForIp() {

  ip_addr="${1}"

  if [[ -z "${ip_addr}" ]]; then 
    
    messagebox -title "Argumentos faltantes" -message "Esta función requiere de al menos, un argumento" -type Error 

    helpPanel

    exit 1 

  fi 


  machineName="$(jq -r '.tutorials[] | "Machine: \(.nombre)\nip: \(.ip)\n"' ${PATH_ARCHIVE} | grep -P "${ip_addr}$" -B 1 | grep -oP "Machine: \K(\S+)")"
  
  if [[ -z "${machineName}" ]]; then 

    messagebox -type "Error" -message "Error fatal, la dirección ip indicada no se encontro en la base de datos, se tenso!" -title "Error"
    helpPanel
    exit 1
  
  fi 

  if [[ "${confirm_act}" == true ]]; then 
    searchMachine "${machineName}"
    exit 0
  fi 
    
  message="""
  La IP ${ip_addr} le pertenece a la máquina ${machineName}
  ¿Deseas listar las propiedades de la máquina ${machineName}?"""
  resp=$(ask_yes_no -message "${message}" -options "Si,No")
  
  if [[ "${resp}" == "No" ]]; then 
    msg="""Operación cancelada por el usuario ${USER}.
Puedes pasar de esto automaticamente con el parametro ${italic_style}${bold_style}--no-confirm${end}"""
    messagebox -type Hint \
    -message "${msg}" \
    -title "Info"
    exit 
  fi 

  searchMachine "${machineName}"

}


function searchDifficulty(){

  difficulty="${1}"

  if [[ -z "${difficulty}" ]]; then 
    
    messagebox -title "Argumentos faltantes" -message "Esta función requiere de al menos, ${bold_style}un ${underline_style}argumento${end}." -type Error 

    helpPanel

    exit 1 

  fi 


  content=$(jq -r --arg difficulty "$difficulty" '
    def normalize(s):
      s
      | ascii_downcase
      | gsub("á";"a")
      | gsub("é";"e")
      | gsub("í";"i")
      | gsub("ó";"o")
      | gsub("ú";"u")
      | gsub("Á";"a")
      | gsub("É";"e")
      | gsub("Í";"i")
      | gsub("Ó";"o")
      | gsub("Ú";"u");

    .tutorials[]
    | select(normalize(.dificultad) == normalize($difficulty))
    | (
        "\u001b[1;38;2;255;255;255m" + .nombre + "\u001b[0m" + "\t" +
        "\u001b[38;2;255;255;100m" + .ip + "\u001b[0m" + "\t" +
        "\u001b[38;2;255;255;150m" + .sistemaOperativo + "\u001b[0m" + "\t" +
        (
          if normalize(.dificultad) == "facil" then "\u001b[38;2;100;255;100m"
          elif normalize(.dificultad) == "media" then "\u001b[38;2;255;255;100m"
          elif normalize(.dificultad) == "dificil" then "\u001b[38;2;255;100;100m"
          elif normalize(.dificultad) == "insane" then "\u001b[38;2;180;100;255m"
          else "\u001b[0m" end
        ) + .dificultad + "\u001b[0m" + "\t" +
        "\u001b[38;2;100;150;255m" + .videoUrl + "\u001b[0m"
      )
      ' "${PATH_ARCHIVE}" | column -t -s $'\t')
  
    if [[ -z "${content}" ]]; then 
      messagebox \
        -type "Error" \
        -message "No se encontro la dificultad indicada, lea al manual de ayuda. ${comment}${italic_style}--help${end}" \
        -title "Error"
      helpPanel 
      exit 1 
    fi 

  fzf --ansi \
      --header="Máquinas $difficulty" \
      --preview './s4vimachines.sh -m {1} | tail -n +3' \
      --preview-window=${prev:-right}:50% \
      --color=16 \
      --prompt="❯ " \
      --marker="✓ " \
      --ignore-case \
      --nth=1,2,3,4 \
      --style full \
      --bind 'enter:execute(./s4vimachines.sh -m {1})+abort' <<< "${content}" 

  return 0
 
}

searchOsSystem(){
  osSystem="${1}"

  if [[ -z "${osSystem}" ]]; then 
    
    messagebox \
      -title "Argumentos faltantes" \
      -message "Esta función requiere de al menos, ${bold_style}un ${underline_style}argumento${end}." \
      -type Error

    helpPanel

    exit 1 

  fi 


  content=$(jq -r --arg osSystem "${osSystem}" '
    def normalize(s):
      s
      | ascii_downcase
      | gsub("á";"a")
      | gsub("é";"e")
      | gsub("í";"i")
      | gsub("ó";"o")
      | gsub("ú";"u")
      | gsub("Á";"a")
      | gsub("É";"e")
      | gsub("Í";"i")
      | gsub("Ó";"o")
      | gsub("Ú";"u");

    .tutorials[]
    | select(normalize(.sistemaOperativo) == normalize($osSystem))
    | (
        "\u001b[1;38;2;255;255;255m" + .nombre + "\u001b[0m" + "\t" +
        "\u001b[38;2;255;255;100m" + .ip + "\u001b[0m" + "\t" +
        "\u001b[38;2;255;255;150m" + .sistemaOperativo + "\u001b[0m" + "\t" +
        (
          if normalize(.dificultad) == "facil" then "\u001b[38;2;100;255;100m"
          elif normalize(.dificultad) == "media" then "\u001b[38;2;255;255;100m"
          elif normalize(.dificultad) == "dificil" then "\u001b[38;2;255;100;100m"
          elif normalize(.dificultad) == "insane" then "\u001b[38;2;180;100;255m"
          else "\u001b[0m" end
        ) + .dificultad + "\u001b[0m" + "\t" +
        "\u001b[38;2;100;150;255m" + .videoUrl + "\u001b[0m"
      )
      ' "${PATH_ARCHIVE}" | column -t -s $'\t')

  if [[ -z "${content}" ]]; then 
    all_so=$(jq -r '.tutorials[]["sistemaOperativo"]' ${PATH_ARCHIVE} | sort -u)
    local so_content
    for os in ${all_so}; do 
      so_content+="""${icon_color}${icon}${end} ${bold_style}${os}${end}
"""
    done 
    msg="""No se encontraron máquinas de SO: \"${bold_style}${italic_style}${osSystem}${end}\".
Actualmente solo contamos con los ${bold_style}sistemas operativos${end}:
${so_content}
"""
    messagebox \
      -type "Error" \
      -message "${msg}" \
      -title "Error"
    helpPanel 
    exit 1
  fi 

  fzf --ansi \
      --header="Máquinas ${osSystem}" \
      --preview './s4vimachines.sh -m {1} | tail -n +3' \
      --preview-window=${prev:-right}:50% \
      --color=16 \
      --prompt="❯ " \
      --marker="✓ " \
      --ignore-case \
      --nth=1,2,3,4 \
      --style full \
      --bind 'enter:execute(./s4vimachines.sh -m {1})+abort' <<< "${content}"

  return 0


}

to_seconds_to_date_yt(){
  local seconds="${1:?}"
  h=$((seconds / 3600))
  m=$(((seconds % 3600) / 60))
  s=$((seconds % 60))

  printf "%02d:%02d:%02d\n" "$h" "$m" "$s"

}

function write_rule_markdown(){

  local rule=""

  for i in $(seq 1 "$tty_largo"); do
    echo -ne "${comment}$rule${end}"
  done
}

function showLink(){  
  local preffix="▌"
  
  local machineName="${1}"


  [[ -z "${machineName}" ]] && messagebox -title "Error" -message "Esta función requiere de un argumento el cual no se ha indicado, vuelve a intentarlo de nuevo mas tarde!" -type Error \
    && helpPanel \
    && exit 1 

  if [[ "${machineName}" == "%{random}%" ]]; then 
    machineName=$(jq -r '.tutorials[]["nombre"]' < "${PATH_ARCHIVE}" | shuf -n1)
  fi 


  local data=$(jq -r --arg name "${machineName}" '.tutorials[] | select((.nombre | ascii_downcase) == ($name | ascii_downcase)) ' "${PATH_ARCHIVE}")
  
  [[ -z "${data}" ]] && messagebox -title "Error" -message "No se encontro el writeup para la máquina dada, intentalo de nuevo más tarde!" -type Error \
    && helpPanel \
    && exit 1

  writeup=$(jq -r '.videoUrl' <<< "${data}")
  machineName=$(jq -r '.nombre' <<< ${data})

  echo -e "${bright_red}${bold}${preffix}${bright_white}${italic_style} Writeup de la máquina ${bold}${machineName}${end}${bright_white}:${bright_blue} ${writeup}${end}\n"

  local data=$(curl -s "${writeup}" \
| sed -n 's/.*ytInitialPlayerResponse = //p' \
| sed 's/;$//' \
| jq '.microformat.playerMicroformatRenderer' 2>/dev/null | jq -r '. | del(
        .availableCountries,
        .embed,
        .linkAlternates,
        .trackingParams
        ) | 
          {
            title,
            description, 
            lengthSeconds,
            uploadDate,
            ownerChannelName, 
            ownerProfileUrl, 
            likeCount,
            lengthSeconds
          }') 

  local tty_largo=$(stty size | awk '{print $2}')
  
  title=$(jq -r '.title["simpleText"]' <<< "${data}")
  creator=$(jq -r '.ownerChannelName' <<< "${data}")
  ownerProfileUrl=$(jq -r '.ownerProfileUrl' <<< "${data}")
  likeCount=$(jq -r '.likeCount' <<< "${data}")
  description=$(jq -r '.description.simpleText' <<< "${data}")
  description=$(
    printf "%b\n" "$description" |
    sed -E '
      s|^(.*https?://)|\x1b[33m'"$icon"' \x1b[0m\1|
      s|(https?://[^[:space:]]+)|\x1b[36m\1\x1b[0m|g
      s|#([A-Za-z0-9_-]+)|\x1b]8;;https://www.youtube.com/hashtag/\1\x1b\\\x1b[34m#\1\x1b[0m\x1b]8;;\x1b\\|g
      s|([0-2][0-9]:[0-5][0-9])|\x1b[34m\1\x1b[0m|g
    '
  )
  seconds=$(jq -r '.lengthSeconds' <<< "${data}")

  total_time=$(to_seconds_to_date_yt "${seconds}")

  write_rule_markdown
  
  echo -e "${icon_color}${icon}${end} ${bright_white}${bold}Título: ${title}${end}"

  echo -e "${icon_color}${icon}${end} ${bright_white}${bold}Autor:${end} ${bright_blue}\033]8;;${ownerProfileUrl}\033\\@${creator}\033]8;;\033\\ ${end}"
  echo -e "${icon_color}${icon}${end} ${bright_white}${bold}Likes:${end} ${bright_green}${underline_style}${likeCount}${end}"
  echo -e "${icon_color}${icon}${end} ${bright_white}${bold}Duración: ${bright_cyan}${total_time}${end}"
  
  write_rule_markdown
  
  messagebox \
    -title "Descripción" \
    -message "${description}" \
    -type Info  
  


}

function log(){
  message="${1:-Este mensaje es de prueba}"

  if ! "${verbose_mode}"; then 
    return 
  fi 

  echo -e "${message}"

}

function s4vidownload(){
  local preffix="▌"
    
  local d=$(date '+%H:%M:%S')

  log "${bright_magenta}${bold}${preffix}[${LINENO}] [${d}] DEBUG${end}${bright_white} Ejecutando el script downloader... ${comment}python3 downloader.py --path=${PATH_ARCHIVE}${end}"

  local status_code=$(python3 downloader.py --path="${PATH_ARCHIVE}" 2>/dev/null)

  local d=$(date '+%H:%M:%S')
  log "${bright_magenta}${bold}${preffix}[${LINENO}] [${d}] DEBUG${end}${bright_white} El script se termino de ejecutar, vamos a ver si todo salio bien."

  if [[ "${?}" -ne 0 ]]; then 
    local d="$(date '+%H:%M:%S')"
    log "${bright_red}${bold}${preffix}[${LINENO}] [${d}] ERROR${end} Se encontro un error al intentar descargar el archivo, vuelve a intentarlo mas tarde."
    local d="$(date '+%H:%M:%S')"
    log "${bright_magenta}${bold}${preffix}[${LINENO}] [${d}] DEBUG${end}${bright_white} Crea un ISSUE en GitHub para poder ayudarte, muchas gracias por leer."
    tput cnorm
    exit 1
  fi
  local d=$(date '+%H:%M:%S')
  
  log "${bright_magenta}${bold}${preffix}[${LINENO}] [${d}] DEBUG${end} El archivo se descargo correctamente sin mostrar errores."
  tput cnorm 

  exit 0

}

function s4viupdate(){
  local preffix="▌"
  
  log "${bright_magenta}${preffix} [${LINENO}] DEBUG${end} Ejecutando el script para obtener la base de datos y compararla con la base de datos actualmente en uso...${comment} python3 downloader.py --path=${TMP_ARCHIVE}${end}"
  local resp=$(python3 downloader.py --path="${TMP_ARCHIVE}" 2>/dev/null)

  log "${bright_magenta}${preffix} [${LINENO}] DEBUG${end} Verificando si no hay errores luego de descargarnos el archivo."

  if [[ "${?}" -ne 0 ]]; then 
    log "${bright_red}${preffix} [${LINENO}] ERROR${end} No se pudo actualizar la base de datos."
    log "${bright_green}${preffix} [${LINENO}] INFO${end} Crea un ISSUE en GitHub comentando este problema."
    tput cnorm 
    exit 1 
  fi >&2 
  
  log "${bright_magenta}${preffix} [${LINENO}] DEBUG${end} Verificando si ${PATH_ARCHIVE##*/} y ${TMP_ARCHIVE##*/} son identicos o no."
  if cmp "${PATH_ARCHIVE}" "${TMP_ARCHIVE}" --quiet; then 
    log "${bright_magenta}${preffix} [${LINENO}] DEBUG${end} No se han detectado actualizaciones, el archivo ${PATH_ARCHIVE##*/} y ${TMP_ARCHIVE##*/} son identicos."
    log "${bright_green}${preffix} [${LINENO}] INFO${end} Se procedera a borrar el archivo temporal para no dejar basura en tu sistema."

    if rm "${TMP_ARCHIVE}" 2>/dev/null; then  
      log "${bright_green}${preffix} [${LINENO}] INFO${end} Archivo borrado exitosamente, ten buen día!"
      tput cnorm 

      exit 0
    fi 

    log "${bright_red}${preffix} [${LINENO}] ERROR${end} No se pudo borrar ${TMP_ARCHIVE}."
    tput cnorm 
    exit 1 
 
  fi 
  
  # There are updates! 
  log "${bright_magenta}${preffix} [${LINENO}] DEBUG${end} Se encontraron actualizaciones, se procedera a actualizar la base de datos."
  rm "${PATH_ARCHIVE}" && mv "${TMP_ARCHIVE}" "${PATH_ARCHIVE}"
  log "${bright_green}${preffix} [${LINENO}] INFO${end} Acutlizaciones encontradas y realizadas, ten buen día."
  tput cnorm 
  exit 0
  
}

function updatefiles(){ 
  local preffix="▌"

  tput civis

  # File doesnt exists, then we will create an file with the necesary recourses!
  local response

  local update=false 
  local download=false 
  local message

  if [[ ! -f "${PATH_ARCHIVE}" ]]; then 
    message="${bright_magenta}${bold}El archivo ${italic_style}${bold}${PATH_ARCHIVE##*/}${end}${bright_magenta}${bold} no existe ¿Deseas bajarlo?${end}"
    download=true
  elif [[ -f "${PATH_ARCHIVE}" ]]; then
    message="${bright_magenta}${bold}El archivo ${italic_style}${bold}${PATH_ARCHIVE##*/}${end}${bright_magenta}${bold} existe ¿Deseas actualizarlo?${end}"
    update=true
  fi

  if "${confirm_act}"; then 

    if "${download}"; then 
      log "${bright_green}${bold}${preffix}[${LINENO}] INFO${end} No se encontro el archivo ${PATH_ARCHIVE##*/}, vamos a descargarlo."
      log "${bright_magenta}${bold}${preffix}[${LINENO}] DEBUG${end}${bright_white} Descargando archivo...${end} ${comment}name=${PATH_ARCHIVE##*/}${end}"
      s4vidownload
    elif "${update}"; then 
      
      log "${bright_green}${preffix} [${LINENO}] INFO${end} El archivo ${italic_style}${PATH_ARCHIVE##*/}${end} existe, pero vamos a ver si hay actualizaciones..."
      log "${bright_magenta}${preffix} [${LINENO}] DEBUG${end} Descargando archivo para realizar comparatorias...${comment} name=${TMP_ARCHIVE}${end}"

      s4viupdate

    fi 

    exit 
  fi 
  
  local resp=$(ask_yes_no -message "${message}" -options "Si,No")

  if [[ "${resp}" == "No" ]]; then 
    messagebox \
      -type Warning \
      -title "Operación cancelada" \
      -message "Operación cancelada por el usuario ${underline}${bold_style}${USER}${end}"
    exit 1
  fi 
  
  if [[ "${resp}" == "Si" ]]; then 
    if "${download}"; then 
      log "${bright_green}${bold}${preffix}[${LINENO}] INFO${end} No se encontro el archivo ${PATH_ARCHIVE##*/}, vamos a descargarlo."
      log "${bright_magenta}${bold}${preffix}[${LINENO}] DEBUG${end}${bright_white} Descargando archivo...${end} ${comment}name=${PATH_ARCHIVE##*/}${end}"
      s4vidownload
    elif "${update}"; then 
      log "${bright_green}${preffix} [${LINENO}] INFO${end} El archivo ${italic_style}${PATH_ARCHIVE##*/}${end} existe, pero vamos a ver si hay actualizaciones..."
      log "${bright_magenta}${preffix} [${LINENO}] DEBUG${end} Descargando archivo para realizar comparatorias...${comment} name=${TMP_ARCHIVE}${end}"
      s4viupdate 
    fi 
    exit 0 
  fi 

}

function advanced_search() {

  > "${p}"

  objects="${1}"
  if [[ -z "${objects}" ]]; then 
    
    messagebox \
      -title "Argumentos faltantes" \
      -message "Esta función requiere de al menos, un argumento" \
      -type Error

    helpPanel

    exit 1 

  fi 


  jq --arg bold_match "${bold_match}" --arg bold_style "${bold_style}" --arg color_matches "${color_matches}" --arg color "${color}" --arg italic_match "${italic_match}" --arg italic_style "${italic_style}" --arg underline_style "${underline_style}" --arg underline_match "${underline_match}"  --argjson terms "$(printf '%s\n' ${objects} | jq -R -s -c 'split("\n")[:-1]')" '

    def style($italic_match; $underline_match; $bold_match; $italic_style; $underline_style; $bold_style):

      {
        "true true true":    ($underline_style + $italic_style + $bold_style),
        "true true false":   ($underline_style + $italic_style),
        "true false true":   ($italic_style + $bold_style),
        "true false false":  ($italic_style),

        "false true true":   ($underline_style + $bold_style),
        "false true false":  ($underline_style),

        "false false true":  ($bold_style),
        "false false false": $color
      }[
        ($italic_match + " " + $underline_match + " " + $bold_match)
      ];


    def highlight_lines($s):
      $s
      | split("\n")
      | map(. as $line
          | if ($terms | map( . as $t | ($line | test($t; "il")) ) | any)
            then (
              if $color_matches == "false"
              then $line                

              else "\($color)" + style($italic_match; $underline_match; $bold_match; $italic_style; $underline_style; $bold_style) + $line + "\u001b[0m"  

              end
            )
            else $line
            end
        )
      | join("\n");

    [ .tutorials[]
      | (to_entries
          | map(select(.key != "ip" and .key != "videoUrl"))
          | map(.value | tostring)
          | join("\n")
        ) as $text
      | ($terms | map(. as $t | ($text | test($t; "il"))) | all) as $matched
      | select($matched)
      | (to_entries
          | map(
              if (.key != "ip" and .key != "videoUrl" and .key != "nombre" and .key != "ip" and .key != "sistemaOperativo" and .key != "dificultad")
              then .value |= tostring | .value |= highlight_lines(.)
              else .
              end
            )
          | from_entries
        )
    ]
  ' "${PATH_ARCHIVE}" > "${p}"

  jq 'map(
        .nombre           |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "") |
        .ip               |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "") |
        .dificultad       |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "") |
        .sistemaOperativo |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "")
      )' "${p}" | sponge "${p}" 2>/dev/null 
  
  results="$(jq -r '.[].nombre' ${p} | wc -l)"

  if [[ ${results} -eq 0 ]]; then  
    local msg=""
    read -a array <<< "$objects"

    for arg in "${array[@]}"; do 
      msg+="""
${icon_color}${icon}${end} ${bold_style}${arg}${end}"""
    done 


    messagebox \
      -title "Error" \
      -message "${bold}${bright_white}No se encontraron máquinas para los siguientes criterios: ${msg}${end}" \
      -type Error
    helpPanel
    rm "${p}" 2>/dev/null 
    exit 1 

  elif [[ "${results}" -eq 1 ]]; then 
    ./.process_machine.sh "$(jq -r '.[].nombre' "${p}")"
    rm "${p}"
    return 0
  fi 

  local preview 
  local b

  if ! "${color_matches}"; then 
    preview='./s4vimachines.sh -m ${1} | tail -n +3'
    b='enter:execute(./s4vimachines.sh -m ${1})+abort'
  else 
    preview='./.process_machine.sh ${1}'
    b='enter:execute(./.process_machine.sh ${1})+abort'

  fi 

  jq -r --arg white "${bright_white}" '
   .[] |
   (
     "\u001b[1;38;2;255;255;255m" + .nombre + "\u001b[0m" + "\t" +
     "\u001b[38;2;255;255;100m" + .ip + "\u001b[0m" + "\t" +
     "\u001b[38;2;255;255;150m" + .sistemaOperativo + "\u001b[0m" + "\t" +
     (
       if .dificultad == "Fácil" then "\u001b[38;2;100;255;100m"
       elif .dificultad == "Media" then "\u001b[38;2;255;255;100m"
       elif .dificultad == "Difícil" then "\u001b[38;2;255;100;100m"
       elif .dificultad == "Insane" then "\u001b[38;2;180;100;255m"
       else "\u001b[0m" end
     ) + .dificultad + "\u001b[0m" + "\t" +
     "\u001b[38;2;100;150;255m" + .videoUrl + "\u001b[0m"
   )
  ' "${p}" | column -t -s $'\t'  | \
   fzf --ansi \
       --header="Selecciona una máquina" \
       --preview="${preview}" \
       --preview-window="${prev:-right}":50% \
       --color=16 \
       --prompt="❯ " \
       --marker="✓ " \
       --ignore-case \
       --nth=1,2,3,4 \
       --style full \
       --bind "${b}"

  rm "${p}"
  return 0

}


function random_machine() {
  objects="${1}"
  #tput civis
  local value=0
  local spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

  # Si mandamos a buscar una máquina aleatoria y ya 
  function callout_withoutObjects(){

    machines="$(jq -r '.tutorials[].nombre' ${PATH_ARCHIVE})"

    # Buscamos una máquina al azar de todas las que pueden haber...
    machineName="$(jq -r '.tutorials[].nombre' "${PATH_ARCHIVE}" | shuf -n 1)"

    while [[ $value -le "${recoils}" ]]; do
        local spin=${spinner[$((value % ${#spinner[@]}))]}
        machineName=$(shuf -n 1 <<< "${machines}")
        echo -ne "\r\033[K${pink}${spin}${bright_white} Tu máquina elegida es: ${bright_cyan}\"$machineName\"${end}"
        ((value++))
        sleep 0.03
    done
    echo -ne "\r\033[K${pink}[+]${bright_white} Tu máquina elegida es: ${bright_cyan}\"$machineName\"${end}"; echo 

    searchMachine "${machineName}" | tail -n+3
    
    exit 0 

  }

  [[ -z "${objects}" ]] && callout_withoutObjects  

  # Si indicamos parametros haremos una busqueda avanzada que nos dara un total de máquinas. 
  # De todas esas máquinas elegiremos solo una.
  # Llegaremos aqui SOLO si indicamos que queremos color-matches

  function callout_withMatchesAndObjects(){

    > "${p}"

    jq --arg color_matches "${color_matches}" --arg color "${color}" --arg italic_match "${italic_match}" --arg italic_style "${italic_style}" --arg underline_style "${underline_style}" --arg underline_match "${underline_match}" --arg bold_match "${bold_match}" --arg bold_style "${bold_style}"  --argjson terms "$(printf '%s\n' ${objects} | jq -R -s -c 'split("\n")[:-1]')" '


    def style($italic_match; $underline_match; $bold_match; $italic_style; $underline_style; $bold_style):

      {
        "true true true":    ($underline_style + $italic_style + $bold_style),
        "true true false":   ($underline_style + $italic_style),
        "true false true":   ($italic_style + $bold_style),
        "true false false":  ($italic_style),

        "false true true":   ($underline_style + $bold_style),
        "false true false":  ($underline_style),

        "false false true":  ($bold_style),
        "false false false": $color
      }[
        ($italic_match + " " + $underline_match + " " + $bold_match)
      ];


      def highlight_lines($s):
        $s
        | split("\n")
        | map(. as $line
            | if ($terms | map( . as $t | ($line | test($t; "il")) ) | any)
              then (
                if $color_matches == "false"
                then $line                
                else "\($color)" + style($italic_match; $underline_match; $bold_match; $italic_style; $underline_style; $bold_style) + $line + "\u001b[0m"  
                end
              )
              else $line
              end
          )
        | join("\n");

      [ .tutorials[]
        | (to_entries
            | map(select(.key != "ip" and .key != "videoUrl"))
            | map(.value | tostring)
            | join("\n")
          ) as $text
        | ($terms | map(. as $t | ($text | test($t; "il"))) | all) as $matched
        | select($matched)
        | (to_entries
            | map(
                if (.key != "ip" and .key != "videoUrl")
                then .value |= tostring | .value |= highlight_lines(.)
                else .
                end
              )
            | from_entries
          )
      ]
    ' "${PATH_ARCHIVE}" > "${p}"

    jq 'map(
          .nombre           |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "") |
          .ip               |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "") |
          .dificultad       |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "") |
          .sistemaOperativo |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "")
        )' "${p}" | sponge "${p}"
  local total=$(jq -r '.[].nombre' "${p}" | wc -l 2>/dev/null) 

  if [[ -z "${total}" || "${total}" -eq 0 ]]; then 

    local msg=""
    read -a array <<< "$objects"

    for arg in "${array[@]}"; do 
      msg+="""
${icon_color}${icon}${end} ${bold_style}${arg}${end}"""
    done 

    messagebox \
      -title "Error" \
      -message "${bold}${bright_white}No se encontraron máquinas para los siguientes criterios: ${msg}${end}" \
      -type Error
    
    rm "${p}" 2>/dev/null

    helpPanel

    exit 1 
  fi 

  if [[ "${total}" -eq 1 ]]; then 
    local machineName="$(jq -r '.[].nombre' ${p})"
    searchMachine "${machineName}"
  else 

    local machines="$(jq -r '.[].nombre' ${p})"

    # Buscamos una máquina al azar de todas las que pueden haber...
    local machineName="$(jq -r '.[].nombre' "${p}" | shuf -n 1)"

    while [[ $value -le "${recoils}" ]]; do
        local spin=${spinner[$((value % ${#spinner[@]}))]}
        machineName=$(shuf -n 1 <<< "${machines}")
        echo -ne "\r\033[K${pink}${spin}${bright_white} Tu máquina elegida es: ${bright_cyan}\"$machineName\"${end}"
        ((value++))
        sleep 0.03
    done
    echo -ne "\r\033[K${pink}[+]${bright_white} Tu máquina elegida es: ${bright_cyan}\"$machineName\"${end}"; echo 
    results=$(jq -r --arg icon_color "${icon_color}" --arg icon "${icon}" --arg name "${machineName}" --arg blue "${bright_blue}" --arg end "${end}" --arg bright_cyan "${bright_cyan}" --arg bright_magenta "${bright_magenta}" --arg bright_white "${bright_white}" '

    .[]
    | select((.nombre | ascii_downcase) == ($name | ascii_downcase))
    | 
    (
      "\(.nombre)" as $n |
      "\(.certificaciones)" as $c |
      "\(.tecnicas)" as $t |
      "\(.videoUrl)" as $writeup |
      "\(.ip)" as $addr |
      "Nombre: \(.nombre)" as $line1 |
      "IP: \(.ip)" as $line2 |
      "SO: \(.sistemaOperativo)" as $line3 |
      "Dificultad: \(.dificultad)" as $line4 |

      [$line1, $line2, $line3, $line4] 

      | map(length) 
      | max as $maxLen |

      def pad($text): $text + (" " * ($maxLen - ($text | length))) ;

      def paint($text):
        ($text | split(":") | .[0] as $k | .[1] as $v |
          "\($bright_magenta)\($k):\($bright_white)\($v)\($blue)") ;

      "\($blue)╭" +
      "\\033]8;;\($writeup)\\033\\\\\($bright_cyan)\($n)\\033[0m\\033]8;;\\033\\\\" + "\($blue)─" + ("─" * (($maxLen + 2) - ($n | length))) + "─╮\n" +

      "│ " + "\($bright_magenta)▌\($blue)" + paint(pad($line2)) + " " + " │\n" +
      "│ " + "\($bright_magenta)▌\($blue)" + paint(pad($line3)) + " " + " │\n" +
      "│ " + "\($bright_magenta)▌\($blue)" + paint(pad($line4)) + " " + " │\n" +
      "╰" + ("─" * ($maxLen + 2)) + "──" + "╯\n" + 
      "\u001b[35mCertificaciones:\u001b[0m\n" +
      (($c // "") 
      | split("\n") 
      | map("\($icon_color)\($icon) \u001b[97m" + . + "\u001b[0m") 
      | join("\n")) +
      "\n\n\u001b[35mTécnicas:\u001b[0m\n" +

      (($t // "")
          | split("\n")
          | map("\($icon_color)\($icon) \u001b[97m" + . + "\u001b[0m")
          | join("\n")
        ) +
        "\n\n\u001b[35mVideo:\u001b[0m \u001b[97m\($writeup)\u001b[0m"
    )

    ' "${p:?Fatal error, variable p not exists!}") 

    echo -e "${results:-Sin Resultados}"
    
    rm "${p}" 2>/dev/null

  fi 



    exit 0

  }
  [[ "${objects}" && "${color_matches}" == true ]] && callout_withMatchesAndObjects
  
  

  function objectsCallout(){

    > "${p}"
    jq --arg color_matches "${color_matches}" --argjson terms "$(printf '%s\n' ${objects} | jq -R -s -c 'split("\n")[:-1]')" '
      def highlight_lines($s):
        $s
        | split("\n")
        | map(. as $line
            | if ($terms | map( . as $t | ($line | test($t; "il")) ) | any)
              then (
                if $color_matches == "false"
                then $line                # sin color
                else "\u001b[1;33m" + $line + "\u001b[0m"  # con color
                end
              )
              else $line
              end
          )
        | join("\n");

      [ .tutorials[]
        | (to_entries
            | map(select(.key != "ip" and .key != "videoUrl"))
            | map(.value | tostring)
            | join("\n")
          ) as $text
        | ($terms | map(. as $t | ($text | test($t; "il"))) | all) as $matched
        | select($matched)
        | (to_entries
            | map(
                if (.key != "ip" and .key != "videoUrl")
                then .value |= tostring | .value |= highlight_lines(.)
                else .
                end
              )
            | from_entries
          )
      ]
    ' "${PATH_ARCHIVE}" > "${p}"

    local total=$(jq -r '.[].nombre' "${p}" | wc -l 2>/dev/null) 

    if [[ -z "${total}" || "${total}" -eq 0 ]]; then 

      local msg=""
      read -a array <<< "$objects"

      for arg in "${array[@]}"; do 
        msg+="""
  ${icon_color}${icon}${end} ${bold_style}${arg}${end}"""
      done 

      messagebox \
        -title "Error" \
        -message "${bold}${bright_white}No se encontraron máquinas para los siguientes criterios: ${msg}${end}" \
        -type Error
      
      rm "${p}" 2>/dev/null

      helpPanel

      exit 1 

    fi 

    if [[ "${total}" -eq 1 ]]; then 
      local machineName="$(jq -r '.[].nombre' ${p})"
      searchMachine "${machineName}"
    else 

      local machines="$(jq -r '.[].nombre' ${p})"

      # Buscamos una máquina al azar de todas las que pueden haber...
      local machineName="$(jq -r '.[].nombre' "${p}" | shuf -n 1)"

      while [[ $value -le "${recoils}" ]]; do
          local spin=${spinner[$((value % ${#spinner[@]}))]}
          machineName=$(shuf -n 1 <<< "${machines}")
          echo -ne "\r\033[K${pink}${spin}${bright_white} Tu máquina elegida es: ${bright_cyan}\"$machineName\"${end}"
          ((value++))
          sleep 0.03
      done
      echo -ne "\r\033[K${pink}[+]${bright_white} Tu máquina elegida es: ${bright_cyan}\"$machineName\"${end}"; echo 

      searchMachine "${machineName}" | tail -n+3
      
      exit 0 

    fi 

    rm "${p}" >/dev/null
    
  }

  [[ "${objects}" ]] && objectsCallout

}

function Get_cert(){

  certificate="${1}"

  if [[ -z "${certificate}" ]]; then 
    
    messagebox \
      -title "Argumentos faltantes" \
      -message "Esta función requiere de al menos, un argumento" \
      -type Error

    helpPanel

    exit 1 

  fi 
  
  > "${p}"

  jq --arg bold_match "${bold_match}" --arg bold_style "${bold_style}" --arg color_matches "${color_matches}" --arg color "${color}" --arg italic_match "${italic_match}" --arg italic_style "${italic_style}" --arg underline_style "${underline_style}" --arg underline_match "${underline_match}"  --argjson terms "$(printf '%s\n' ${certificate} | jq -R -s -c 'split("\n")[:-1]')" '

    def style($italic_match; $underline_match; $bold_match; $italic_style; $underline_style; $bold_style):

      {
        "true true true":    ($underline_style + $italic_style + $bold_style),
        "true true false":   ($underline_style + $italic_style),
        "true false true":   ($italic_style + $bold_style),
        "true false false":  ($italic_style),

        "false true true":   ($underline_style + $bold_style),
        "false true false":  ($underline_style),

        "false false true":  ($bold_style),
        "false false false": $color
      }[
        ($italic_match + " " + $underline_match + " " + $bold_match)
      ];


    def highlight_lines($s):
      $s
      | split("\n")
      | map(. as $line
          | if ($terms | map( . as $t | ($line | test($t; "il")) ) | any)
            then (
              if $color_matches == "false"
              then $line                

              else "\($color)" + style($italic_match; $underline_match; $bold_match; $italic_style; $underline_style; $bold_style) + $line + "\u001b[0m"  

              end
            )
            else $line
            end
        )
      | join("\n");

    [ .tutorials[]
      | (to_entries
          | map(select(.key == "certificaciones"))
          | map(.value | tostring)
          | join("\n")
        ) as $text
      | ($terms | map(. as $t | ($text | test($t; "il"))) | all) as $matched
      | select($matched)
      | (to_entries
          | map(
              if (.key != "ip" and .key != "videoUrl" and .key != "nombre" and .key != "sistemaOperativo" and .key != "dificultad" and .key != "tecnicas")
              then .value |= tostring | .value |= highlight_lines(.)
              else .
              end
            )
          | from_entries
        )
    ]
  ' "${PATH_ARCHIVE}" > "${p}"

  jq 'map(
        .nombre           |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "") |
        .ip               |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "") |
        .dificultad       |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "") |
        .sistemaOperativo |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "")
      )' "${p}" | sponge "${p}" 2>/dev/null 
  

  total="$(jq -r '.[].nombre' ${p} | wc -l 2>/dev/null)"
  
  if [[ "${total}" -eq 0 ]]; then 

    local msg=""
    read -a array <<< "${certificate}"

    for arg in "${array[@]}"; do 
      msg+="""
${icon_color}${icon}${end} ${bold_style}${arg}${end}"""
    done 

    messagebox \
      -title "Error" \
      -message "${bold}${bright_white}No se encontraron máquinas para los siguientes criterios: ${msg}${end}" \
      -type Error
    helpPanel 
    rm "${p}" 2>/dev/null 
    exit 1 

  fi 
  
  if [[ "${total}" -eq 1 ]]; then 
    machineName=$(jq -r '.[].nombre' ${p})

    if "${color_matches}"; then 
      ./.process_machine.sh "${machineName}"
    else 
      searchMachine "${machineName}"
    fi 

    exit 0 
    rm "${p}" 2>/dev/null

  fi 

  if ! "${color_matches}"; then 
    preview='./s4vimachines.sh -m ${1} | tail -n +3'
    b='enter:execute(./s4vimachines.sh -m ${1})+abort'
  else 
    preview='./.process_machine.sh ${1}'
    b='enter:execute(./.process_machine.sh ${1})+abort'

  fi 


  jq -r --arg white "${bright_white}" '
   .[] |
   (
     "\u001b[1;38;2;255;255;255m" + .nombre + "\u001b[0m" + "\t" +
     "\u001b[38;2;255;255;100m" + .ip + "\u001b[0m" + "\t" +
     "\u001b[38;2;255;255;150m" + .sistemaOperativo + "\u001b[0m" + "\t" +
     (
       if .dificultad == "Fácil" then "\u001b[38;2;100;255;100m"
       elif .dificultad == "Media" then "\u001b[38;2;255;255;100m"
       elif .dificultad == "Difícil" then "\u001b[38;2;255;100;100m"
       elif .dificultad == "Insane" then "\u001b[38;2;180;100;255m"
       else "\u001b[0m" end
     ) + .dificultad + "\u001b[0m" + "\t" +
     "\u001b[38;2;100;150;255m" + .videoUrl + "\u001b[0m"
   )
  ' "${p}" | column -t -s $'\t'  | \
  fzf --ansi \
       --header="Selecciona una máquina" \
       --preview="${preview}" \
       --preview-window="${prev:-right}":50% \
       --color=16 \
       --prompt="❯ " \
       --marker="✓ " \
       --ignore-case \
       --nth=1,2,3,4 \
       --style full \
       --bind "${b}"

  rm "${p}"

}

function searchSkill(){

  skill="${1}"

  if [[ -z "${skill}" ]]; then 
    
    messagebox \
      -title "Argumentos faltantes" \
      -message "Esta función requiere de al menos, un argumento" \
      -type Error

    helpPanel

    exit 1 

  fi 

  
  > "${p}"

  jq --arg bold_match "${bold_match}" --arg bold_style "${bold_style}" --arg color_matches "${color_matches}" --arg color "${color}" --arg italic_match "${italic_match}" --arg italic_style "${italic_style}" --arg underline_style "${underline_style}" --arg underline_match "${underline_match}"  --argjson terms "$(printf '%s\n' ${skill} | jq -R -s -c 'split("\n")[:-1]')" '

    def style($italic_match; $underline_match; $bold_match; $italic_style; $underline_style; $bold_style):

      {
        "true true true":    ($underline_style + $italic_style + $bold_style),
        "true true false":   ($underline_style + $italic_style),
        "true false true":   ($italic_style + $bold_style),
        "true false false":  ($italic_style),

        "false true true":   ($underline_style + $bold_style),
        "false true false":  ($underline_style),

        "false false true":  ($bold_style),
        "false false false": $color
      }[
        ($italic_match + " " + $underline_match + " " + $bold_match)
      ];


    def highlight_lines($s):
      $s
      | split("\n")
      | map(. as $line
          | if ($terms | map( . as $t | ($line | test($t; "il")) ) | any)
            then (
              if $color_matches == "false"
              then $line                

              else "\($color)" + style($italic_match; $underline_match; $bold_match; $italic_style; $underline_style; $bold_style) + $line + "\u001b[0m"  

              end
            )
            else $line
            end
        )
      | join("\n");

    [ .tutorials[]
      | (to_entries
          | map(select(.key == "tecnicas"))
          | map(.value | tostring)
          | join("\n")
        ) as $text
      | ($terms | map(. as $t | ($text | test($t; "il"))) | all) as $matched
      | select($matched)
      | (to_entries
          | map(
              if(.key == "tecnicas") 
              then .value |= tostring | .value |= highlight_lines(.)
              else .
              end
            )
          | from_entries
        )
    ]
  ' "${PATH_ARCHIVE}" > "${p}"

  jq 'map(
        .nombre           |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "") |
        .ip               |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "") |
        .dificultad       |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "") |
        .sistemaOperativo |= gsub("(\u001b|\\\\u001b)\\[[0-9;]*[A-Za-z]"; "")
      )' "${p}" | sponge "${p}" 2>/dev/null 
  

  total="$(jq -r '.[].nombre' ${p} | wc -l 2>/dev/null)"
  
  if [[ "${total}" -eq 0 ]]; then 

    local msg=""
    read -a array <<< "${skill}"

    for arg in "${array[@]}"; do 
      msg+="""
${icon_color}${icon}${end} ${bold_style}${arg}${end}"""
    done 

    messagebox \
      -title "Error" \
      -message "${bold}${bright_white}No se encontraron máquinas para los siguientes criterios: ${msg}${end}" \
      -type Error
    helpPanel 
    rm "${p}" 2>/dev/null 
    exit 1 

  fi 

  
  if [[ "${total}" -eq 1 ]]; then 
    machineName=$(jq -r '.[].nombre' ${p})

    if "${color_matches}"; then 
      ./.process_machine.sh "${machineName}"
    else 
      searchMachine "${machineName}"
    fi 

    exit 0 
    rm "${p}" 2>/dev/null

  fi 

  if ! "${color_matches}"; then 
    preview='./s4vimachines.sh -m ${1} | tail -n +3'
    b='enter:execute(./s4vimachines.sh -m ${1})+abort'
  else 
    preview='./.process_machine.sh ${1}'
    b='enter:execute(./.process_machine.sh ${1})+abort'

  fi 


  jq -r --arg white "${bright_white}" '
   .[] |
   (
     "\u001b[1;38;2;255;255;255m" + .nombre + "\u001b[0m" + "\t" +
     "\u001b[38;2;255;255;100m" + .ip + "\u001b[0m" + "\t" +
     "\u001b[38;2;255;255;150m" + .sistemaOperativo + "\u001b[0m" + "\t" +
     (
       if .dificultad == "Fácil" then "\u001b[38;2;100;255;100m"
       elif .dificultad == "Media" then "\u001b[38;2;255;255;100m"
       elif .dificultad == "Difícil" then "\u001b[38;2;255;100;100m"
       elif .dificultad == "Insane" then "\u001b[38;2;180;100;255m"
       else "\u001b[0m" end
     ) + .dificultad + "\u001b[0m" + "\t" +
     "\u001b[38;2;100;150;255m" + .videoUrl + "\u001b[0m"
   )
  ' "${p}" | column -t -s $'\t'  | \
  fzf --ansi \
       --header="Selecciona una máquina" \
       --preview="${preview}" \
       --preview-window="${prev:-right}":50% \
       --color=16 \
       --prompt="❯ " \
       --marker="✓ " \
       --ignore-case \
       --nth=1,2,3,4 \
       --style full \
       --bind "${b}"

  rm "${p}"

}

function get_allMachines(){


  jq -r --arg white "${bright_white}" '
    .tutorials[] |
    (
      "\u001b[1;38;2;255;255;255m" + .nombre + "\u001b[0m" + "\t" +
      "\u001b[38;2;255;255;100m" + .ip + "\u001b[0m" + "\t" +
      "\u001b[38;2;255;255;150m" + .sistemaOperativo + "\u001b[0m" + "\t" +
      (
        if .dificultad == "Fácil" then "\u001b[38;2;100;255;100m"
        elif .dificultad == "Media" then "\u001b[38;2;255;255;100m"
        elif .dificultad == "Difícil" then "\u001b[38;2;255;100;100m"
        elif .dificultad == "Insane" then "\u001b[38;2;180;100;255m"
        else "\u001b[0m" end
      ) + .dificultad + "\u001b[0m" + "\t" +
      "\u001b[38;2;100;150;255m" + .videoUrl + "\u001b[0m"
    )
  ' "${PATH_ARCHIVE}" | column -t -s $'\t'  | \
    fzf --ansi \
        --header="Selecciona una máquina" \
        --preview './s4vimachines.sh -m {1} | tail -n +3' \
        --preview-window=${prev:-right}:50% \
        --color=16 \
        --prompt="❯ " \
        --marker="✓ " \
        --ignore-case \
        --nth=1,2,3,4 \
        --style full \
        --bind 'enter:execute(./s4vimachines.sh -m ${1})+abort'
    
  return 0
}

function validate_preview(){
  
  case "${prev}" in 
    up|down|left|right)
      true 
      ;; 
    *)
      messagebox \
        -title "Parametro invalido" \
        -message "El parametro de preview solo acepta 4 posibles modos para previsualización, el modo indicado no es valido en este momento." \
        -type Error
      helpPanel 
      exit 1 

  esac 

}

function main(){

  while [[ $1 ]]; do
    case $1 in
      -v|--verbose)
        verbose_mode=true
        ;;
      -y|--no-confirm)
        confirm_act=true
        ;;
      -m|--machine)
        machineName="$2"
        ((parameter_counter+=1))
        shift
        ;;
      -u|--update-db)
        ((parameter_counter+=2))
        ;;
      -i|--ip-adress)
        ip_addr="$2"
        ((parameter_counter+=3))
        shift
        ;;
      -d|--difficulty)
        difficulty="$2"
        ((parameter_counter+=4))
        ((target_difficulty+=1))
        shift
        ;;
      -o|--os)
        osSystem="$2"
        ((parameter_counter+=5))
        ((target_os+=1))
        shift
        ;;
      -w|--writeup)
        writeup="$2"
        ((parameter_counter+=6))
        shift
        ;;
      -c|--cert)
        certificate="$2"
        ((parameter_counter+=7))
        shift
        ;;
      -s|--skill)
        skill="$2"
        ((parameter_counter+=9))
        shift
        ;;
      -a|--all-machines)
        ((parameter_counter+=10))
        ;;
      --color-matches)
        color_matches=true
        ;; 
      -A|--Advanced-search)
        objects="$2"
        ((parameter_counter+=11))
        shift
        ;;
      --recoils)
        recoils_input="${2:?Missing parameter recoils}"
        recoils="${recoils_input}"
        ;;

      -r|--random-machine)
        objects="${2}"
        ((parameter_counter+=12))
        ;;
      --preview|--preview=)
        prev="${2}"

        validate_preview "${prev}"

        ;;
      -h|--help)
        helpPanel 
        exit 0
        ;;
      -*)
        messagebox -title "Parametro invalido" \
          -message "El parametro ${bold}${italic_style}${1}${end} no existe en este momento, vuelve a intentarlo mas tarde!" \
          -type Error
        helpPanel
        exit 1 
        ;;
    esac
    shift
  done


  if [[ ! -f "$PATH_ARCHIVE" && ! "$parameter_counter" -eq 2 ]]; then
    messagebox -title "Dependencias faltantes" \
      -message "${bright_white}Base de datos ${bold}(${PATH_ARCHIVE})${end}${bright_white} no encontrada, actualiza dependencias para usar el script.${end}" \
      -type Error 
    helpPanel
    exit 1
  elif [[ $parameter_counter -eq 2 ]]; then
    updatefiles
    exit 0
  fi

  shopt -s nocasematch

  if [[ $parameter_counter -eq 1 ]]; then
    searchMachine "$machineName"

  elif [[ $parameter_counter -eq 3 ]]; then
    searchForIp "${ip_addr}"

  elif [[ $parameter_counter -eq 4 ]]; then
    searchDifficulty "$difficulty"

  elif [[ $parameter_counter -eq 5 ]]; then
    searchOsSystem "$osSystem"

  elif [[ $parameter_counter -eq 6 ]]; then
    showLink "$writeup"

  elif [[ "$parameter_counter" -eq 7 ]]; then
    Get_cert "$certificate"

  elif [[ "$parameter_counter" -eq 9 ]]; then
    searchSkill "$skill"

  elif [[ "$parameter_counter" -eq 10 ]]; then
    get_allMachines

  elif [[ "$parameter_counter" -eq 11 ]]; then
    advanced_search "$objects"

  elif [[ "$parameter_counter" -eq 12 ]]; then
    random_machine "${objects}"

  else

    helpPanel

  fi
}

main "${@}"
