#!/bin/bash
#
# Start the web server and setup the VPN connection

declare -r REQUIRED_FILES="client.crt client.key ca.crt"
declare -rx MY_NAME="$(basename $0)"

# Points to the root dir of the virtual environment
declare -rx ROOT_DIR="$(dirname $(dirname $0))"

# Storage location is at /data/ for homeassistant docker containers
declare -r STORAGE_LOCATION=/data/

# points to the location of the configuration files
declare -r CLIENT_CONFIG_LOCATION=$ROOT_DIR/share/openvpnclient

# The uwsgi configuration file
declare -r UWSGI_CONFIG_FILE=${CLIENT_CONFIG_LOCATION}/openvpnclient.ini

# The options file is in the persistent storage of the docker container /data/
declare -r OPENVPN_OPTIONS=${STORAGE_LOCATION}/options.json

# Save the OpenVPN configuration in the persistent storage
declare -r OPENVPN_CONFIG=${STORAGE_LOCATION}/client.ovpn

########################################################################################################################
# Log to stdout
# Arguments:
#   A string or a list of strings
# Returns:
#   None
########################################################################################################################
function log(){
	local argv="$*"

	echo "[$(date +%Y.%m.%d-%H:%M:%S) | $$ : ${MY_NAME} ] $argv"
}

########################################################################################################################
# Initialize the tun interface for OpenVPN if not already available
# Arguments:
#   None
# Returns:
#   None
########################################################################################################################
function init_tun_interface(){
    # create the tunnel for the openvpn client

    mkdir -p /dev/net
    if [ ! -c /dev/net/tun ]; then
        mknod /dev/net/tun c 10 200
    fi
}

########################################################################################################################
# Read the user OpenVPN configuration and save it into the directory defined by CLIENT_CONFIG_LOCATION
# Globals:
#   CLIENT_CONFIG_LOCATION
# Arguments:
#   None
# Returns:
#   None
########################################################################################################################
function setup_openvpn_config(){

    # split up the entries in the config option into lines and write to the client configuration file
    cat ${OPENVPN_OPTIONS} | jq --raw-output '.config[]' > ${OPENVPN_CONFIG}

    chmod 777 ${OPENVPN_CONFIG}

}

########################################################################################################################
# Start our Flask-based web server using the virtual environment setup by the Dockerfile.
# Globals:
#   NAME
# Arguments:
#   None
# Returns:
#   None
########################################################################################################################
function start_webserver(){

    # The python virtual environment is inside the directory defined by $NAME in /
    source $ROOT_DIR/bin/activate

    log "Start the web server."

    # now we the the entry point defined by the application
    uwsgi ${UWSGI_CONFIG_FILE} --home ${ROOT_DIR}

}

########################################################################################################################
# Check if all required files are available.
# Globals:
#   REQUIRED_FILES
#   STORAGE_LOCATION
# Arguments:
#   None
# Returns:
#   0 if all files are available and 1 otherwise
########################################################################################################################
function check_files_available(){
    failed=0
    for file in ${REQUIRED_FILES}
    do
        if [[ ! -f ${STORAGE_LOCATION}/${file} ]]
        then
            log "File ${STORAGE_LOCATION}/${file} not found"
            failed=1
            break
        fi
    done

    if [[ ${failed} == 0 ]]
    then
        return 0
    else
        return 1
    fi


}
########################################################################################################################
# Wait until the user has uploaded all required certificates and keys in order to setup the VPN connection.
# Globals:
#   REQUIRED_FILES
#   CLIENT_CONFIG_LOCATION
# Arguments:
#   None
# Returns:
#   None
########################################################################################################################
function wait_configuration(){

    log "Wait until the user uploads the files."
    # therefore, wait until the user upload the required certification files
    while true; do

        check_files_available

        if [[ $? == 0 ]]
        then
            break
        fi

        sleep 5
    done
    log "All files available!"
}


init_tun_interface

# create the config directory if it does not exist
if [[ ! -d ${STORAGE_LOCATION} ]]
then
    mkdir -p ${STORAGE_LOCATION}
fi


setup_openvpn_config

# start the web server as background task
start_webserver &

# wait until the user uploaded the configuration files
wait_configuration

log "Setup the VPN connection with the following OpenVPN configuration."

cat ${OPENVPN_CONFIG}

# try to connect to the server using the used defined configuration
cd ${STORAGE_LOCATION} && openvpn --config ${OPENVPN_CONFIG}
