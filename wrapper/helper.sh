#!/bin/bash

function create_paths(){
    # parameters
    l_name_net=${1}
    prefix=${2}
    p_dir=${3}
    
    # create paths for network names
    IFS=',' read -ra l_name <<< "${l_name_net}"
    l_path_net="${p_dir}${prefix}_${l_name[0]}.tsv"


    for (( i=1;i<${#l_name[@]};i++ ))
    do
        l_path_net="${l_path_net},${p_dir}${prefix}_${l_name[i]}.tsv"
    done

    echo "${l_path_net}"
}