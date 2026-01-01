#!/usr/bin/env bash
# Output machine results 
icon="  •"
icon_color="\u001b[93m"

# Matches 
color="\033[33m" # El color que recibira la linea donde esten los matches  
bold_match=false 
italic_match=false 
underline_match=false 

# Styles 
italic_style="\u001b[3m"
underline_style="\033[4m"
bold_style="\u001b[1m"

# From write script writed in **go**.
width=0
height=20
