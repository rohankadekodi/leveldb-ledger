#!/bin/bash

set -x

ycsb_workloads_folder=/home/rohan/projects/ycsb_workloads
ycsb_folder=/home/rohan/projects/YCSB
record_count=5000000

operation_count_bcd=10000000
operation_count_a=5000000
operation_count_f=5000000
operation_count_e=1000000

mkdir -p $ycsb_workloads_folder
cd $ycsb_folder

./bin/ycsb load tracerecorder -p recorder.file=$ycsb_workloads_folder/loada_5M -p recordcount=$record_count -P workloads/workloada

./bin/ycsb run tracerecorder -p recorder.file=$ycsb_workloads_folder/runa_5M_5M -p recordcount=$record_count -p operationcount=$operation_count_a -P workloads/workloada

./bin/ycsb run tracerecorder -p recorder.file=$ycsb_workloads_folder/runb_5M_10M -p recordcount=$record_count -p operationcount=$operation_count_bcd -P workloads/workloadb

./bin/ycsb run tracerecorder -p recorder.file=$ycsb_workloads_folder/runc_5M_10M -p recordcount=$record_count -p operationcount=$operation_count_bcd -P workloads/workloadc

./bin/ycsb run tracerecorder -p recorder.file=$ycsb_workloads_folder/runf_5M_5M -p recordcount=$record_count -p operationcount=$operation_count_f -P workloads/workloadf

./bin/ycsb run tracerecorder -p recorder.file=$ycsb_workloads_folder/rund_5M_10M -p recordcount=$record_count -p operationcount=$operation_count_bcd -P workloads/workloadd

./bin/ycsb load tracerecorder -p recorder.file=$ycsb_workloads_folder/loade_5M -p recordcount=$record_count -P workloads/workloade

./bin/ycsb run tracerecorder -p recorder.file=$ycsb_workloads_folder/rune_5M_1M -p recordcount=$record_count -p operationcount=$operation_count_e -P workloads/workloade

