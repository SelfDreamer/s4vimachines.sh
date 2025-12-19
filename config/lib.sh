source ../variables/global_variables.sh 2>/dev/null || source ./variables/global_variables.sh 2>/dev/null
readonly random="jq -r '.tutorials[].nombre' < ${PATH_ARCHIVE} | shuf -n1"
