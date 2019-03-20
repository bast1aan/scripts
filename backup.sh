#!/bin/sh

EXCLUDES=`cat <<EOF
snap
nobackup
tmp
.cache
EOF`

echo_existing_excludes() {
    #find if dirs actually exist
    for i in $EXCLUDES; do
        if [ -d $HOME/$i ]; then
            echo $i
        fi
    done;
}

echo_exclude_opts() {
    for i in $@; do
        echo -n "--exclude $i "
    done;
}

encrypted_encludes=`echo_existing_excludes | encfsctl encode --extpass="/bin/cat $HOME/.encfs_pwd" $HOME`

echo_exclude_opts $encrypted_encludes

#rsync -rlptvx --delete --exclude tmp --exclude .cache --exclude build \
#  --exclude snap --exclude .thunderbird --exclude nobackup \
#  --exclude .WebIde70/system --exclude .crypt-baardmans \
#  --exclude VirtualBox\ VMs --exclude Seafile \
#  /home/bastiaan/ nas:/vol/storage/t450s/home/bastiaan
#TODAY=`date +%Y_%m_%d`
## maak snapshot van backup
#ssh nas cp -al /vol/storage/t450s /vol/storage/snapshots/t450s/$TODAY
