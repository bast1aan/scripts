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
# $ chmod 600 ~/.encfs_pwd
# $ encfs --reverse $HOME /var/tmp/$USER-export
#   and then use the standard options, and fill in the password 
#   from ~/.encfs_pwd
# 
# next test it with:
# $ fusermount -u /var/tmp/$USER-export
# $ encfs --reverse --extpass="/bin/cat $HOME/.encfs_pwd" $HOME /var/tmp/$USER-export
# 
# to make all encfs related info as little readable as possibe:
# $ chmod 600 ~/.encfs*
# (this includes the generated ~/.encfs6.xml as well)
# 
# Done!

EXCLUDES=`cat <<EOF
snap
nobackup
tmp
.cache
EOF`

EXTERNAL_SSH=cloudsuite@myexamplebackupserver.net

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

mountpoint=/var/tmp/$USER-export
mkdir $mountpoint

encfs --reverse --extpass="/bin/cat $HOME/.encfs_pwd" $HOME $mountpoint

rsync -rlptvx --bwlimit=1000 --delete `echo_exclude_opts $encrypted_encludes` $mountpoint/ $EXTERNAL_SSH:storage/t450s/home/$USER

fusermount -u $mountpoint

echo Making hardlink snapshot...
today=`date +%Y_%m_%d`
ssh $EXTERNAL_SSH cp -al storage/t450s storage/snapshots/t450s/$today
echo done.
