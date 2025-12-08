#!/usr/bin/env bash

source ./variables/global_variables.sh
source ./Colors.sh
source ./config/appareance.sh

function search(){ 
  machineName="${1}"
  
  results=$(jq -r --arg icon_color "${icon_color}" --arg name "${machineName}" --arg blue "${bright_blue}" --arg end "${end}" --arg bright_cyan "${bright_cyan}" --arg icon "${icon}" --arg bright_magenta "${bright_magenta}" --arg bright_white "${bright_white}" '

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

}

search "${1:?}"
