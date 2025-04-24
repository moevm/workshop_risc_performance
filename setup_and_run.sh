#!/bin/bash

set -e

args=(
    # lab1_asm_intro
    "lab1_asm_intro:assembler_error.s"
    "lab1_asm_intro:call.s"
    "lab1_asm_intro:ecall.s"
    "lab1_asm_intro:empty.s"
    "lab1_asm_intro:loop.s"
    "lab1_asm_intro:no_globl.s"
    "lab1_asm_intro:no_ret.s"
    "lab1_asm_intro:no_solution.s"
    "lab1_asm_intro:segfault.s"
    "lab1_asm_intro:wrong_calc.s"
    "lab1_asm_intro:correct.s"

    # lab3_condition
    "lab3_condition:assembler_error.s"
    "lab3_condition:call.s"
    "lab3_condition:ecall.s"
    "lab3_condition:empty.s"
    "lab3_condition:loop.s"
    "lab3_condition:no_globl.s"
    "lab3_condition:no_ret.s"
    "lab3_condition:no_solution.s"
    "lab3_condition:segfault.s"
    "lab3_condition:wrong_calc.s"
    "lab3_condition:correct.s"

    # lab4_string
    "lab4_string:empty_main.s"
    "lab4_string:no_exit.s"
    "lab4_string:no_main.s"
    "lab4_string:non_ascii.s"
    "lab4_string:wrong.s"
    "lab4_string:correct.s"

    # lab5_daemon
    "lab5_daemon:early_exit.s"
    "lab5_daemon:fail_button.s"
    "lab5_daemon:fail_led.s"
    "lab5_daemon:no_delay.s"
    "lab5_daemon:segfault.s"
    "lab5_daemon:wrong_answer.s"
    "lab5_daemon:correct.s"
    "lab5_daemon:syntax_error.s"
    "lab5_daemon:sm.s"

    # lab6_interrupt
    "lab6_interrupt:event_no_increment.s"
    "lab6_interrupt:event_wrong_increment.s"
    "lab6_interrupt:load_no_counter.s"
    "lab6_interrupt:load_no_function.s"
    "lab6_interrupt:load_no_increment.s"
    "lab6_interrupt:load_wrong_function.s"
    "lab6_interrupt:load_wrong_increment.s"
    "lab6_interrupt:loop.s"
    "lab6_interrupt:segfault.s"
    "lab6_interrupt:unload.s"
    "lab6_interrupt:wrong_answer.s"
    "lab6_interrupt:wrong_answer_with_flags.s"
    "lab6_interrupt:correct.s"
    "lab6_interrupt:correct_with_flags.s"

    # lab7_vectors
    "lab7_vectors:no_load.s"
    "lab7_vectors:no_solution.s"
    "lab7_vectors:no_store.s"
    "lab7_vectors:no_vec_op.s"
    "lab7_vectors:no_vectors.s"
    "lab7_vectors:segfault.s"
    "lab7_vectors:wrong_answer.s"
    "lab7_vectors:correct.s"
)


if ! [ -d ./results/ ]; then
mkdir results
fi

# clone repo
if ! [ -d ./workshop_risc-v/ ]; then
echo "Cloning risc-v repo"
git clone https://github.com/moevm/workshop_risc-v.git
fi

# copy scripts
cp -f run_load.sh ./workshop_risc-v/
cp -f analyze_*.py ./workshop_risc-v/
cp -f load.sh ./workshop_risc-v/tst/

cd workshop_risc-v
# build image
./scripts/build.sh


# ./run_load.sh $*

for arg in "${args[@]}"; do
    output_dir="../results/${arg}"
    mkdir -p "$output_dir"
    echo "Running test: $arg"
    ./run_load.sh "$arg"
    cp -f ./*.png ./*.log "$output_dir/"
    rm -f ./*.png ./*.log
done


cp -f ./*.png ../results/
cp -f ./*.log ../results/
rm ./*.png ./*.log
cd -

echo "Done! Data placed in ./results"
