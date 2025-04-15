#!/bin/bash

# положить в корень проекта с risc  
# пример ./run_load.sh lab3_condition:no_globl.s
interval=1  # Интервал измерений в секундах
logfile_cpu="cpu.log"
logfile_ram="ram.log"
idle_time=10

echo "Сбор данных начат..."
# atop -P CPU -P MEM -i "$interval" > "$logfile_cpu" 2>&1 &
atop -P CPU -i "$interval" > "$logfile_cpu" 2>&1 &
atop_pid=$!

free -s "$interval" --mega -t  > "$logfile_ram" 2>&1 &
vmstat_pid=$!

sleep $idle_time   # возможно стоит убрать
./tst/load.sh $*
sleep $idle_time   # возможно стоит убрать

kill $atop_pid
kill $vmstat_pid
wait $atop_pid 2>/dev/null
wait $vmstat_pid 2>/dev/null
echo "Сбор данных завершен. Лог сохранен в $logfile_cpu и $logfile_ram" 

python3 analyze_cpu.py "$logfile_cpu"
python3 analyze_ram.py "$logfile_ram"