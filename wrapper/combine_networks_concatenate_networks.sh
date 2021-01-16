#!/bin/bash

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
    h)
        usage
        exit 2
        ;;
    -)
        case "${OPTARG}" in
            p_net_np3_with_support)
                p_net_np3_with_support="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_net_np3_without_support)
                p_net_np3_without_support="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_net_np3_with_de)
                p_net_np3_with_de="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_net_np3_without_de)
                p_net_np3_without_de="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_net_np3)
                p_net_np3="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            l_top_edges_1)
                nargs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                l_top_edges_1=${nargs}
                if [ ${nargs} != "NONE" ]
                then
                    for (( i=1; i<`expr ${nargs}+1`;i++ ))
                    do
                        arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                        l_top_edges_1+=("${arg}")
                    done
                fi
                ;;
            l_top_edges_2)
                nargs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                l_top_edges_2=${nargs}
                if [ ${nargs} != "NONE" ]
                then
                    for (( i=1; i<`expr ${nargs} + 1`; i++ ))
                    do
                        arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                        l_top_edges_2+=("${arg}")
                    done
                fi
                ;;
            p_src_code)
                p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_out_tmp)
                p_out_tmp="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_out_net)
                p_out_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            flag_slurm)
                flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            flag_concat)
                flag_concat="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_in_dir_data)
                p_in_dir_data="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
            p_in_dir_pred)
                p_in_dir_pred="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                ;;
        esac;;
    esac
done

if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

echo "l_top_edges_1[@]: ${l_top_edges_1}"
echo "l_top_edges_2[@]: ${l_top_edges_2}"

source activate netprophet
ls -la /home/dabid/.conda/envs/netprophet/bin >> ${p_out_tmp}tmp.txt

if [ ${flag_concat} == "concat_cv" ]
then
    python ${p_src_code}code/combine_networks_concat_networks.py \
        --p_in_dir_data ${p_in_dir_data} \
        --p_in_dir_pred ${p_in_dir_pred} \
        --p_out_file ${p_net_np3}
elif [ ${flag_concat} == "concat_with_without_support" ]
then
    python ${p_src_code}code/combine_networks_concat_networks.py \
        --l_p_in_net ${p_net_np3_with_support} ${p_net_np3_without_support} \
        --p_out_file ${p_net_np3} \
        --flag_method "a"
  
elif [ ${flag_concat} == "concat_with_without_de" ]
then

    # Only without DE 
    if [ ${p_net_np3_with_de} == "NONE" ] && [ ${p_net_np3_without_de} != "NONE" ]
    then
        while [ ! -f ${p_net_np3_without_de} ]
        do
            sleep 10
        done
        sleep 120  # wait till it finishes writing the file
        cp ${p_net_np3_without_de} ${p_net_np3}
        if [ ${l_top_edges_2} != "NONE" ]
        then
            echo "l_top_edges_2: ${l_top_edges_2[@]}"
            for (( i=1;i<${#l_top_edges_2[@]};i++ ))
            do 
                while [ ! -f ${p_out_tmp}without_de/top_${l_top_edges_2[i]}/net_np3_${l_top_edges_2[i]}.tsv ]
                do
                    sleep 10
                done
                sleep 120  # wait till it finishes writing the file
                cp ${p_out_tmp}without_de/top_${l_top_edges_2[i]}/net_np3_${l_top_edges_2[i]}.tsv ${p_out_net}net_top_${l_top_edges_2[i]}.tsv
            done
        fi
    elif [ ${p_net_np3_with_de} != "NONE" ] && [ ${p_net_np3_without_de} == "NONE" ]
    then
        while [ ! -f ${p_net_np3_with_de} ]
        do
            sleep 10
        done
        sleep 120  # wait till it finishes writing the file
        cp ${p_net_np3_with_de} ${p_net_np3}
        
        if [ ${l_top_edges_1} != "NONE" ]
        then
            echo "l_top_edges_1: ${l_top_edges_1[@]}"
            for (( i=1;i<${#l_top_edges_1[@]};i++ ))
            do 
                while [ ! -f ${p_out_tmp}with_de/top_${l_top_edges_1[i]}/net_np3_${l_top_edges_1[i]}.tsv ]
                do
                    sleep 10
                done
                sleep 120
                cp ${p_out_tmp}with_de/top_${l_top_edges_1[i]}/net_np3_${l_top_edges_1[i]}.tsv ${p_out_net}net_top_${l_top_edges_1[i]}.tsv
            done
        fi
    else
        # Only with DE
        # Both with and without DE
        # the whole network..
        while [ ! -f ${p_net_np3_with_de} ] || [ ! -f ${p_net_np3_without_de} ]
        do
            sleep 10
        done
        sleep 120  # to wait for files to finish writing

        echo "- concat with and without DE for all edges.."
        python ${p_src_code}code/combine_networks_concat_networks.py \
            --l_p_in_net ${p_net_np3_with_de} ${p_net_np3_without_de} \
            --p_out_file ${p_net_np3} \
            --flag_method "a"

        # feed forward networks..
        if [ ${l_top_edges_1} != "NONE" ] & [ ${l_top_edges_2} != "NONE" ]
        then
            echo "l_top_edges_1: ${l_top_edges_1[@]}"
            echo "l_top_edges_2: ${l_top_edges_2[@]}"
            for (( i=1;i<${#l_top_edges_1[@]};i++ ))
            do
                while [ ! -f ${p_out_tmp}with_de/top_${l_top_edges_1[i]}/net_np3_${l_top_edges_1[i]}.tsv ] || [ ! -f ${p_out_tmp}without_de/top_${l_top_edges_2[i]}/net_np3_${l_top_edges_2[i]}.tsv ]
                do
                    sleep 10
                done
                sleep 120

                ((total=${l_top_edges_1[i]} + ${l_top_edges_2[i]}))
                echo "- concat with and without DE for ${l_top_edges_1[i]} and ${l_top_edges_2[i]}, total: ${total}.."
                python ${p_src_code}code/combine_networks_concat_networks.py \
                --l_p_in_net ${p_out_tmp}with_de/top_${l_top_edges_1[i]}/net_np3_${l_top_edges_1[i]}.tsv \
                             ${p_out_tmp}without_de/top_${l_top_edges_2[i]}/net_np3_${l_top_edges_2[i]}.tsv \
                --p_out_file ${p_out_net}net_top_${total}.tsv \
                --flag_method "a"
            done

        elif [ ${l_top_edges_1} != "NONE" ]
        then
            for (( i=2;i<=${#l_top_edges_1[@]};i++ ))
            do
                cp ${p_out_tmp}with_de/top_${l_top_edges_1[i]}/net_np3_${l_top_edges_1[i]}.tsv ${p_out_net}.
            done
        fi
    fi
fi
source deactivate netprophet