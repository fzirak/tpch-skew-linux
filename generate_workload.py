import os
import random
import subprocess
import argparse
import psycopg2
import time
import numpy as np
from  tqdm import tqdm
import traceback
import multiprocessing


def clean_query(query):
    lines = [l.strip() for l in query.splitlines() if len(l.strip()) > 0 and "--" not in l]
    if ";" in lines[-1] and ";" in lines[-2]:
        lines = lines[:-1]
    return " ".join(lines).strip()


def get_timed_filename(file_path):
    dir_name, file_name = os.path.split(file_path)
    new_file_name = f"timed_{file_name}"
    new_file_path = os.path.join(dir_name, new_file_name)
    return new_file_path

def execute_queries_for_template(template_id, q_lst, db_name, db_user, db_pass, query_times_per_temp):
    try:
        conn = psycopg2.connect(database=db_name, user=db_user, password=db_pass,
                                host='localhost', port=5432)
        conn.autocommit = True
        cursor = conn.cursor()

        times = []
        for q in q_lst:
            try:
                t1 = time.time()
                cursor.execute(q)  
                t2 = time.time()                
                
                times.append(t2 - t1)
            except Exception:
                err = traceback.format_exc()
                print(f"Error executing query for template {template_id}: {err}")
                continue
        query_times_per_temp[f'q{template_id}'] = times
        print(f'q{template_id} = {times}')
    except Exception:
        print(f"Error in process for template {template_id}: {traceback.format_exc()}")
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()

def parallel_query_execution(q_and_temp_dict, db_name, db_user, db_pass):
    with multiprocessing.Manager() as manager:
        query_times_per_temp = manager.dict()

        processes = []
        for template_id, q_lst in q_and_temp_dict.items():
            p = multiprocessing.Process(target=execute_queries_for_template, 
                                         args=(template_id, q_lst, db_name, db_user, db_pass, query_times_per_temp))
            processes.append(p)

        for p in processes:
            p.start()

        for p in processes:
            p.join()

        query_times_per_temp = dict(query_times_per_temp)
        return query_times_per_temp
    

parser = argparse.ArgumentParser(description="Generate and process TPC-H queries.")
parser.add_argument(
    "-n", "--num-queries", type=int, required=True,
    help="Number of queries to generate."
)
parser.add_argument(
    "-o", "--output-file", type=str, default="./queries.csv",
    help="Directory to save the processed queries (default: ./queries.csv)."
)
parser.add_argument(
    "-s", "--scale-factor", type=float, default=1,
    help="TPC-H scale factor (default: 1)."
)
parser.add_argument(
    "-r", "--random-seed", type=int, default=None,
    help="Seed for random selection (default: None)."
)
parser.add_argument(
    "-d", "--db-name", type=str, default="tpch_sf10_z05",
    help="Database name to execute the queries."
)
parser.add_argument(
    "-u", "--db-user", type=str, default="postgres",
    help="Database user for execution."
)
parser.add_argument(
    "-p", "--db-pass", type=str, default="pass",
    help="Password for user."
)
parser.add_argument(
    "-x", "--exclude-temp", type=str, default=None,
    help="Path to the file with templatesIDs to be excluded (default None)"
)
parser.add_argument(
    "-t", "--time-test", action="store_true", 
    help="Whether to do time test."
)
parser.add_argument(
    "-e", "--equal-selection", action="store_true", 
    help="Whether to generate same number of queries from each template."
)
args = parser.parse_args()

# Configuration
tpch_tool_path = "./"  # Path to the TPC-H tool directory containing qgen
output_file = args.output_file
num_queries = args.num_queries
scale_factor = args.scale_factor
if scale_factor > 1:
    scale_factor = int(scale_factor)
random_seed = args.random_seed 
if random_seed:
    random.seed(random_seed)
db_name = args.db_name
db_user = args.db_user
db_pass = args.db_pass
do_time_test = args.time_test
temps_to_exclude_fp = args.exclude_temp
select_temp_equally = args.equal_selection

temps_to_exclude = []
if temps_to_exclude_fp:
    with open(temps_to_exclude_fp, 'r') as temp_exclude_file:
        lines = temp_exclude_file.readlines()
    nums = set()
    for line in lines:
        line = line.strip()
        for l in line.replace('', '').split(','):
            nums.add(l)
    
    invalids = []
    for temp in nums:
        try:
            temps_to_exclude.append(int(temp))
        except Exception:
            invalids.append(str(temp))

    if len(invalids):
        print(f"({' '.join(invalids)}) {'is an' if len(invalids) == 1 else 'are'} invalid value{'' if len(invalids) == 1 else 's'} in temp exclude file. Ignoring them")
    
    if len(temps_to_exclude):
        print(f'Templates to exclude: {temps_to_exclude}')



templates = [i for i in range(1, 23) if i not in temps_to_exclude]
print(f'Generating {num_queries} queries with following templates (equal selection is {"ON" if select_temp_equally else "OFF"}):\n\t{templates}')

if select_temp_equally:
    num_queries_per_temp = num_queries // len(templates)
    selected_templates = [i for j in range(num_queries_per_temp) for i in templates]
    random.shuffle(selected_templates)
else:
    selected_templates = [random.choice(templates) for _ in range(num_queries)]

generated_queries = []
q_and_temp_dict = {}
query_times_per_temp_ = {}
for idx, template_id in enumerate(tqdm(selected_templates, desc='Generating queries'), start=1):  
    qgen_command = [
        os.path.join(tpch_tool_path, "./qgen"),
        "-s", str(scale_factor),  
        # "-r", str(unique_seed),  
        # "-l", './params.txt',
         str(template_id) 
    ]

    query_output = subprocess.run(qgen_command, capture_output=True, text=True)
    raw_query = query_output.stdout
    processed_query = clean_query(raw_query)
    generated_queries.append(processed_query)
    if template_id not in q_and_temp_dict:
        q_and_temp_dict[template_id] = []
    q_and_temp_dict[template_id].append(processed_query)

print("Done generating queries. Storing queries.")
with open(output_file, "w") as query_file:
    for q in generated_queries:
        query_file.write(q)
        query_file.write('\n')

if do_time_test:
    print("Start executing queries for time.")
    query_times_per_temp_ = parallel_query_execution(q_and_temp_dict, db_name, db_user, db_pass)

    print("Storing times.")
    with open(get_timed_filename(output_file), "w") as timed_query_file:
        timed_query_file.write('query_template,min_exec_time, max_exec_time,avg_exec_time,std_exec_time\n')
        print(query_times_per_temp_)

        for q_temp in query_times_per_temp_:
            time_arr = np.array(query_times_per_temp_[q_temp])
            timed_query_file.write(
                f'{q_temp},{np.min(time_arr)},{np.max(time_arr)},{np.mean(time_arr)},{np.std(time_arr)}\n'
            )
            timed_query_file.write('\n')