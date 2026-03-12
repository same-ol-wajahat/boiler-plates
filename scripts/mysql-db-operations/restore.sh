#!/usr/bin/env bash

HOST="<hostname>"
USER="<username>"
PASSWORD="<password>"
DBNAME="<dbname>"
INPUT_DIR="<some-dir>"

echo "Disabling foreign key checks..."
mysql -h $HOST -u $USER -p$PASSWORD -e "SET foreign_key_checks = 0;" $DBNAME

echo "Restoring routines (stored procedures and functions)..."
mysql -h $HOST -u $USER -p$PASSWORD $DBNAME < $INPUT_DIR/routines.sql

for SQL_FILE in $INPUT_DIR/*.sql.gz
do
    echo "Restoring table $SQL_FILE..."
    gunzip < $SQL_FILE \
    | sed -E 's/DEFINER=`[^`]+`@`%`/DEFINER=`masteruser`@`%`/g' \
    | mysql -h $HOST -u $USER -p$PASSWORD $DBNAME
    echo "Table restored: $SQL_FILE"
done

echo "Re-enabling foreign key checks..."
mysql -h $HOST -u $USER -p$PASSWORD -e "SET foreign_key_checks = 1;" $DBNAME

echo "Database restore completed!"
