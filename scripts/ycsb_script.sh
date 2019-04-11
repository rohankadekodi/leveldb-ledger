#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters; Please provide run and setup (ledger/dax/nova/pmfs) as the parameter;"
    exit 1
fi

set -x

runId=$1
system=$2
databaseDir=/mnt/pmem_emul/leveldbtest-1000
#databaseDir=/mlfs/leveldbtest-1000
ycsbWorkloadsDir=/home/sekwon/ycsb_workloads
levelDbDir=/home/sekwon/leveldb-ledger
scriptsDir=/home/sekwon/leveldb-ledger/scripts
storingFileInfo=/home/sekwon/ledger-rohan/Results/YCSB
pmemDir=/mnt/pmem_emul
quillDir=/home/sekwon/ledger-rohan
quillLedgerResultsDir=/home/sekwon/ycsb-results/ledger
quillDaxResultsDir=/home/sekwon/ycsb-results/dax
quillNovaResultsDir=/home/sekwon/ycsb-results/nova
quillPMFSResultsDir=/home/sekwon/ycsb-results/pmfs
quillStrataResultsDir=/home/sekwon/ycsb-results/strata

parameters=' --open_files=1000 --max_file_size=134217730'
echo Configuration: 20, 24, 64MB

mkdir -p $quillLedgerResultsDir
mkdir -p $quillDaxResultsDir
mkdir -p $quillNovaResultsDir
mkdir -p $quillPMFSResultsDir

echo Sleeping for 5 seconds . . 
sleep 5

load_workload()
{
    workloadName=$1
    tracefile=$2
    parameters=$3
    
    if [ "$setup" = "ledger" ]; then
	resultDir=$quillLedgerResultsDir/Load$workloadName
    elif [ "$setup" = "dax" ]; then
	resultDir=$quillDaxResultsDir/Load$workloadName
    elif [ "$setup" = "nova" ]; then
	resultDir=$quillNovaResultsDir/Load$workloadName
    else		
	resultDir=$quillPMFSResultsDir/Load$workloadName
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
    if [ "$setup" = "ledger" ]; then
	$quillDir/run_quill.sh -p $quillDir/ -t nvp_nvp.tree ./db_bench --use_existing_db=0 --benchmarks=ycsb,stats,printdb --db=$databaseDir --threads=1 --open_files=1000 >> $resultDir/Run$runId
	sudo df -h | grep "/mnt/pmem_emul" >> $resultDir/Run$runId
    else	
    ./db_bench --use_existing_db=0 --benchmarks=ycsb,stats,printdb --db=$databaseDir --threads=1 --open_files=1000 >> $resultDir/Run$runId
	sudo df -h | grep "/mnt/pmem_emul" >> $resultDir/Run$runId
	#$quillSyscallsDir/run_quill.sh -p $quillSyscallsDir/ -t nvp_nvp.tree ./db_bench --use_existing_db=0 --benchmarks=ycsb,stats,printdb --db=$databaseDir --threads=1 --open_files=1000 >> $resultDir/Run$runId
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
#    setup=$4

    if [ "$setup" = "ledger" ]; then
	resultDir=$quillLedgerResultsDir/Run$workloadName
    elif [ "$setup" = "dax" ]; then
	resultDir=$quillDaxResultsDir/Run$workloadName
    elif [ "$setup" = "nova" ]; then
	resultDir=$quillNovaResultsDir/Run$workloadName
    else
	resultDir=$quillPMFSResultsDir/Run$workloadName
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
    if [ "$setup" = "ledger" ]; then
	$quillDir/run_quill.sh -p $quillDir/ -t nvp_nvp.tree ./db_bench --use_existing_db=1 --benchmarks=ycsb,stats,printdb --db=$databaseDir --threads=1 --open_files=1000 >> $resultDir/Run$runId
	sudo df -h | grep "/mnt/pmem_emul" >> $resultDir/Run$runId
    else
	./db_bench --use_existing_db=1 --benchmarks=ycsb,stats,printdb --db=$databaseDir --threads=1 --open_files=1000 >> $resultDir/Run$runId
	sudo df -h | grep "/mnt/pmem_emul" >> $resultDir/Run$runId
	#strace -cf -e trace=file,desc ./db_bench --use_existing_db=1 --benchmarks=ycsb --db=/mnt/pmem_emul --threads=1 --open_files=1000
	#strace -cf ./db_bench --use_existing_db=1 --benchmarks=ycsb --db=/mnt/pmem_emul --threads=1 --open_files=1000
	#$quillSyscallsDir/run_quill.sh -p $quillSyscallsDir/ -t nvp_nvp.tree ./db_bench --use_existing_db=1 --benchmarks=ycsb,stats,printdb --db=$databaseDir --threads=1 --open_files=1000 >> $resultDir/Run$runId
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

#    sudo mkdir $databaseDir
#    sudo cp /home/sekwon/leveldb-ledger/loada_data/* $databaseDir/
    load_workload a $ycsbWorkloadsDir/loada_5M $parameters $setup
    $scriptsDir/pause_script.sh 10

    run_workload a $ycsbWorkloadsDir/runa_5M_5M $parameters $setup
    $scriptsDir/pause_script.sh 10

    run_workload b $ycsbWorkloadsDir/runb_5M_10M $parameters $setup
    $scriptsDir/pause_script.sh 10

    run_workload c $ycsbWorkloadsDir/runc_5M_10M $parameters $setup
    $scriptsDir/pause_script.sh 10

    run_workload f $ycsbWorkloadsDir/runf_5M_5M $parameters $setup
    $scriptsDir/pause_script.sh 10

    run_workload d $ycsbWorkloadsDir/rund_5M_10M $parameters $setup
    $scriptsDir/pause_script.sh 10

    sudo rm -rf $pmemDir/*

#    sudo mkdir $databaseDir
#    sudo cp /home/sekwon/leveldb-ledger/loade_data/* $databaseDir/
    load_workload e $ycsbWorkloadsDir/loade_5M $parameters $setup
    $scriptsDir/pause_script.sh 10

    run_workload e $ycsbWorkloadsDir/rune_5M_1M $parameters $setup
    $scriptsDir/pause_script.sh 10
}

setup_expt $system $parameters
