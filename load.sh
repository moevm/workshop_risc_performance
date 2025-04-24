#!/bin/bash

# paste in tst folder

# set num reties
N_retries=100


# use as: ./tst/load.sh lab3_condition:no_globl.s

NO_COLOR='\033[0m'
BLUE_COLOR='\033[0;34m'
YELLOW_COLOR='\033[0;33m'
CYAN_COLOR='\033[0;36m'
RED_COLOR='\033[0;31m'
GREEN_COLOR='\033[0;32m'

tasks_dir="./tst/integration/"
declare -A task_filter 
checker_run_flags=''
tasks=''

# Обработка аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -f)
            checker_run_flags+=" $2"
            shift 2
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            # Парсим аргументы вида "task:solution.s"
            if [[ "$1" == *":"* ]]; then
                IFS=':' read -r task_name solution_name <<< "$1"
                task_filter[$task_name]+=" $solution_name"
                tasks+=" $task_name"
            else
                tasks+=" $1"
            fi
            shift
            ;;
    esac
done

# Удаляем дубликаты задач
tasks=$(echo "$tasks" | tr ' ' '\n' | sort -u | tr '\n' ' ')

if [ -z "$tasks" ] 
then
  echo "Task list is not set, checking all existing tasks"
  tasks=$(ls -1 ${tasks_dir} | grep '^lab')
fi

echo -e "${YELLOW_COLOR}Task list is:${NO_COLOR}"
echo "${tasks}"
echo -e "${YELLOW_COLOR}Checker run flags are:${NO_COLOR}"
echo "${checker_run_flags}"

fail_count=0
task_counter=1
total_tasks=$(echo "$tasks" | wc -w)

echo "Checking solutions for tasks"

for task in ${tasks}
do
  echo -e "${YELLOW_COLOR}[${task_counter}/${total_tasks}] Starting check for ${task}:${NO_COLOR}"
  ((task_counter++))
  seeds=$(ls -1 "${tasks_dir}/${task}/" 2>/dev/null)

  if [ -z "$seeds" ]; then
    echo -e "${RED_COLOR}No seeds found for task ${task}${NO_COLOR}"
    let "fail_count++"
    continue
  fi

  seed_counter=1
  total_seeds=$(echo "$seeds" | wc -w)

  for seed in ${seeds}
  do
    echo -e "\t${CYAN_COLOR}[${seed_counter}/${total_seeds}] Starting check ${task} seed=${seed}${NO_COLOR}"
    ((seed_counter++))
    
    if ! ( [ -d "${tasks_dir}/${task}/${seed}/success/" ] && [ -d "${tasks_dir}/${task}/${seed}/fail/" ] ) ; then
      echo -e "\t\t${RED_COLOR}Error - missing success/fail directories for ${task} seed=${seed}${NO_COLOR}"
      ls -la "${tasks_dir}/${task}/${seed}/"
      let "fail_count++"
      continue
    fi
    
    # Фильтрация решений
    filtered_solutions=""
    if [[ -n "${task_filter[$task]}" ]]; then
        for solution in ${task_filter[$task]}
        do
            last_name="${solution}"
            if [ -f "${tasks_dir}/${task}/${seed}/success/${solution}" ]; then
                filtered_solutions+=" ${solution};success"
            fi
            if [ -f "${tasks_dir}/${task}/${seed}/fail/${solution}" ]; then
                filtered_solutions+=" ${solution};fail"
            fi
        done
        
        if [ -z "$filtered_solutions" ]; then
            echo -e "\t\t${RED_COLOR}No solutions found for filter: ${task_filter[$task]}${NO_COLOR}"
            let "fail_count++"
            continue
        fi
    else
        success_solutions=$(ls -1 "${tasks_dir}/${task}/${seed}/success/" 2>/dev/null | sed -e 's/$/;success/')
        fail_solutions=$(ls -1 "${tasks_dir}/${task}/${seed}/fail/" 2>/dev/null | sed -e 's/$/;fail/')
        filtered_solutions="${success_solutions} ${fail_solutions}"
    fi

    solutions=${filtered_solutions}
    solution_counter=1
    total_solutions=$(echo "$solutions" | wc -w)
    for (( i=1; i <= $N_retries; i++ ))
    do
    start=$(date +%s%3N)
      for s in ${solutions}
      do
        array=(${s//;/ })
        solution=${array[0]}
        expected_result=${array[1]}
        solution_path="$(pwd)/${tasks_dir}/${task}/${seed}/${expected_result}/${solution}"
        
        echo -e "\t\t${BLUE_COLOR}[${solution_counter}/${total_solutions}] Checking ${solution} (${solution_path}), expecting ${expected_result}${NO_COLOR}"
        ((solution_counter++))

        current_checker_run_flags=$(echo ${checker_run_flags}; cat "${solution_path}" | grep -Po '(?<=run_flags:).*')
        output=$(docker run --rm -t -v "${solution_path}:/app/solution.s:ro" riscvcourse/workshop_risc-v "${task}" --mode=check --seed="${seed}" ${current_checker_run_flags})
        exit_code="$?"

        echo "${output}"

        if [[ ("${expected_result}" == "success" && "${exit_code}" == "0" ) || ("${expected_result}" == "fail" && "${exit_code}" != "0" ) ]]
        then
          echo -e "\t\t${GREEN_COLOR}${task}, seed=${seed}, ${solution} is OK${NO_COLOR}"
        else
          let "fail_count++"
          echo -e "\t\t${RED_COLOR}Exit code mismatch for ${task} seed=${seed} ${solution} - expected ${expected_result}, got exit_code=${exit_code}${NO_COLOR}"
        fi
        echo -e "\n"
      done 
    end=$(date +%s%3N)
    duration=$((end-start))
    # echo "${task}:${last_name}:time.log"
    echo "${duration} " >> "${task}:${last_name}:time.log"
    done
  done
done

if [[ "${fail_count}" != "0" ]]
then
  echo -e "${RED_COLOR}Error, FAIL COUNT is ${fail_count}${NO_COLOR}"
  exit 1
else
  echo -e "${GREEN_COLOR}Everything is OK. Feel free to push${NO_COLOR}"
fi