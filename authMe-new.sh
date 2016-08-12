#!/bin/bash
#for centos user must first install epel-release, sshpass, nmap, and pdsh (sshpass, nmap and pdsh are available from epel-release for CENTOS)
#usage ./authMe-new.sh

[[ -f ~/.ssh/id_rsa ]] || ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
KEY=`grep ssh-rsa ~/.ssh/id_rsa.pub -m 1`

# base64 encoded because we use this when sshing to nodes
ADD_SSH_KEY=$(base64 -w0 <<EOF
[[ -d ~/.ssh ]] || mkdir -m 700 -p ~/.ssh
[[ -f ~/.ssh/config ]] || ( umask 377; echo -e "Host *\nStrictHostKeyChecking no" > ~/.ssh/config )
[[ -f ~/.ssh/authorized_keys ]] || ( umask 177; touch ~/.ssh/authorized_keys )
if [[ \$(egrep '^SELINUX=' /etc/sysconfig/selinux | awk -F= '{print \$2}') == "enforcing" ]]; then
     [[ \$(restorecon -Rnvv ~/.ssh | wc -l) -eq 0 ]] || restorecon -FR ~/.ssh
fi
KEY="$KEY"
grep -q "\$KEY" ~/.ssh/authorized_keys || echo "\$KEY" >> ~/.ssh/authorized_keys
EOF
)

base64 -d <<< $ADD_SSH_KEY | sh

# chown azureuser:azureuser /home/azureuser/.ssh/config

uniquify() {
    sort -u $1 > $1~ && cp $1~ $1 && rm -f $1~
}

IPADDRS=`hostname -i`
USER=`id -nu`
HEADNODE=`hostname -s`
[[ $USER == "root" ]] && EUSER=azureuser || EUSER=$USER
export USER
export EUSER
a=0
while true; do
    if [[ $a == 3 ]]; then
        echo "Too many failed attempts."
        unset SSHPASS
        exit 1
    fi
    read -s -p "$EUSER@$HEADNODE Password: " SSHPASS
    echo ""
    export SSHPASS
    sshpass -e ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no $EUSER@localhost /bin/true && break
    echo "Incorrect Password."
    let a=$a+1
done

for IPADDR in $IPADDRS; do
    IPPRE=`echo $IPADDR | awk -F. '{ print $1"."$2"."$3 }'`
    # nmap is not a great way of getting hosts, but it'll have to do until we're using the cloud api for it.
    NMAP=`nmap -sn $IPPRE.* | grep $IPPRE`
    # only get things that look like IP addresses
    grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' <<< "$NMAP" >> ~/nodeips.txt
    # uniquify the nodeips.txt file
done

SSH_ID_UPDATE="base64 -d <<< $ADD_SSH_KEY | sh && echo RTN_\$?"
[[ $USER == "root" ]] && SSH_ID_UPDATE="sudo -S sh -c '$SSH_ID_UPDATE' <<< $SSHPASS"

ssh_id_update() {
    NODE=${1:-localhost}
    echo -n "ssh-id update for $USER@$NODE: "
    SUCCESS=$(sshpass -e ssh -t -o ConnectTimeout=5 $EUSER@$NODE $SSH_ID_UPDATE 2>&1)
    [[ $SUCCESS == *RTN_0* ]] && echo "[SUCCESS]" || echo "$SUCCESS"
}
export -f ssh_id_update
export SSH_ID_UPDATE

remote_yum_install() {
    NODE=${1:-localhost}
    echo -n "Updating packages on $NODE: "
    SUCCESS=$(ssh -o ConnectTimeout=5 $NODE 'yum -y install epel-release pdsh 2>&1 && echo RTN_$?')
    [[ $SUCCESS == *RTN_0* ]] && echo "[SUCCESS]" || echo "$SUCCESS"
}
export -f remote_yum_install

uniquify ~/nodeips.txt
xargs -a ~/nodeips.txt -I {} bash -c ssh_id_update\ {}
[[ $USER == "root" ]] && xargs -a ~/nodeips.txt -I {} bash -c remote_yum_install\ {}

unset SSHPASS
read -n1 -r -p "Press a key to continue..." key

pdcp -w ^$HOME/nodeips.txt -p $HOME/.ssh/id_rsa $HOME/.ssh/config .ssh/

# the nmap way of getting hostnames doesn't work without working hostname resolution. even with hostname resolution,
# be careful as the field number changes from version to version of nmap.
#awk '/\(/ { hn=$5; sub(/\..*/,"",hn); print hn }' <<< "$NMAP"

# don't really care for this way of getting node names, but until we can do it the "right" way, pdsh is the most accurate.
pdsh -N -w ^$HOME/nodeips.txt hostname -s >> ~/nodenames.txt
uniquify ~/nodenames.txt
