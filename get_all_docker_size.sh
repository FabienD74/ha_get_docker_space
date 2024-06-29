#!/bin/bash

function get_folder_size_kb(){
        FOLDER=$1
        FOLDER_SIZE=$(du -k -s $FOLDER |  awk -F ' ' '{print $1}'  )
        echo ${FOLDER_SIZE}
}

function get_docker_mounts(){
        docker inspect $1 | grep  "\"Source\": " | sed "s/^ *//" | sed "s/[\",]//g" | sort -u | awk -F ' ' '{print $2}' | grep -v "/dev"
}

function get_all_docker_names(){
        docker ps -a --format "{{.Names}}"
}
function get_report_lines(){
        ALL_DOCKERS=$(get_all_docker_names)
        for DOCKER in $ALL_DOCKERS
        do
                ALL_MOUNTS=$(get_docker_mounts $DOCKER )
                for MOUNT in ${ALL_MOUNTS}
                do
                        FOLDER_SIZE=$(get_folder_size_kb $MOUNT)
                        if [ "${FOLDER_SIZE}" -gt "1024" ]; then
                                echo "${DOCKER} ${MOUNT} ${FOLDER_SIZE} Kb"
                        fi
                done
        done
}


#####################
### Main program here

get_report_lines | grep -v "^addon.*homeassistant"
