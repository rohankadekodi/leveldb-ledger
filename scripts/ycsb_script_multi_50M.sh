#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters; Please provide run as the parameter;"
    exit 1
fi

set -x

runId=$1
databaseDir=/mnt/pmem_emul/leveldbtest-1000
ycsbWorkloadsDir=/home/rohan/projects/ycsb_workloads
levelDbDir=/home/rohan/projects/leveldb
ext4DAXResultsDir=/home/rohan/projects/ext4DAX/Results/YCSB
scriptsDir=/home/rohan/projects/leveldb/scripts
storingFileInfo=/home/rohan/projects/quill-modified/Results/YCSB
pmemDir=/mnt/pmem_emul
quillDir=/home/rohan/projects/quill-modified
quillSyscallsDir=/home/rohan/projects/quill-syscalls/quill-modified
quillResultsDir=$quillDir/Results/YCSB
quillSyscallsResultsDir=$quillSyscallsDir/Results/YCSB

parameters=' --open_files=1000 --max_file_size=134217730'
echo Configuration: 20, 24, 64MB

mkdir -p $quillResultsDir
mkdir -p $ext4DAXResultsDir
mkdir -p $quillSyscallsResultsDir

echo Sleeping for 5 seconds . . 
sleep 5

load_workload()
{
    workloadName=$1
    tracefile=$2
    parameters=$3
    
    if [ "$setup" = "quill" ]; then
	resultDir=$quillResultsDir/Load$workloadName
    else
	resultDir=$quillSyscallsResultsDir/Load$workloadName
    fi

    mkdir -p $resultDir
    
    echo ----------------------- LevelDB YCSB Load $workloadName ---------------------------
    date
    export trace_file=$tracefile
    echo Trace file is $trace_file
    cd $levelDbDir/build
    
#nohup echo alohomora | sudo -S iotop -btoqa | grep --line-buffered bench > ycsb$run/iotop_loada_50M1.log &
#nohup ~/pmap_script.sh > ycsb"$run"/pmap_loada_50M"$run".log &

    date
    if [ "$setup" = "quill" ]; then
	$quillDir/run_quill.sh -p $quillDir/ -t nvp_nvp.tree ./db_bench --use_existing_db=0 --benchmarks=ycsb,stats,printdb --db=$databaseDir --threads=4 --open_files=1000 >> $resultDir/Run$runId
    else
        #./db_bench --use_existing_db=0 --benchmarks=ycsb,stats,printdb --db=$databaseDir --threads=1 --open_files=1000 >> $resultDir/Run$runId
	$quillSyscallsDir/run_quill.sh -p $quillSyscallsDir/ -t nvp_nvp.tree ./db_bench --use_existing_db=0 --benchmarks=ycsb,stats,printdb --db=$databaseDir --threads=4 --open_files=1000 >> $resultDir/Run$runId

    fi
    date

    echo Sleeping for 5 seconds . .
    sleep 5

    ls -lah $databaseDir/* >> $resultDir/FileInfo$runId
    echo "--------------------------------" >> $resultDir/FileInfo$runId
    ls $databaseDir/ | wc -l >> $resultDir/FileInfo$runId
    echo "--------------------------------" >> $resultDir/FileInfo$runId
    du -sh $databaseDir >> $resultDir/FileInfo$runId

    #mkdir -p /mnt/ssd/flsm/leveldbtest-original-loada-50M$run
    #cp -r /mnt/ssd/flsm/leveldbtest-original-1000/* /mnt/ssd/flsm/leveldbtest-original-loada-50M$run/
    #echo Killing iotop process `pgrep iotop`
    #echo alohomora | sudo -S kill `pgrep iotop`
    #echo alohomora | sudo -S kill `pgrep pmap_script`

    echo -----------------------------------------------------------------------

    echo Sleeping for 5 seconds . . 
    sleep 5
}

run_workload()
{
    workloadName=$1
    tracefile=$2
    parameters=$3
    setup=$4

    if [ "$setup" = "quill" ]; then
	resultDir=$quillResultsDir/Run$workloadName
    else
	resultDir=$quillSyscallsResultsDir/Run$workloadName
    fi

    mkdir -p $resultDir
    
    echo ----------------------- LevelDB YCSB Run $workloadName ---------------------------
    date
    export trace_file=$tracefile
    echo Trace file is $trace_file
    cd $levelDbDir/build
    #nohup echo alohomora | sudo -S iotop -btoqa | grep --line-buffered bench > ycsb$run/iotop_loada_50M1.log &
    #nohup ~/pmap_script.sh > ycsb"$run"/pmap_loada_50M"$run".log &

    date
    if [ "$setup" = "quill" ]; then
	$quillDir/run_quill.sh -p $quillDir/ -t nvp_nvp.tree ./db_bench --use_existing_db=1 --benchmarks=ycsb,stats,printdb --db=$databaseDir --threads=4 --open_files=1000 >> $resultDir/Run$runId
    else
	#./db_bench --use_existing_db=1 --benchmarks=ycsb,stats,printdb --db=$databaseDir --threads=1 --open_files=1000 >> $resultDir/Run$runId
	$quillSyscallsDir/run_quill.sh -p $quillSyscallsDir/ -t nvp_nvp.tree ./db_bench --use_existing_db=1 --benchmarks=ycsb,stats,printdb --db=$databaseDir --threads=4 --open_files=1000 >> $resultDir/Run$runId
    fi
    date

    echo Sleeping for 5 seconds . .
    sleep 5

    ls -lah $databaseDir/* >> $resultDir/FileInfo$runId
    echo "--------------------------------" >> $resultDir/FileInfo$runId
    ls $databaseDir/ | wc -l >> $resultDir/FileInfo$runId
    echo "--------------------------------" >> $resultDir/FileInfo$runId
    du -sh $databaseDir >> $resultDir/FileInfo$runId
    
    #mkdir -p /mnt/ssd/flsm/leveldbtest-original-loada-50M$run
    #cp -r /mnt/ssd/flsm/leveldbtest-original-1000/* /mnt/ssd/flsm/leveldbtest-original-loada-50M$run/
    #echo Killing iotop process `pgrep iotop`
    #echo alohomora | sudo -S kill `pgrep iotop`
    #echo alohomora | sudo -S kill `pgrep pmap_script`

    echo -----------------------------------------------------------------------

    echo Sleeping for 5 seconds . . 
    sleep 5
}

setup_expt()
{
    setup=$1

    sudo rm -rf $pmemDir/*

    load_workload a $ycsbWorkloadsDir/loada_50M_1,$ycsbWorkloadsDir/loada_50M_2,$ycsbWorkloadsDir/loada_50M_3,$ycsbWorkloadsDir/loada_50M_4 $parameters $setup
    $scriptsDir/pause_script.sh 10
    
    run_workload a $ycsbWorkloadsDir/runa_50M_5M_1,$ycsbWorkloadsDir/runa_50M_5M_2,$ycsbWorkloadsDir/runa_50M_5M_3,$ycsbWorkloadsDir/runa_50M_5M_4 $parameters $setup
    $scriptsDir/pause_script.sh 10

    run_workload b $ycsbWorkloadsDir/runb_50M_5M_1,$ycsbWorkloadsDir/runb_50M_5M_2,$ycsbWorkloadsDir/runb_50M_5M_3,$ycsbWorkloadsDir/runb_50M_5M_4 $parameters $setup
    $scriptsDir/pause_script.sh 10

    run_workload c $ycsbWorkloadsDir/runc_50M_5M_1,$ycsbWorkloadsDir/runc_50M_5M_2,$ycsbWorkloadsDir/runc_50M_5M_3,$ycsbWorkloadsDir/runc_50M_5M_4 $parameters $setup
    $scriptsDir/pause_script.sh 10

    run_workload f $ycsbWorkloadsDir/runf_50M_5M_1,$ycsbWorkloadsDir/runf_50M_5M_2,$ycsbWorkloadsDir/runf_50M_5M_3,$ycsbWorkloadsDir/runf_50M_5M_4 $parameters $setup
    $scriptsDir/pause_script.sh 10

    run_workload d $ycsbWorkloadsDir/rund_50M_5M_1,$ycsbWorkloadsDir/rund_50M_5M_2,$ycsbWorkloadsDir/rund_50M_5M_3,$ycsbWorkloadsDir/rund_50M_5M_4 $parameters $setup
    $scriptsDir/pause_script.sh 10

    sudo rm -rf $pmemDir/*

    load_workload e $ycsbWorkloadsDir/loade_50M_1,$ycsbWorkloadsDir/loade_50M_2,$ycsbWorkloadsDir/loade_50M_3,$ycsbWorkloadsDir/loade_50M_4 $parameters $setup
    $scriptsDir/pause_script.sh 10

    run_workload e $ycsbWorkloadsDir/rune_50M_25M_1,$ycsbWorkloadsDir/rune_50M_25M_2,$ycsbWorkloadsDir/rune_50M_25M_3,$ycsbWorkloadsDir/rune_50M_25M_4 $parameters $setup
    $scriptsDir/pause_script.sh 10
}

setup_expt quill $parameters
setup_expt ext4DAX $parameters
