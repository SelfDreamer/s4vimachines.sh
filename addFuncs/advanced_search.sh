#!/bin/bash
source Colors.sh
# Hacer las comparaciones insensibles a mayúsculas y minúsculas
shopt -s nocasematch

[[ -z "$1" ]] && echo "${bright_red}[!] Es necesario que introduzcas al menos un argumento${end}"

# Archivo temporal para resultados
result_file="/tmp/machine_results"
> "$result_file"

# Variables para almacenar datos
machine_name=""
machine_data=""

while IFS= read -r line; do
    # Detectar nombre de la máquina
    if [[ $line =~ name:\ (.*) ]]; then
        machine_name="${BASH_REMATCH[1]}"
    fi
    
    # Acumular todos los datos de la máquina para buscar en ellos
    machine_data+="$line"$'\n'
    
    # Cuando encontramos una línea vacía, procesamos la máquina anterior
    if [[ -z "$line" ]]; then
        match_count=0
        for word in "$@"; do
            if [[ $machine_data =~ $word ]]; then
                ((match_count++))
            fi
        done
        
        # Si todas las palabras buscadas están en los datos de la máquina
        if [[ $match_count -eq $# ]]; then
            echo "$machine_name" >> "$result_file"
        fi
        
        # Resetear variables para la próxima máquina
        machine_name=""
        machine_data=""
    fi
done < /tmp/bundle.js

total_machines=$(wc -l "$result_file" | awk '{print $1}')

if [[ "$total_machines" -ge 1 ]]; then
  echo -e "${bright_cyan}[+]${bright_white} Máquinas encontradas:${bright_magenta} $total_machines${end}"
  echo
  tput setaf 6  # Color cian para los resultados
  cat "$result_file" | column
  tput sgr0     # Resetear color
  echo
else
  echo -e "\n${bright_red}[!] No se encontraron los siguientes matches: $*${end}\n"
  exit 1
fi

#rm -f "$result_file"
