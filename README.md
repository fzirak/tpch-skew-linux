# TPCH-Skew for Linux
This code is just a modified and debugged clone of the [tpch_skew_linux](https://github.com/YSU-Data-Lab/TPC-H-Skew) repo which has made TPCH-Skew tool adjusted for unix based systems. 

There are makefiles for multiple operating systems and within those file you can specify your desired database server. I have added PostgreSQL to the database server options. However, it has only been tested for generating data and queries on Ubuntu 18.04. Other features, such as analyzing queries or update statements, may need further adjustment.

There are extera scripts to create multiple databases and workloads. **Make sure the environmental variables listed in `set_env_var.sh` are set properly before running the following scripts** (you can modify the pathes as you wish).
### Creating database
The `create_database.sh` script can be used to (1) call `dbgen` tool to create data files, (2) create database, and (3) load database with the data files. Some of the `dbgen` parameters can be passed to `create_database` sript, for the rest you can change the code and add them manually. An example command to run this script is:


    ./create_database.sh -g -s 10 -z 3.0 -ddir ./path_to_data_dir -db tpch_sf10_z3

Running the script without `-g` skips the data generation step mentioned above.

### Generating workloads
The `generate_workload.py` script can be used for generating query workload using specified query templates that are selected with a uniform distribution. It also allowes you to run the queries and measure their execution time within the python code (**It is not a precise measurment for sensitive analysis and is just an indication on how long each template query takes to complete**). 


The original TPCH-Skew tool only contains 17 templates, but this repo contains all templates except template 22. You can exclude some templates but including their ID in a file (eg `e_temp.txt`) and pass it to the `generate_workload.py` script. 

An example command to run this script is:


    python generate_workload.py -n 100 -s 10 -x e_temp.txt -o tpch_sf10_z3_wrkld.csv


The following is the instructions provided in the cloned repo. You can also find the readme file provided in the original TPCH-skew tool in `README-SKEW.doc` file.
## tpch_skew_linux

TPC-H with skew factor (Zipf distribution) enabled. Use `dbgen` with `-z` option to input the skew when generating benchmark data. There are several makefile available for different OSs and settings. Try them if the default makefile doesn't work.

The original is the linux version on github. Multiple makefiles have been prepared for multiple distributions including Mac OS.


## CentOS compile

    make -f makefile_centos


## MacOS compile

    make -f makefile_MacSolaris
    
# Generate
For example to generate a 100MB test data:

`./dbgen -s 0.1`

# Help information

```
./dbgen -h
TPC-D Population Generator (Version 1.3.1)
Copyright Transaction Processing Performance Council 1994 - 1998
USAGE:
dbgen [-{vfFD}] [-O {fhmst}][-T {pcsoPSOL}]
	[-s <scale>][-C <procs>][-S <step>]
dbgen [-v] [-O {dhmrt}] [-s <scale>] [-U <updates>] [-r <percent>]

-C <n> -- use <n> processes to generate data
          [Under DOS, must be used with -S]
-D     -- do database load in line
-f     -- force. Overwrite existing files
-F     -- generate flat files output
-h     -- display this message
-n <s> -- inline load into database <s>
-O d   -- generate SQL syntax for deletes
-O f   -- over-ride default output file names
-O h   -- output files with headers
-O m   -- produce columnar output
-O r   -- generate key ranges for deletes.
-O s   -- generate seed sets ONLY
-O t   -- use TIME table and julian dates
-r <n> -- updates refresh (n/100)% of the
          data set
-R <n> -- resume seed rfile generation with step <n>
-s <n> -- set Scale Factor (SF) to  <n>
-S <n> -- build the <n>th step of the data set
-T c   -- generate cutomers ONLY
-T l   -- generate nation/region ONLY
-T L   -- generate lineitem ONLY
-T n   -- generate nation ONLY
-T o   -- generate orders/lineitem ONLY
-T O   -- generate orders ONLY
-T p   -- generate parts/partsupp ONLY
-T P   -- generate parts ONLY
-T r   -- generate region ONLY
-T s   -- generate suppliers ONLY
-T S   -- generate partsupp ONLY
-U <s> -- generate <s> update sets
-v     -- enable VERBOSE mode
-z     -- **generate skewed data distributions**

To generate the SF=1 (1GB) database population , use:
	dbgen -vfF -s 1

To generate the qualification database population (100 MB), use:

	dbgen -vfF -s 0.1

To generate updates for a SF=1 (1GB), use:
	dbgen -v -O s -s 1
	dbgen -v -U 1 -s 1
```
