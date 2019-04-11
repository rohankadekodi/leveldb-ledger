#!/bin/bash
system=$1

echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

#dax and ledger
dax_init() {
    sudo rm -rf /mnt/pmem_emul/* && sudo sync
    sleep 3
    sudo umount -f /mnt/pmem_emul
    sleep 3
    echo "yes" | sudo mkfs.ext4 -b 4096 /dev/pmem0
    sleep 3
    sudo mount -o dax /dev/pmem0 /mnt/pmem_emul/
    sleep 3
}

#nova
nova_init() {
    sudo rm -rf /mnt/pmem_emul/* && sudo sync
    sleep 3
    sudo umount -f /mnt/pmem_emul
    sleep 3
    sudo modprobe nova inplace_data_updates=1
    sleep 3
    sudo mount -t NOVA -o init /dev/pmem0 /mnt/pmem_emul
    sleep 3
}

#pmfs
pmfs_init() {
    sudo rm -rf /mnt/pmem_emul/* && sudo sync
    sleep 3
    sudo umount -f /mnt/pmem_emul
    sleep 3
    sudo insmod /home/sekwon/PMFS-new/pmfs.ko
    sleep 3
    sudo mount -t pmfs -o init /dev/pmem0 /mnt/pmem_emul
    sleep 3
}

if [ ${system} = "dax" ];then
    dax_init
    echo "dax run"
elif [ ${system} = "ledger" ];then
    dax_init
#    pmfs_init
    echo "ledger run"
elif [ ${system} = "nova" ];then
    nova_init
    echo "nova run"
elif [ ${system} = "pmfs" ];then
    pmfs_init
    echo "pmfs run"
fi

for i in {1..1}
do
    sudo ./ycsb_script.sh 3 $system
    sleep 3
    sudo rm -rf /mnt/pmem_emul/* && sudo sync
    sleep 3
done
