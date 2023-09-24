#! /bin/bash
set -e

REPO="${1}"
SSH_KEY="${2}"

log() {
    echo -e "\033[0;32m${@}\033[0m"
}

apt-get -y update
apt-get -y install --no-install-recommends \
    ca-certificates \
    equivs \
    git \
    openssh-client

log "Cloning ${REPO}"
git clone --depth 1 https://github.com/${REPO}.git

log "Setting up SSH"
mkdir -p /root/.ssh
ssh-keyscan github.com > /root/.ssh/known_hosts
echo "${SSH_KEY}" > /root/.ssh/key
chmod -R go-rwx /root/.ssh
export GIT_SSH_COMMAND="ssh -i /root/.ssh/key"

log "Cloning lmd-linux/lmd-linux.github.io"
git clone --depth 1 git@github.com:lmd-linux/lmd-linux.github.io.git

log "Building ${REPO##*/}"
cd ${REPO##*/}/debian
equivs-build control

log "Publishing ${REPO##*/}"
for DEST in $(cat destination); do
    mkdir -p ../../lmd-linux.github.io/pool/${DEST}
    cp *.deb ../../lmd-linux.github.io/pool/${DEST}
done
cd ../../lmd-linux.github.io
git config user.name "lmd Linux"
git config user.email lmd.linux@gmail.com
git add .
git commit -m "Update packages for ${REPO}"
git push
