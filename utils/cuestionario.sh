#!/usr/bin/env bash


declare -a QUESTIONS
declare -a OPTIONS_LIST 
declare -a USER_ANSWERS  
declare -a CURRENT_HOVER 

CURRENT_Q_INDEX=0
TOTAL_QUESTIONS=0

C_PURPLE="\033[38;5;212m"
C_MAGENTA="\033[0;95m"
C_GREEN="\033[32m"
C_GREY="\033[90m"
C_WHITE="\033[97m"
C_RESET="\033[0m"
BG_SELECTED="\e[45m"
BG_EMPTY="\e[100m"

# Iconos
ICON_CHECKED="◉"
ICON_UNCHECKED="○"
ICON_CURSOR="➜"

setup_terminal() {
    tput civis      
    stty -echo      
}

restore_terminal() {
    tput cnorm      
    stty echo       
    echo -e "${C_RESET}"
}

trap restore_terminal EXIT INT TERM

draw_header() {
    local title="${QUESTIONS[$CURRENT_Q_INDEX]}"
    

    echo -e "${C_MAGENTA}┌──────────────────────────────────────────────┐${C_RESET}\033[K"

    printf "${C_MAGENTA}│ PREGUNTA %d/%d : %-29s │${C_RESET}\033[K\n" "$((CURRENT_Q_INDEX + 1))" "$TOTAL_QUESTIONS" "..."
    echo -e "${C_MAGENTA}└──────────────────────────────────────────────┘${C_RESET}\033[K"
    
    echo -e "${C_WHITE}${title}${C_RESET}\033[K\n"
}

draw_options() {
    local raw_opts="${OPTIONS_LIST[$CURRENT_Q_INDEX]}"
    IFS=',' read -r -a opts_array <<< "$raw_opts"
    
    local hover_idx=${CURRENT_HOVER[$CURRENT_Q_INDEX]}
    local selected_idx=${USER_ANSWERS[$CURRENT_Q_INDEX]}

    local MAX_LINES_TO_CLEAR=6 
    
    for i in "${!opts_array[@]}"; do
        local opt_text=$(echo "${opts_array[$i]}" | xargs)
        
        local icon="${ICON_UNCHECKED}"
        local style="${C_GREY}"
        local cursor_ptr="  "

        if [[ "$selected_idx" == "$i" ]]; then
            icon="${ICON_CHECKED}"
            style="${C_GREEN}" 
        fi

        if [[ "$hover_idx" == "$i" ]]; then
            cursor_ptr="${C_PURPLE}${ICON_CURSOR} "
            if [[ "$selected_idx" == "$i" ]]; then
                 style="${C_PURPLE}" 
            else
                 style="${C_WHITE}" 
            fi
        fi


        printf "${cursor_ptr}${style}%s %s${C_RESET}\033[K\n" "$icon" "$opt_text"
    done
    
    local current_lines=${#opts_array[@]}
    for ((l=current_lines; l<MAX_LINES_TO_CLEAR; l++)); do 
        echo -e "\033[K" 
    done
}

draw_pagination() {
    echo -e "\n${C_GREY}Navegación:${C_RESET}\033[K"
    local line=""
    
    for ((i=0; i<TOTAL_QUESTIONS; i++)); do
        local label=" $((i+1)) "
        if [[ $i -eq $CURRENT_Q_INDEX ]]; then
            line+="${BG_SELECTED}${C_WHITE}${label}${C_RESET} "
        elif [[ "${USER_ANSWERS[$i]}" != "-1" ]]; then
            line+="\e[42m\e[30m${label}${C_RESET} "
        else
            line+="${BG_EMPTY}${C_WHITE}${label}${C_RESET} "
        fi
    done
    

    echo -e "$line\033[K"
    echo -e "${C_GREY}x: Seleccionar • Enter: Siguiente • ←/→: Preguntas • q: Salir${C_RESET}\033[K"
}



run_quiz() {
    setup_terminal

    for ((i=0; i<TOTAL_QUESTIONS; i++)); do
        CURRENT_HOVER[$i]=0
        USER_ANSWERS[$i]=-1 
    done

    while true; do
        tput cup 0 0
        draw_header
        draw_options
        draw_pagination

        read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
            case "$key" in
                '[A') 
                    local opts_count=$(echo "${OPTIONS_LIST[$CURRENT_Q_INDEX]}" | awk -F, '{print NF}')
                    ((CURRENT_HOVER[$CURRENT_Q_INDEX]--))
                    if [[ ${CURRENT_HOVER[$CURRENT_Q_INDEX]} -lt 0 ]]; then 
                        CURRENT_HOVER[$CURRENT_Q_INDEX]=$((opts_count - 1))
                    fi
                    ;;
                '[B') 
                    local opts_count=$(echo "${OPTIONS_LIST[$CURRENT_Q_INDEX]}" | awk -F, '{print NF}')
                    ((CURRENT_HOVER[$CURRENT_Q_INDEX]++))
                    if [[ ${CURRENT_HOVER[$CURRENT_Q_INDEX]} -ge $opts_count ]]; then 
                        CURRENT_HOVER[$CURRENT_Q_INDEX]=0
                    fi
                    ;;
                '[D') if [[ $CURRENT_Q_INDEX -gt 0 ]]; then ((CURRENT_Q_INDEX--)); fi ;;
                '[C') if [[ $CURRENT_Q_INDEX -lt $((TOTAL_QUESTIONS - 1)) ]]; then ((CURRENT_Q_INDEX++)); fi ;;
            esac
        
        elif [[ "$key" == "x" || "$key" == "X" ]]; then
            USER_ANSWERS[$CURRENT_Q_INDEX]=${CURRENT_HOVER[$CURRENT_Q_INDEX]}
            
        elif [[ "$key" == "" ]]; then 
            if [[ $CURRENT_Q_INDEX -lt $((TOTAL_QUESTIONS - 1)) ]]; then
                ((CURRENT_Q_INDEX++))
            fi
            
        elif [[ "$key" == "q" ]]; then
            break
        fi
    done
    
    tput cup $((12 + 5)) 0 
    for ((i=0; i<TOTAL_QUESTIONS; i++)); do
        local q_title="${QUESTIONS[$i]}"
        local ans_idx="${USER_ANSWERS[$i]}"
        local ans_text="No respondido"
        
        if [[ "$ans_idx" -ne -1 ]]; then
             IFS=',' read -r -a opts <<< "${OPTIONS_LIST[$i]}"
             ans_text="${opts[$ans_idx]}"
        fi
        echo -e "P$((i+1)): $q_title -> ${C_PURPLE}$ans_text${C_RESET}"
    done
}

load_data() {
    local raw_data="$1"
    IFS=';' read -r -a items <<< "$raw_data"
    for item in "${items[@]}"; do
        local title="${item%%|*}"
        local opts="${item#*|}"
        QUESTIONS+=("$title")
        OPTIONS_LIST+=("$opts")
    done
    TOTAL_QUESTIONS=${#QUESTIONS[@]}
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    DATA_STRING=""
    while [[ "${1}" ]]; do
        case "${1}" in
            -data) DATA_STRING="${2}"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [[ -z "$DATA_STRING" ]]; then
        DATA_STRING="¿Cual es la vulnerabilidad web más sencilla?|Path Traversal,SQL Injection,XSS Reflejado;"
        DATA_STRING+="¿Qué herramienta se usa para fuzzing web?|Nmap,Gobuster,Wireshark,Metasploit;"
        DATA_STRING+="¿Puerto por defecto de SSH?|80,443,21,22;"
        DATA_STRING+="¿Sistema Operativo favorito para Pentesting?|Windows,Kali Linux,MacOS,Ubuntu Server;"
        DATA_STRING+="¿Como derivas un XSS a un RCE?|Evadiendo el CSP,Tenemos que aprovechar que la flag HTTP Only este en false,Realizando un cookie hijacking,No se puede"
    fi

    load_data "$DATA_STRING"
    run_quiz
fi
