#!/bin/bash


GIT_REPO="git@github.com:iflan7744/gitops.git"
#KNOWN_HOSTS_FILE=$1
KEY_FILE=$1 #ssh-keygen private key

# setup flux namespace if not already created
kubectl apply -f /root/flux/namespace.yaml

# setup secret for KEY_FILE
kubectl create -n flux secret generic flux-git-deploy --from-file=identity=${KEY_FILE}
kubectl create -n flux secret generic helm-git-deploy --from-file=identity=${KEY_FILE}


# helm install
helm install flux \
        --wait \
        --version=0.6.2 \
        --set image.repository=weaveworks/flux \
        --set helmOperator.repository=weaveworks/helm-operator \
        --set helmOperator.create=true \
        --set helmOperator.createCRD=true \
        --set git.url="${GIT_REPO}" \
        --set git.branch=master \
        --set git.user="iflan7744" \
        --set git.email="iflan_mohamed@yahoo.com" \
        --set git.path="cluster" \
        --set git.pollInterval=3m \
        --set git.secretName=flux-git-deploy \
        --set memcached.maxItemSize=2m \
        --set helmOperator.configureRepositories.enable=false \
        --namespace flux \
        fluxcd/flux
