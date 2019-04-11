#! /bin/bash

PATH=$PATH:.

STRATA=/home/sekwon/strata

export trace_file=/home/sekwon/ycsb_workloads/loada_5M
export LD_LIBRARY_PATH=$STRATA/libfs/lib/nvml/src/nondebug/:$STRATA/libfs/build:$STRATA/libfs/src/storage/spdk/:$STRATA/shim/glibc-build/rt/:$STRATA/libfs/lib/libspdk/libspdk/

LD_PRELOAD=$STRATA/shim/libshim/libshim.so:$STRATA/libfs/lib/jemalloc-4.5.0/lib/libjemalloc.so.2 ${@}
#LD_PRELOAD=../../shim/libshim/libshim.so:../lib/jemalloc-4.5.0/lib/libjemalloc.so.2 MLFS_PROFILE=1 ${@}
