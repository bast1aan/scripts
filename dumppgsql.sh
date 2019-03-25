#!/bin/sh
#

# !!!!!!!!!! CONFIGURE THIS VARIABLES TO YOUR LOCAL NEEDS !!!!!!!!!!
DUMPDIR=/var/local/pgsqldump
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

if [ ! -d $DUMPDIR ]; then
        echo "$DUMPDIR not found, aborting"
        exit 1
fi

#TODAY=`date +%Y_%m_%d`

#DUMPDIR=$DUMPDIR/$TODAY

rm -rf $DUMPDIR/*

pg_dumpall --roles-only > $DUMPDIR/roles.sql

DBS=`psql -l -t | cut -d'|' -f 1 | sed -e '/^ *$/d' | egrep -v 'template[01]|\:' `

for database in $DBS; do
        echo Dumping $database ...
        pg_dump $database | gzip > $DUMPDIR/$database.sql.gz
done;

