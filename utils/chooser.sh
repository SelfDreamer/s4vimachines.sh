#!/bin/bash

function chooser(){
    HEADER="\u001b[0;95mSelecciona una opción:\033[0m"
    OPTIONS=()
    CURSOR="> "
    COL_SELECTED="\033[38;5;212m" 
    blink_style=""
    
    checked="✓"
    unchecked="•"
    pending="󰥔" 

    MULTI_SELECT=false 
    SELECTED=0
    RAW_SELECTED="" 
    RAW_SELECTED_PENDING="" 

    declare -a CHECKED_STATUS

    while [[ "${1}" ]]; do 
        case "${1}" in 
            -header) HEADER="${2:?}"; shift 2 ;; 
            -options)
                RAW_OPTIONS="$2"
                OLD_IFS=$IFS; IFS=','; read -r -a TEMP_ARRAY <<< "$RAW_OPTIONS"; IFS=$OLD_IFS
                for opt in "${TEMP_ARRAY[@]}"; do
                    opt=$(echo "$opt" | xargs)
                    OPTIONS+=("$opt")
                done
                shift 2 
                ;;
            -cursor) CURSOR="${2:?}"; shift 2 ;; 
            -color-selected) COL_SELECTED="${2:?}"; shift 2 ;; 
            --no-limit) MULTI_SELECT=true; shift 1 ;;
            -selected) RAW_SELECTED="$2"; shift 2 ;;

            -selected-pending) RAW_SELECTED_PENDING="$2"; shift 2 ;; 
            -selected-prefix)
              checked=${2:?}
              shift 2 
              ;; 
            -unselected-prefix)
              unchecked="${2:?}"
              shift 2 
              ;;
            -pending-prefix)
              pending="${2:?}"
              shift 2
              ;; 
            -blink-cursor)
              blink_style="\033[0;5m"
              shift 1 
              ;; 
        esac 
    done 
    
    ICON_CHECKED="\033[32m${checked}\033[0m"  
    ICON_UNCHECKED="\033[2m${unchecked}\033[0m" 
    ICON_PENDING="\033[33m${pending}\033[0m"

    TOTAL_OPTIONS=${#OPTIONS[@]}
    
    for ((i=0; i<TOTAL_OPTIONS; i++)); do CHECKED_STATUS[$i]=0; done

    if [[ -n "$RAW_SELECTED" ]]; then
        OLD_IFS=$IFS; IFS=','; read -r -a PRE_SELECTED_ARRAY <<< "$RAW_SELECTED"; IFS=$OLD_IFS
        for pre_item in "${PRE_SELECTED_ARRAY[@]}"; do
            pre_item=$(echo "$pre_item" | xargs)
            for ((i=0; i<TOTAL_OPTIONS; i++)); do
                if [[ "${OPTIONS[$i]}" == "$pre_item" ]]; then
                    CHECKED_STATUS[$i]=1
                    break 
                fi
            done
        done
    fi

    if [[ -n "$RAW_SELECTED_PENDING" ]]; then
        OLD_IFS=$IFS; IFS=','; read -r -a PRE_PENDING_ARRAY <<< "$RAW_SELECTED_PENDING"; IFS=$OLD_IFS
        for pre_item in "${PRE_PENDING_ARRAY[@]}"; do
            pre_item=$(echo "$pre_item" | xargs)
            for ((i=0; i<TOTAL_OPTIONS; i++)); do
                if [[ "${OPTIONS[$i]}" == "$pre_item" ]]; then
                    CHECKED_STATUS[$i]=2 # Asignamos estado 2
                    break 
                fi
            done
        done
    fi

    echo -ne "\033[?25l" >&2 

    cleanup() { echo -ne "\033[?25h" >&2; }
    trap cleanup EXIT

    while true; do
        HEADER_PRINTED=$(printf "%b\033[K\n" "${HEADER}")
        HEADER_LINES=$(echo -n "$HEADER_PRINTED" | grep -c '^')
        
        printf "%b\033[K\n" "${HEADER}" >&2 

        for ((i=0; i<TOTAL_OPTIONS; i++)); do
            PREFIX=""
            SUFFIX="\033[0m"
            
            if [ "$MULTI_SELECT" = true ]; then
                if [ "${CHECKED_STATUS[$i]}" -eq 1 ]; then
                    STATE_ICON="${ICON_CHECKED}"      
                    TEXT_STYLE=""                     
                elif [ "${CHECKED_STATUS[$i]}" -eq 2 ]; then
                    STATE_ICON="${ICON_PENDING}"
                    TEXT_STYLE="\033[33m" 
                else
                    STATE_ICON="${ICON_UNCHECKED}"   
                    TEXT_STYLE="\033[2m"             
                fi
                STATE_ICON="${STATE_ICON} "
            else
                STATE_ICON=""
                TEXT_STYLE=""
            fi

            if [ $i -eq $SELECTED ]; then
                echo -e "${blink_style}${COL_SELECTED}${CURSOR}\033[0m${STATE_ICON}${COL_SELECTED}${OPTIONS[$i]}\033[0m\033[K" >&2
            else
                printf "%*s%b%b%s\033[0m\033[K\n" ${#CURSOR} "" "${STATE_ICON}" "${TEXT_STYLE}" "${OPTIONS[$i]}" >&2 
            fi
        done

        read -rsn1 key

        if [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key 
            case "$key" in
                '[A') ((SELECTED--)); if [ $SELECTED -lt 0 ]; then SELECTED=$((TOTAL_OPTIONS - 1)); fi ;;
                '[B') ((SELECTED++)); if [ $SELECTED -ge $TOTAL_OPTIONS ]; then SELECTED=0; fi ;;
            esac
        
        elif [[ "$key" == "x" && "$MULTI_SELECT" = true ]]; then
            if [ "${CHECKED_STATUS[$SELECTED]}" -eq 1 ]; then
                CHECKED_STATUS[$SELECTED]=0
            else
                CHECKED_STATUS[$SELECTED]=1
            fi
        
        elif [[ ("$key" == "d" || "$key" == "D") && "$MULTI_SELECT" = true ]]; then
            if [ "${CHECKED_STATUS[$SELECTED]}" -eq 2 ]; then
                CHECKED_STATUS[$SELECTED]=0
            else
                CHECKED_STATUS[$SELECTED]=2
            fi

        elif [[ "$key" == $'\x01' && "$MULTI_SELECT" = true ]]; then
             ALL_MARKED=true
             for ((i=0; i<TOTAL_OPTIONS; i++)); do
                if [ "${CHECKED_STATUS[$i]}" -eq 0 ]; then ALL_MARKED=false; break; fi
             done
             NEW_STATUS=1
             if [ "$ALL_MARKED" = true ]; then NEW_STATUS=0; fi
             for ((i=0; i<TOTAL_OPTIONS; i++)); do CHECKED_STATUS[$i]=$NEW_STATUS; done

        elif [[ $key == "" ]]; then
            break
        fi

        LINES_TO_CLEAR=$((TOTAL_OPTIONS + HEADER_LINES))
        echo -ne "\033[${LINES_TO_CLEAR}A" >&2
    done

      if [ "$MULTI_SELECT" = true ]; then
          local str_pending=""
          local str_selected=""
          local str_unselected=""

          for ((i=0; i<TOTAL_OPTIONS; i++)); do
              if [ "${CHECKED_STATUS[$i]}" -eq 2 ]; then
                  if [ -n "$str_pending" ]; then str_pending="${str_pending}, "; fi
                  str_pending+="${OPTIONS[$i]}"

              elif [ "${CHECKED_STATUS[$i]}" -eq 1 ]; then
                  if [ -n "$str_selected" ]; then str_selected="${str_selected}, "; fi
                  str_selected+="${OPTIONS[$i]}"

              else
                  if [ -n "$str_unselected" ]; then str_unselected="${str_unselected}, "; fi
                  str_unselected+="${OPTIONS[$i]}"
              fi
          done

          echo "${str_pending} | ${str_selected} | ${str_unselected}"
      else
          printf "%b\n" "${OPTIONS[$SELECTED]}"
      fi
}

function getoutput() {
    local raw_input="$1"
    local target="${2,,}" 
    target=$(echo "$target" | xargs)

    if [[ -z "$raw_input" ]]; then
        echo "Error: No se pasó data a getoutput (Argumento \$1 vacío)" >&2
        return 1
    fi

    IFS='|' read -r val_pending val_selected val_unselected <<< "$raw_input"

    local result=""

    case "$target" in
        *pending*|p)       
            result="$val_pending"
            ;;
        *unselected*|u)   
            result="$val_unselected"
            ;;
        *selected*|s)      
            result="$val_selected"
            ;;
        *)
            echo "Error: Flag '$target' no reconocida. Usa: 'selected', 'pending' o 'unselected'." >&2
            echo "Valores disponibles -> P: $val_pending | S: $val_selected | U: $val_unselected" >&2
            return 1
            ;;
    esac

    echo "$result" | xargs
}
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then 
    
    OUTPUT=$(chooser --no-limit \
        -options "Docker, Kubernetes, Terraform, Ansible, Jenkins, AWS CLI" \
        -selected "Docker" \
        -selected-pending "Ansible, Jenkins" \
        -header "\u001b[1;35mSelecciona las herramientas DevOps:\033[0m\n(x: seleccionar, d: pendiente)" \
        -color-selected "\033[38;5;212m" \
        -unselected-prefix "󰄱 " \
        -selected-prefix "󰱒 " \
        -pending-prefix "󰥔 " \
        -cursor "▌ " \
        -blink-cursor
      )

      selected=$(getoutput "${OUTPUT}" -selected)
      unselected=$(getoutput "${OUTPUT}" -unselected)
      pending=$(getoutput "${OUTPUT}" -pending)

      echo "Valores seleccionados: ${selected}"
      echo "Valores no seleccionados: ${unselected}"
      echo "Valores pendientes: ${pending}"

fi
