#!/bin/bash

# Function to handle SIGINT (Ctrl+C)
cleanup() {
    echo "Caught SIGINT. Terminating all child processes..."
    kill 0  # Sends SIGINT to all child processes in the same process group
    exit 1
}

# Trap SIGINT and forward to child processes
trap 'cleanup' SIGINT

# Your command or script execution here
echo "Starting the command..."
./create_database.sh -g -s 1 -z 0.5 -ddir  ./data_sf1_z05 -db tpch_sf1_z05 
./create_database.sh -g -s 10 -z 0.5 -ddir  ./data_sf10_z05 -db tpch_sf10_z05 

#  (since it changes the environment variables, better not to be run in parallel)
