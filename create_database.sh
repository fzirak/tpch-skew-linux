#!/bin/bash

# Default variables
DB_NAME="tpch_test"
DB_USER="postgres"
DATA_DIR="./data"
DO_GENERATE=false
SCALEFACTOR=1
ZIPF="None"

print_usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -db, --database           Set the database name (default: $DB_NAME)"
    echo "  -u, --user                Set the database user (default: $DB_USER)"
    echo "  -ddir, --datadir          Set the data directory for .tbl files (default: $DATA_DIR)"
    echo "  -g, --generate-data       Generate the table data (default: False)"
    echo "  -s, --scalefactor         Data generation scale factor (default: 1)"
    echo "  -z, --zipf                Data generation zipf factor (default: None)"
    echo "  --help                    Show this help message and exit"
    echo
}

check_and_create_dir() {
    local dir=$1
    if [[ ! -d "$dir" ]]; then
        echo "Data directory '$dir' does not exist. Creating it"
        mkdir -p "$dir"
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to create data directory '$dir'."
            exit 1
        fi
    fi
}

check_and_create_db() {
    if ! psql -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -wq "$DB_NAME"; then
        echo "Database '$DB_NAME' does not exist. Creating it"
        createdb -U "$DB_USER" "$DB_NAME"
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to create database '$DB_NAME'."
            exit 1
        fi
    fi
}


while [[ "$#" -gt 0 ]]; do
    case $1 in
        -db|--database)
            DB_NAME="$2"
            shift 2
            ;;
        -u|--user)
            DB_USER="$2"
            shift 2
            ;;
        -ddir|--datadir)
            DATA_DIR="$2"
            shift 2
            ;;
        -g|--generate-data)
            DO_GENERATE=true
            shift 1
            ;;
        -s|--scalefactor)
            SCALEFACTOR="$2"
            shift 2
            ;;
        -z|--zipf)
            ZIPF="$2"
            shift 2
            ;;
        --help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown parameter: $1"
            print_usage
            exit 1
            ;;
    esac
done

echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "Data directory: $DATA_DIR"

if $DO_GENERATE; then
    echo "generating the data in $DATA_DIR"
    check_and_create_dir "$DATA_DIR"
    export DSS_PATH="$DATA_DIR"
    if [[ "$ZIPF" != "None" ]]; then
        echo "zipf is $ZIPF"
        ./dbgen -s "$SCALEFACTOR" -z "$ZIPF"
    else
        ./dbgen -s "$SCALEFACTOR" 
    fi
fi



# Load schema
export PGPASSWORD="pass"
check_and_create_db
psql -U "$DB_USER" -d "$DB_NAME" -f ./dss_pg.ddl
unset PGPASSWORD


# rename order table file if exists
if [[ -f "$DATA_DIR/order.tbl" ]]; then
    echo "Found '$DATA_DIR/order.tbl', renaming to '$DATA_DIR/orders.tbl'"
    mv "$DATA_DIR/order.tbl" "$DATA_DIR/orders.tbl"
fi

echo "Modifying .tbl files to remove trailing delimeter"
for file in "$DATA_DIR"/*.tbl; do
    sed -i 's/|$//' "$file"
done

# Load data
echo "Loading data into tables"
for TABLE in nation region customer orders lineitem partsupp part supplier; do
    psql -U $DB_USER -d $DB_NAME -c "\COPY $TABLE FROM '$DATA_DIR/$TABLE.tbl' WITH (FORMAT csv, DELIMITER '|', NULL '');"
done
