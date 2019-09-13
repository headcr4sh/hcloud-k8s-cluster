#!/usr/bin/env bash

set -euo pipefail

TF_OUTPUT=`terraform output -json`

# It is assumed, that your ~/.ssh/config file contains the following directive:
# Include ~/.ssh/config.d/*
if [[ ! -d ~/.ssh/config.d ]]; then
        mkdir -p ~/.ssh/config.d
fi

K8S_CLUSTER_NAME=`echo ${TF_OUTPUT} | jq -r '.kubernetes_cluster.value.name'`

echo "${TF_OUTPUT}" | jq -r '.ssh_access.value.public_key_openssh' > ~/.ssh/id_rsa_k8s-${K8S_CLUSTER_NAME}-admin.pub
chmod 0600 ~/.ssh/id_rsa_k8s-${K8S_CLUSTER_NAME}-admin.pub
echo "${TF_OUTPUT}" | jq -r '.ssh_access.value.private_key_pem' > ~/.ssh/id_rsa_k8s-${K8S_CLUSTER_NAME}-admin
chmod 0600 ~/.ssh/id_rsa_k8s-${K8S_CLUSTER_NAME}-admin


cat << EOF > ~/.ssh/config.d/k8s-${K8S_CLUSTER_NAME}-admin
Host `echo "${TF_OUTPUT}" | jq -r '.kubernetes_cluster.value.master_api_endpoint_hostname'` `echo "${TF_OUTPUT}" | jq -r '.kubernetes_cluster.value.master_api_endpoint_ipv4'`
        IdentityFile ~/.ssh/id_rsa_k8s-${K8S_CLUSTER_NAME}-admin
        User root
        ForwardAgent yes
EOF

if [[ ! -d ~/.kube/config.d ]]; then
	mkdir -p ~/.kube/config.d
fi
echo "${TF_OUTPUT}" | jq -r '.kubeconfig.value' > ~/.kube/config.d/${K8S_CLUSTER_NAME}.yaml
