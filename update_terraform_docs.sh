#!/bin/bash
# ==========================================================
# CONFIG (Global Variables)
# ==========================================================
# -e: option instructs bash to immediately exit if
# any command has a non-zero exit status
#set -e;

if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Linux
    ECHO_FLAGS="-e";
elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
    ECHO_FLAGS="";
else # Unknown OS
    echo "[!] Cannot be executed on this OS type: $OSTYPE! (requires UNIX-based OS)";
    exit 1;
fi

#-----------
#| General |:
#-----------
SCRIPT_FILENAME=$(basename $0);
PROJECT_DIR=$(dirname -- "$( readlink -f -- "$0"; )");
USER_PWD=$(pwd);

MODULES=( $(ls $PROJECT_DIR) );

# --------------------------------
# OUTPUT Colors
# --------------------------------
RED_OUTPUT='\033[0;31m';
GREEN_OUTPUT='\033[0;32m';
YELLOW_OUTPUT='\033[0;33m';
CYAN_OUTPUT='\033[0;36m';
COLOR_OFF='\033[0m';

# ==========================================================
# LIBRARY (Functions)
# ==========================================================
# ----------------------------------------------------------
# Logging
# Params: $@ - array<string>: a log message
# Return: None
function log() {
    local log_level="$1";
    shift;
    local message="$@";

    if [ "$log_level" == "verbose" ]; then
        echo >&2 "$@";
    elif [ "$log_level" == "error" ]; then
        echo $ECHO_FLAGS "${RED_OUTPUT}[!!! ERROR !!!]${COLOR_OFF}: $@" 1>&2;
    elif [ "$log_level" == "warning" ]; then
        echo $ECHO_FLAGS "${YELLOW_OUTPUT}[!!! WARNING !!!]${COLOR_OFF}: $@" 1>&2;
    elif [ "$log_level" == "success" ]; then
        echo $ECHO_FLAGS "${GREEN_OUTPUT}[!!! SUCCESS !!!]${COLOR_OFF}: $@" 1>&2;
    fi
}

# ========================================================
cd $PROJECT_DIR;

for module in ${MODULES[@]}; do
    if [ ! -d "$module" ]; then
        continue;
    fi

    if [ ! -f "$module/README.md" ]; then
        log "warning" "[$module] $module/README.md is absent";
        continue;
    fi

    log=$(terraform-docs -c .terraform-docs.yml $module 2>&1);
    if [ $? -ne 0 ]; then
        log "error" "[$module] $log";
    else
        log "success" "[$module] $log";
    fi
done

# Root README.md content:
cat <<EOF >README.md
# Terraform Modules

_This file is generated automatically by [$SCRIPT_FILENAME]($SCRIPT_FILENAME) script!_

**[Terraform Modules Overview](https://developer.hashicorp.com/terraform/language/modules)**

### Available modules:
$(
    for module in ${MODULES[@]}; do
        if [ ! -d "$module" ]; then
            continue;
        fi

        echo "- [$module]($module/README.md)";
    done
)
EOF

log "success" "README.md has been updated!";