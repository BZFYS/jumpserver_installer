#!/bin/bash
#

BASE_DIR=$(cd "$(dirname "$0")";pwd)
PROJECT_DIR=$(dirname ${BASE_DIR})
source ${BASE_DIR}/utils.sh
action=$1
target=$2


function list_backup_tags(){
    docker images  | grep registry.fit2cloud | grep -E '20\d{4,}_\d{6,}' | awk '{ print $2 }' | sort | uniq
}


function backup_images(){
    echo
    echo ">>> 开始备份镜像"
    images=$(get_images)
    for i in ${images};do
        target_tag=$(date +'%Y%m%d_%H%M%S')
        target_image=${i/:${VERSION}/:${target_tag}}
        if [[ "${i}" != "${target_image}" ]];then
            echo "docker tag ${i} ${target_image}"
            docker tag ${i} ${target_image}
        fi
    done
}

function restore_images() {
    src_tag=$1
    images=$(get_images)
    for i in ${images};do
        src_image=${i/:${VERSION}/:${src_tag}}
        if [[ "${i}" == "${src_image}" ]];then
            continue
        fi
        docker image inspect ${src_image} &> /dev/null
        if [[ "$?" == "0" ]];then
            echo "docker tag ${src_image} ${i}"
            docker tag ${src_image} ${i}
        fi
    done
}

function main() {
    case "$action" in
    list)
       list_backup_tags
       ;;
    backup)
        backup_images
        ;;
    restore)
        restore_images ${target}
        ;;
    *)
        echo "Usage: $0 list|backup|restore"
        ;;
    esac
}

main