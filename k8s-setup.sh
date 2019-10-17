#!/bin/bash

# Copyright 2018 The Caicloud Authors All rights reserved.

set -o errexit
set -o nounset

INVENTORY_FILE_NAME=inventory

KUBE_ROOT=$(dirname "{BASH_SOURCE}")
ANSIBLE_DEBS_DIR=${KUBE_ROOT}/ansible-debs


OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o "\w*"| head -n 1)

  case "${OS_NAME}" in
    "CentOS")
      echo ""
      echo "#### create local.repo"
      ./add_repo.sh
      sudo yum install -y ansible
    ;;
    "Kylin")
      
      ansible_debs="ansible_2.0.0.2-2kord_all.deb ieee-data_20150531.1kord_all.deb libyaml-0-2_0.1.6-3kord_amd64.deb python-crypto_2.6.1-6kord1_amd64.deb python-ecdsa_0.13-2kord_all.deb python-httplib2_0.9.1+dfsg-1kord_all.deb python-jinja2_2.8-1kord_all.deb python-markupsafe_0.23-2build2kord_amd64.deb python-netaddr_0.7.18-1kord_all.deb python-paramiko_1.16.0-1kord_all.deb python-pkg-resources_20.7.0-1kord_all.deb python-yaml_3.11-3kord1_amd64.deb sshpass.deb"
      echo "#### Check ansible if exists"
      ansible --version || (
      echo ""
      echo "#### Install ansible"
      cd ${ANSIBLE_DEBS_DIR}
      dpkg -i *
      cd -
      #for deb in ${ansible_debs}
      #do
      #  dpkg -i "${ANSIBLE_DEBS_DIR}/${deb}"
      #done
      )

    ;;
  
    *)
      echo "${OS_NAME} is not support ..."; exit 1
  esac


###close private key check
export ANSIBLE_HOST_KEY_CHECKING=False

#echo ""
#echo "#### 设置免密码认证"
#./addkey.sh


echo ""
echo "#### Make sure your inventory file is correct!"
cat ${INVENTORY_FILE_NAME}

echo "#### update hostname"
ansible-playbook -i ${INVENTORY_FILE_NAME} name.yml

echo ""
echo "#### Setup k8s cluster"
ansible-playbook -i ${INVENTORY_FILE_NAME}  k8s-cluster.yml
