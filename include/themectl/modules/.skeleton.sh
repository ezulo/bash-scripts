# SKELETON FILE (not to be used directly)

#!/bin/echo Please-Source

#
# themectl module
# PRE-REQUISITE:
# your theme must have a subfolder named ${mod} contain configuration files.
# otherwise, your module is ignored.
#
# to create a module for a service, you must understand how that service
# is configured, and copy the appropriate files over accordingly.
#
# 3 functions are required to be defined with the following functions:
#
# ${mod}_theme:  copy theme configuration to service config directory
# ${mod}_reload  reload that service
# ${mod}_clean   revert that service to default configuration
#
# `themectl` assumes the function names. it is important you do not change
# their names.
#
# You are also responsible for function validation (missing commands etc.)
# 

ID="$_ID:${MOD}"

TC_${MOD}="$THEME_HOME/${mod}"
${MOD}_CONFIG_DIR="$XDG_CONFIG_DIR/${mod}"

# The commands to copy theme files to a service
${mod}_theme() {
    cp -r "$TC_${MOD}/*" 
}

# The command to reload the service, once themed
${mod}_reload() {
    echo "Do nothing"
}

# The command to un-theme a service
${mod}_clean() {
    rm -r $XDG_CONFIG_HOME/${mod}/theme/*
}

