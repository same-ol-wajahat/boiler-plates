#!/usr/bin/env bash

HOST="<hostname>"
USER="<username>"
PASSWORD="<password>"
DBNAME="<dbname>"
OUTPUT_DIR="<some-dir>"


echo "Dumping routines (stored procedures and functions)..."
mysqldump -h $HOST -u $USER -p$PASSWORD --routines --no-data --no-set-names --quick --lock-tables=false $DBNAME > $OUTPUT_DIR/routines.sql

mapfile -t TABLES < <(mysql -h $HOST -u $USER -p$PASSWORD -e "SHOW TABLES IN $DBNAME" -s --skip-column-names)
#printf '%s\n' "${TABLES[@]}"

for TABLE in "${TABLES[@]}"
do
    echo "Dumping table $TABLE..."
    mysqldump -h $HOST -u $USER -p$PASSWORD --single-transaction --quick --lock-tables=false $DBNAME $TABLE > $OUTPUT_DIR/$TABLE.sql
    gzip $OUTPUT_DIR/$TABLE.sql
    echo "Table $TABLE dumped and compressed."
done

echo "Database dump completed!"
