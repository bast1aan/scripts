#!/bin/sh

# Script to synchronize homedir to external host, encrypted by 
# encfs --reverse.
# With extra feature to exclude directories that are not relevant
# to make backup of.
# 
# REQUIRES:
# - a setup encfs --reverse from $HOME. This wil require a $HOME/.encfs6.xml
# - the password that is used for the encryption to be stored in ~/.encfs_pwd
#
# To meet these requirements; do:
#
# $ mkdir /var/tmp/$USER-export
# $ pwgen -s 16 1 > ~/.encfs_pwd
# $ encfs --reverse $HOME /var/tmp/$USER-export
# and then use the standard options, and fill in the password 
# from ~/.encfs_pwd
# 
# next test it with:
# $ fusermount -u /var/tmp/$USER-export
# $ encfs --reverse --extpass="/bin/cat $HOME/.encfs_pwd" $HOME /var/tmp/$USER-export
# 
# Done!

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

mountpoint=/var/tmp/$USER-export
mkdir $mountpoint

encfs --reverse --extpass="/bin/cat $HOME/.encfs_pwd" $HOME $mountpoint


#rsync -rlptvx --delete --exclude tmp --exclude .cache --exclude build \
#  --exclude snap --exclude .thunderbird --exclude nobackup \
#  --exclude .WebIde70/system --exclude .crypt-baardmans \
#  --exclude VirtualBox\ VMs --exclude Seafile \
#  /home/bastiaan/ nas:/vol/storage/t450s/home/bastiaan
#TODAY=`date +%Y_%m_%d`
## maak snapshot van backup
#ssh nas cp -al /vol/storage/t450s /vol/storage/snapshots/t450s/$TODAY
