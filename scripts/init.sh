#!/bin/bash
#--------------------------------------------------------------------+
# Bash script to initialize JSON Schema corpus database with data    |
#                                                                    |
# Author: Thomas Pilz (Thomas.Pilz@st.oth-regensburg.de)             |
#--------------------------------------------------------------------+

set -e
echo "+------------------------------------------------------------------------------------------------------------------------------+"
echo "| Initializing database with JSON Schema corpus data...                                                                        |"
echo "| 3 step processs to...                                                                                                        |"
echo "|  - configure psql                                                                                                            |"
echo "|  - unpack the data to be restored                                                                                            |"
echo "|  - restore data                                                                                                              |"
echo "| Expected duration: about 25-30 minutes                                                                                       |"
echo "+------------------------------------------------------------------------------------------------------------------------------+"

log(){
    echo -e "$(date +"%Y-%m-%d %H:%M:%S")  $1"
}

calc_duration(){
    DURATION="$(( ($T_END/60) % 60  ))min $(( $T_END % 60 ))s"
}


# configure psql to adjust terminal output to terminal window and put schema "jsonnegation" as current schema
echo ">> STEP 1"
log "Configuring psql..."
SECONDS=0
# Enable "Extended Display"
echo "\x auto" > ~/.psqlrc
T_END=$SECONDS
calc_duration
log "Done. ($DURATION)"

echo ">> STEP 2"
log "Unpacking $WORKDIR/$SQL_DUMP_FNAME.gz to $WORKDIR/$SQL_DUMP_FNAME..."
log "Expected duration: about 5 minutes"
SECONDS=0
gzip -d $WORKDIR/$SQL_DUMP_FNAME.gz
T_END=$SECONDS
calc_duration
log "Done. ($DURATION)"


# Login as root to db and run restore
echo ">> STEP 3"
log "Restoring data from SQL-dump $WORKDIR/$SQL_DUMP_FNAME into database $POSTGRES_DB and granting all privileges to user $POSTGRES_USER..."
log "Expected duration: about 20-25 minutes"
SECONDS=0
# Start Postgres service to allow restore
/etc/init.d/postgresql start
psql -v ERROR_STOP=1 -U $POSTGRES_USER -d $POSTGRES_DB --file $WORKDIR/$SQL_DUMP_FNAME
# Stop Postgres service again. Postgres Server will instead be started on "docker run" in foreground 
/etc/init.d/postgresql stop
T_END=$SECONDS
calc_duration
log "Done. ($DURATION)"
log "Database initialized."

echo ">> STEP 4"
log "Deleting $WORKDIR/$SQL_DUMP_FNAME to minimize Docker Image size..."
log "Expected duration: about 1 minutes"
SECONDS=0
rm -rf $WORKDIR/$SQL_DUMP_FNAME
T_END=$SECONDS
calc_duration
log "Done. ($DURATION)"

