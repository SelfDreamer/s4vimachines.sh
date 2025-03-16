#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Uso: $0 <certificación1> [<certificación2> ...]"
    exit 1
fi
source ./Colors.sh
# Hacer las comparaciones insensibles a mayúsculas y minúsculas
shopt -s nocasematch

# Archivos temporales
htb_file="/tmp/cert_htb"
vuln_file="/tmp/cert_vuln"
swigger_file="/tmp/cert_swigger"

# Limpiar archivos anteriores
> "$htb_file"
> "$vuln_file"
> "$swigger_file"

# Variables para almacenar datos
machine_name=""
platform=""
certs=""

while IFS= read -r line; do
    # Detectar la plataforma
    if [[ $line =~ platform:\ (.*) ]]; then
        platform="${BASH_REMATCH[1]}"
    fi

    # Detectar nombre de la máquina
    if [[ $line =~ name:\ (.*) ]]; then
        machine_name="${BASH_REMATCH[1]}"
    fi

    # Detectar certificaciones
    if [[ $line =~ certification:\ (.*) ]]; then
        certs="${BASH_REMATCH[1]}"
        
        match_count=0
        for word in "$@"; do
            if [[ $certs =~ $word ]]; then
                ((match_count++))
            fi
        done

        # Si todas las certificaciones dadas están en la máquina, la guardamos en la plataforma correspondiente
        if [[ $match_count -eq $# ]]; then
            case "$platform" in
                "HackTheBox") echo -e "${bright_green}$machine_name${end}" >> "$htb_file" ;;
                "VulnHub") echo -e "${bright_yellow}$machine_name${end}" >> "$vuln_file" ;;
                "PortSwigger") echo -e "${bright_cyan}$machine_name${end}" >> "$swigger_file" ;;
            esac
        fi
    fi
done < /tmp/bundle.js

get_total(){
  # Eliminar archivos temporales
  local total_htb=$(wc -l $htb_file | awk '{print $1}')
  local total_swigger=$(wc -l $swigger_file | awk '{print $1}')
  local total_vul=$(wc -l $vuln_file | awk '{print $1}')

  echo "$total_htb + $total_vul + $total_swigger" | bc
}

total_machines=$(get_total)
if [[ $total_machines -ge 1 ]]; then
  echo -e "${bright_cyan}[+]${bright_white} Máquinas encontradas:${bright_magenta} $total_machines${end}"
fi
# Mostrar los resultados en formato columnar
for file in "$htb_file" "$vuln_file" "$swigger_file"; do
    if [[ -s $file ]]; then
        echo -e "${bright_green}[+]${bright_white} Máquinas en la plataforma $(basename "$file" | cut -d'_' -f2 | tr 'a-z' 'A-Z'):"
        echo; /bin/cat "$file" | sort | column
        echo ""
    fi
done


rm -f /tmp/cert_*

