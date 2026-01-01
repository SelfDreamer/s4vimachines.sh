#!/usr/bin/env bash
# Variables globales
export url='https://infosecmachines.io/api/machines'
PATH_ARCHIVE="$HOME/.local/share/s4vimachines/bundle.js"
TMP_ARCHIVE="$PATH_ARCHIVE.tmp"
DIRECTORY="$HOME/.local/share/s4vimachines/"
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
target_os=0
target_difficulty=0
declare -i recoils=100
color_matches=false

p="/tmp/.test.json"


border="\033[38;2;130;160;200m"   
header="\033[1;38;2;150;180;255m" 
opt="\033[1;38;2;255;200;130m"    
reset="\033[0m"
green_water="\033[1;38;2;140;230;200m"   
light_blue="\033[1;38;2;110;200;255m"    
birght_white="\u001b[0;97m"
comment="\u001b[38;2;95;95;95m"
subrayado="\033[4m"

# PATH ROADMAP 
path_roadmap="${PATH_ARCHIVE%/*}/s4vi_roadmap"
take_note=false
