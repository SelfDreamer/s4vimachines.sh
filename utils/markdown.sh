#!/bin/bash

cadenas=( "➀" "➁" "➂" "➃" "➄" "➅" )

function rule(){
  printf '─%.0s' $(seq 1 $(tput cols))
}

get_visible_length() {
    local text="$1"
    local clean_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    echo ${#clean_text}
}

repeat_char() {
    local char="$1"
    local count="$2"
    if (( count > 0 )); then printf "%0.s$char" $(seq 1 $count); fi
}

render_table_dynamic() {
    local -a table_lines=("${@}")
    local -a clean_rows=()
    
    for line in "${table_lines[@]}"; do
        if [[ ! "$line" =~ ^[[:space:]]*\|?[-:\|[:space:]]+\|?[[:space:]]*$ ]]; then
            clean_line=$(echo "$line" | sed 's/^[[:space:]]*|//; s/|[[:space:]]*$//')
            clean_rows+=("$clean_line")
        fi
    done
    if [[ ${#clean_rows[@]} -eq 0 ]]; then return; fi

    declare -A col_widths
    local num_cols=0
    IFS='|' read -ra first_row_cols <<< "${clean_rows[0]}"
    num_cols=${#first_row_cols[@]}
    for ((i=0; i<num_cols; i++)); do col_widths[$i]=0; done

    for row in "${clean_rows[@]}"; do
        IFS='|' read -ra cols <<< "$row"
        for ((i=0; i<num_cols; i++)); do
            val=$(echo "${cols[$i]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            len=$(get_visible_length "$val")
            if (( len > col_widths[$i] )); then col_widths[$i]=$len; fi
        done
    done

    local C_TBL_BORD=$'\033[38;5;237m'
    local C_TBL_TXT=$'\033[38;5;250m'
    local C_TBL_HDR=$'\033[1;38;5;223m'
    local RESET=$'\033[0m'

    local top_border="${C_TBL_BORD}╭"
    local mid_border="${C_TBL_BORD}├"
    local bot_border="${C_TBL_BORD}╰"
    for ((i=0; i<num_cols; i++)); do
        width=$(( col_widths[$i] + 2 ))
        line=$(repeat_char "─" $width)
        top_border+="$line"; mid_border+="$line"; bot_border+="$line"
        if (( i < num_cols - 1 )); then top_border+="┬"; mid_border+="┼"; bot_border+="┴"; fi
    done
    top_border+="╮${RESET}"; mid_border+="┤${RESET}"; bot_border+="╯${RESET}"

    echo "$top_border"
    local row_idx=0
    for row in "${clean_rows[@]}"; do
        IFS='|' read -ra cols <<< "$row"
        printf "${C_TBL_BORD}│${RESET}"
        for ((i=0; i<num_cols; i++)); do
            val=$(echo "${cols[$i]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            val_len=$(get_visible_length "$val")
            padding=$(repeat_char " " $(( col_widths[$i] - val_len )))
            if [[ $row_idx -eq 0 ]]; then
                printf " ${C_TBL_HDR}%s${RESET}${padding} ${C_TBL_BORD}│${RESET}" "$val"
            else
                printf " ${C_TBL_TXT}%s${RESET}${padding} ${C_TBL_BORD}│${RESET}" "$val"
            fi
        done
        printf "\n"
        if [[ $row_idx -eq 0 ]]; then echo "$mid_border"; fi
        ((row_idx++))
    done
    echo "$bot_border"
}

markdown_render() {
  local EXPAND_MODE=0
  local LINE_NUMS_MODE=0
  local input=""

  while [[ -n "${1}" ]]; do
    case "${1}" in
      --code-block-expand) EXPAND_MODE=1; shift ;;
      --line-numbers-code-block) LINE_NUMS_MODE=1; shift ;;
      *) if [[ -z "$input" ]]; then input="${1}"; fi; shift ;;
    esac
  done

  local content=""
  if [[ -n "$input" ]]; then
      if [[ -f "$input" ]]; then content=$(cat "$input"); else content="$input"; fi
  elif [ -p /dev/stdin ]; then
      content=$(cat)
  else
      return 1
  fi

  rule_text=$(rule)
  local term_cols=$(tput cols 2>/dev/null)
  term_cols="${term_cols:-${FZF_PREVIEW_COLUMNS}}"

  BG_CODE=$'\033[48;5;236m' 
  TXT_CODE=$'\033[38;5;250m'
  C_COMMENT=$'\033[38;5;240m'      
  C_STRING=$'\033[38;5;149m'      
  C_NUM=$'\033[38;5;208m'          
  C_LINE_NUM=$'\033[38;5;239m'    
  C_PY_KEY=$'\033[38;5;197m'      
  C_PY_FUNC=$'\033[38;5;39m'      
  C_PY_CLASS=$'\033[1;38;5;214m'  
  C_PY_DEC=$'\033[3;38;5;51m'     
  C_PY_SELF=$'\033[3;38;5;203m'    
  C_SH_CMD=$'\033[1;38;5;39m'      
  C_SH_KEY=$'\033[38;5;197m'      
  C_SH_VAR=$'\033[38;5;214m'      
  C_SH_FLAG=$'\033[38;5;51m'      
  C_SH_OP=$'\033[38;5;203m'        
  C_BORDE=$'\033[38;5;240m'
  BOLD=$'\033[1m'
  ITALIC=$'\033[3m'
  RESET=$'\033[0m'
  LIST_BULLET=$'\033[1;32m•\033[0m'
  HDR_COLOR=$'\033[1;34m'
  
  C_LINK_TXT=$'\033[1;34m'
  C_LINK_URL=$'\033[38;5;237m'
  C_IMG=$'\033[38;5;214m'
  C_QUOTE=$'\033[38;5;248m'
  CHECK_YES=$'\033[1;32m☑\033[0m'
  CHECK_NO=$'\033[38;5;240m☐\033[0m'
  
  declare -a code_buffer
  declare -a table_buffer 
  local max_line_len=0
  local in_code_block=0
  local in_table_block=0 
  local current_lang=""

  printf "%s\n" "$content" | sed -E "
    s/^[[:space:]]*\`\`\`(.*)/__CODE_FENCE__\1/
    :a; s/^([[:space:]]*([[:space:]]*▌[[:space:]]*)*)>[[:space:]]?/\1▌ /; ta

    /^__CODE_FENCE__/,/^__CODE_FENCE__/ ! {
        s|^[[:space:]]*<[hH]1>[[:space:]]*(.*)[[:space:]]*</[hH]1>.*$|__HDR__#__TXT__\1|
        s|^[[:space:]]*<[hH]2>[[:space:]]*(.*)[[:space:]]*</[hH]2>.*$|__HDR__##__TXT__\1|
        s/^(#{1,6})[[:space:]]+(.*)/__HDR__\1__TXT__\2/
        
        # --- NUEVOS MARCADORES (Mejoras) ---
        s/!\[([^]]+)\]\(([^)]+)\)/__IMG__\1__URL_START__\2__URL_END__/g
        s/\[([^]]+)\]\(([^)]+)\)/__LNK__\1__LNK_END__ (__URL_START__\2__URL_END__)/g
        s/^[[:space:]]*[-*][[:space:]]+\[[xX]\] (.*)/__CHK_Y__ \1/
        s/^[[:space:]]*[-*][[:space:]]+\[[[:space:]]\] (.*)/__CHK_N__ \1/
        
        # Estilos Inline básicos
        s/\*\*(.*?)\*\*/__BOLD__\1__RST__/g
        s/\*(.*?)\*/__ITAL__\1__RST__/g
        s/\`([^\`]+)\`/\\__CODE__\1__RST__/g
        s/^-{3,}$/__HR__/g
        s/^[\*\-] (.*)/ __LIST__ \1/g
    }
  " | while IFS= read -r line; do
   
    if [[ $in_code_block -eq 0 && "$line" =~ ^[[:space:]]*\| ]]; then
        in_table_block=1
        line="${line//__BOLD__/$BOLD}"
        line="${line//__RST__/$RESET}"
        line="${line//__CODE__/$BG_CODE}"
        table_buffer+=("$line")
        continue
    elif [[ $in_table_block -eq 1 ]]; then
        render_table_dynamic "${table_buffer[@]}"
        table_buffer=()
        in_table_block=0
    fi

    if [[ "$line" =~ __CODE_FENCE__(.*) ]]; then
        lang="${BASH_REMATCH[1]}"
        lang=$(echo "$lang" | xargs)
        [[ -z "$lang" ]] && lang="Code"

        if [[ $in_code_block -eq 1 ]]; then
            max_content_allowed=$(( term_cols - 6 ))
            declare -a wrapped_buffer
            for raw_line in "${code_buffer[@]}"; do
                if (( ${#raw_line} > max_content_allowed )); then
                    while IFS= read -r part; do
                        wrapped_buffer+=("$part")
                    done <<< "$(printf "%s\n" "$raw_line" | fold -s -w $max_content_allowed)"
                else
                    wrapped_buffer+=("$raw_line")
                fi
            done
            code_buffer=("${wrapped_buffer[@]}")
            
            max_line_len=0
            for l in "${code_buffer[@]}"; do
                if (( ${#l} > max_line_len )); then max_line_len=${#l}; fi
            done

            gutter_width=0
            if [[ $LINE_NUMS_MODE -eq 1 ]]; then
                total_lines=${#code_buffer[@]}
                chars_in_num=${#total_lines}
                gutter_width=$(( chars_in_num + 2 ))
            fi
            
            if [[ $EXPAND_MODE -eq 1 ]]; then 
                box_width=$term_cols
            else
                box_width=$(( max_line_len + 6 + gutter_width ))
                min_width=$(( ${#current_lang} + 7 ))
                if (( box_width < min_width )); then box_width=$min_width; fi
                if (( box_width > term_cols )); then box_width=$term_cols; fi
            fi
            
            top_fill_len=$(( box_width - ${#current_lang} - 5 ))
            if (( top_fill_len < 0 )); then top_fill_len=0; fi
            top_fill=$(printf '─%.0s' $(seq 1 $top_fill_len))
            printf "${BG_CODE}${C_BORDE}╭─ ${TXT_CODE}%s${C_BORDE} %s╮${RESET}\n" "$current_lang" "$top_fill"
            
            line_cnt=1
            for raw_line in "${code_buffer[@]}"; do
                colored_line="$raw_line"
                
                if [[ "$current_lang" == "python" ]]; then
                      colored_line=$(printf "%s\n" "$colored_line" | sed -E "
                        :a
                        s/^([^#]*)\"([^\"#]*)#([^\"]*)\"/\1\"\2__HASH__\3\"/
                        ta
                        :b
                        s/^([^#]*)'([^'#]*)#([^']*)'/\1'\2__HASH__\3'/
                        tb
                        s/(\"[^\"]*\")/\\x02\1\\x03/g
                        s/('[^']*')/\\x02\1\\x03/g
                        s/(#.*)/__COM__\1/
                        s/(__COM__.*)def/\1d@ef/g
                        s/(__COM__.*)class/\1c@lass/g
                        s/(__COM__.*)import/\1i@mport/g
                        s/(__COM__.*)from/\1f@rom/g
                        s/(__COM__.*)return/\1r@eturn/g
                        s/(__COM__.*)self/\1s@elf/g
                        s/(@[a-zA-Z0-9_.]+)/__MK_DEC__\1__MK_END__/g
                        s/\b(__[a-z0-9_]+__)\b/__MK_MAG__\1__MK_END__/g
                        s/\bclass[[:space:]]+([a-zA-Z0-9_]+)/class __MK_CLS__\1__MK_END__/g
                        s/\b([0-9]+\.?[0-9]*)\b/__MK_NUM__\1__MK_END__/g
                        s/\b(and|as|assert|async|await|break|class|continue|def|del|elif|else|except|finally|for|from|global|if|import|in|is|lambda|nonlocal|not|or|pass|raise|return|try|while|with|yield)\b/__MK_KEY__\1__MK_END__/g
                        s/\b(True|False|None)\b/__MK_NUM__\1__MK_END__/g
                        s/\b(print|len|range|open|str|int|float|list|dict|set|super|type|enumerate|zip|input)\b/__MK_BLT__\1__MK_END__/g
                        s/\b(self|cls|Literal|TypedDict|Self)\b/__MK_SLF__\1__MK_END__/g
                        s/([a-zA-Z0-9_]+)(\()/__MK_FUNC__\1__MK_END__\2/g
                        s/d@ef/def/g
                        s/c@lass/class/g
                        s/i@mport/import/g
                        s/f@rom/from/g
                        s/r@eturn/return/g
                        s/s@elf/self/g
                        s/__COM__(.*)/__MK_COM__\1__MK_END__/g
                        s/\x02(.*)\x03/__MK_STR__\1__MK_END__/g
                    ")
                    colored_line="${colored_line//__MK_COM__/${C_COMMENT}}"
                    colored_line="${colored_line//__MK_STR__/${C_STRING}}"
                    colored_line="${colored_line//__MK_DEC__/${C_PY_DEC}}"
                    colored_line="${colored_line//__MK_MAG__/${C_MAGIC}}"
                    colored_line="${colored_line//__MK_CLS__/${C_PY_CLASS}}"
                    colored_line="${colored_line//__MK_NUM__/${C_NUM}}"
                    colored_line="${colored_line//__MK_KEY__/${C_PY_KEY}}"
                    colored_line="${colored_line//__MK_BLT__/${C_BUILTIN}}"
                    colored_line="${colored_line//__MK_SLF__/${C_PY_SELF}}"
                    colored_line="${colored_line//__MK_FUNC__/${C_PY_FUNC}}"
                    colored_line="${colored_line//__MK_END__/${TXT_CODE}}"
                    colored_line="${colored_line//__HASH__/#}"

                elif [[ "$current_lang" == "bash" || "$current_lang" == "sh" ]]; then
                      colored_line=$(printf "%s\n" "$colored_line" | sed -E "
                        :a
                        s/^([^#]*)\"([^\"#]*)#([^\"]*)\"/\1\"\2__HASH__\3\"/
                        ta
                        s/(\"[^\"]*\")/\\x02\1\\x03/g
                        s/('[^']*')/\\x02\1\\x03/g
                        s/(#.*)/__COM__\1/
                        s/(__COM__.*)if/\1i@f/g
                        s/(__COM__.*)then/\1t@hen/g
                        s/(__COM__.*)echo/\1e@cho/g
                        s/(__COM__.*)local/\1l@ocal/g
                        s/(\\\$[a-zA-Z0-9_?@*#{}-]+)/__MK_VAR__\1__MK_END__/g
                        s/[[:space:]](-[a-zA-Z0-9_-]+)/ __MK_FLG__\1__MK_END__/g
                        s/(&&|\|\||\|)/__MK_OP__\1__MK_END__/g
                        s/\b(if|then|else|elif|fi|case|esac|for|select|while|until|do|done|in|function|time)\b/__MK_KEY__\1__MK_END__/g
                        s/\b(echo|printf|read|cd|pwd|pushd|popd|dirs|let|eval|exec|set|unset|export|declare|typeset|local|readonly|getopts|source|shift|test|exit|return|break|continue|alias|cat|grep|sed|awk|find|ls|mkdir|rm|touch|chmod|chown)\b/__MK_CMD__\1__MK_END__/g
                        s/i@f/if/g
                        s/t@hen/then/g
                        s/e@cho/echo/g
                        s/l@ocal/local/g
                        s/__COM__(.*)/__MK_COM__\1__MK_END__/g
                        s/\x02(.*)\x03/__MK_STR__\1__MK_END__/g
                    ")
                    colored_line="${colored_line//__MK_COM__/${C_COMMENT}}"
                    colored_line="${colored_line//__MK_STR__/${C_STRING}}"
                    colored_line="${colored_line//__MK_VAR__/${C_SH_VAR}}"
                    colored_line="${colored_line//__MK_FLG__/${C_SH_FLAG}}"
                    colored_line="${colored_line//__MK_OP__/${C_SH_OP}}"
                    colored_line="${colored_line//__MK_KEY__/${C_SH_KEY}}"
                    colored_line="${colored_line//__MK_CMD__/${C_SH_CMD}}"
                    colored_line="${colored_line//__MK_END__/${TXT_CODE}}"
                    colored_line="${colored_line//__HASH__/#}"
                
                else
                    colored_line=$(printf "%s\n" "$colored_line" | sed -E "
                        s/(\"[^\"]*\")/\\x02\1\\x03/g
                        s/('[^']*')/\\x02\1\\x03/g
                        s/(#.*)/__COM__\1/
                        s/(\/\/.*)/__COM__\1/
                        s/\b([0-9]+\.?[0-9]*)\b/__MK_NUM__\1__MK_END__/g
                        s/__COM__(.*)/__MK_COM__\1__MK_END__/g
                        s/\x02(.*)\x03/__MK_STR__\1__MK_END__/g
                    ")
                    colored_line="${colored_line//__MK_COM__/${C_COMMENT}}"
                    colored_line="${colored_line//__MK_STR__/${C_STRING}}"
                    colored_line="${colored_line//__MK_NUM__/${C_NUM}}"
                    colored_line="${colored_line//__MK_END__/${TXT_CODE}}"
                fi

                line_prefix=""
                if [[ $LINE_NUMS_MODE -eq 1 ]]; then
                    line_prefix=$(printf "${C_LINE_NUM} %*d " $chars_in_num $line_cnt)
                fi

                raw_len=${#raw_line}
                padding_needed=$(( box_width - raw_len - 3 - gutter_width ))
                if (( padding_needed > 0 )); then pad_spaces=$(printf '%*s' $padding_needed ""); else pad_spaces=""; fi
                
                printf "${BG_CODE}${C_BORDE}│${line_prefix} ${TXT_CODE}%s${BG_CODE}%s${C_BORDE}│${RESET}\n" "${colored_line}" "${pad_spaces}"
                
                ((line_cnt++))
            done

            bottom_fill_len=$(( box_width - 2 ))
            if (( bottom_fill_len < 0 )); then bottom_fill_len=0; fi
            bottom_fill=$(printf '─%.0s' $(seq 1 $bottom_fill_len))
            printf "${BG_CODE}${C_BORDE}╰%s╯${RESET}\n" "$bottom_fill"

            in_code_block=0
            code_buffer=()
            max_line_len=0
            
        else
            in_code_block=1
            current_lang="$lang"
            code_buffer=()
            max_line_len=0
        fi
        continue
    fi

    if [[ $in_code_block -eq 1 ]]; then
        line_no_tabs="${line//$'\t'/    }"
        code_buffer+=("$line_no_tabs")
        continue
    fi

    line="${line//__BOLD__/$BOLD}"
    line="${line//__ITAL__/$ITALIC}"
    line="${line//__CODE__/$BG_CODE}"
    line="${line//__RST__/$RESET}"
    line="${line//__HR__/$rule_text}"
    line="${line//__LIST__/$LIST_BULLET}"
    line="${line//__QUOTE__/${C_BORDE}▌${RESET}$ITALIC }"
    
    line="${line//__IMG__/${C_IMG}🖼 }"
    line="${line//__LNK__/${C_LINK_TXT}}"
    line="${line//__LNK_END__/${RESET}}"
    line="${line//__URL_START__/${C_LINK_URL}}"
    line="${line//__URL_END__/${RESET}}"
    line="${line//__CHK_Y__/$CHECK_YES}"
    line="${line//__CHK_N__/$CHECK_NO}"

    if [[ "$line" =~ __HDR__(#{1,6})__TXT__(.*) ]]; then
        level=${#BASH_REMATCH[1]}
        text="${BASH_REMATCH[2]}"
        icon="${cadenas[$((level-1))]}"
        printf "%s%s%s %s%s%s\n" $'\n' "${HDR_COLOR}" "${icon}" "${BOLD}" "${text}" "${RESET}"
    else
        printf "%s\n" "$line"
    fi
  done
  
  if [[ ${#table_buffer[@]} -gt 0 ]]; then
      render_table_dynamic "${table_buffer[@]}"
  fi
  
  printf "%s\n" "${RESET}"
}

function main(){

  md_text='''# Titulo
Este es un comentario normal 

---

<h1> titulo HTML </h1>

**Bloque de código** en el la siguiente `linea`:

```python 
#!/usr/bin/env python3 
import os, sys 

class OSsystem():
  
  def __init__(self, value=None):
    self.value = value 

  def _list(self, path: str):
    return os.listdir(path)

def main() -> None:
  
  s = OSsystem()
  files = s._list()
  for file in files:
    print(file)
    
  sys.exit(1)


if __name__ == '__main__':
  main()

```

  '''
  
  markdown_render "${md_text}" --code-block-expand --line-numbers-code-block  

  return 0 
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then 
  main 
fi 

