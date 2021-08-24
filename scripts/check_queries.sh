#!/bin/bash
#--------------------------------------------------------------+
# Bash script to check whether all queries work as expected    |
# i. e. return with exit code 0.                               |
#                                                              |
# Author: Thomas Pilz (Thomas.Pilz@st.oth-regensburg.de)       |
#--------------------------------------------------------------+

# Directory where scripts are located
NUM_SUCCESS=0
NUM_FAILED=0
NUM_CHECKED=0
NUM_QUERIES=$(ls $WORKDIR/sql-queries/ | wc -l)

echo -e "\nChecking all SQL-queries...\n"
 
for file in $WORKDIR/sql-queries/*
do
    NUM_CHECKED=$(($NUM_CHECKED + 1))
    # check query, redirect stderr to stdout and suppress stdout
    echo -en "Running $file...\t"
    ERROR=$(psql -v ON_ERROR_STOP=1 -U $POSTGRES_USER -d $POSTGRES_DB -f $file 2>&1 >/dev/null)
    if [ $? -eq 0 ]
    then
        echo -e "\033[0;92m[SUCCESS]\033[0m"
        NUM_SUCCESS=$(($NUM_SUCCESS + 1))
    else
        echo -e "\033[0;91m[FAILED]\033[0m"
        echo -e $ERROR
        NUM_FAILED=$(($NUM_FAILED + 1))
    fi
done

echo -e "\n--- Summary ---\nTotal queries: $NUM_QUERIES\nNo. checked queries: $NUM_CHECKED\nNo. successful queries: $NUM_SUCCESS\nNo. failed queries: $NUM_FAILED"
