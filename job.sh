#!/bin/bash

if [ -z "$SLURM_ARRAY_TASK_ID" ]; then
    echo "Use arrayjob-runner.sh to submit job." >&2
    exit 1
fi

TASK_LIST="$1"
TASKS_PER_JOB="$2"
TASK_SCRIPT="$3"

if [ ! -f "$TASK_LIST" ]; then
    echo "Error: '$TASK_LIST' is not found." >&2
    exit 1
fi

if [[ ! "$TASKS_PER_JOB" =~ ^[0-9]+$ ]]; then
    echo "Error: $TASKS_PER_JOB is an invalid value for tasks_per_job." >&2
    exit 1
fi

if [ ! -x "$TASK_SCRIPT" ]; then
    echo "Error: '$TASK_SCRIPT' is not found or not executable." >&2
    exit 1
fi

# Calculate the line numbers of the first and last tasks to be processed
START_LINE=$(( (SLURM_ARRAY_TASK_ID - 1) * TASKS_PER_JOB + 1 ))
END_LINE=$(( SLURM_ARRAY_TASK_ID * TASKS_PER_JOB ))

for LINE in $(seq $START_LINE $END_LINE); do
    TASK=$(sed -n "${LINE}p" "$TASK_LIST")

    if [ -n "$TASK" ]; then
        if "$TASK_SCRIPT" "$TASK"; then
            echo "Completed: $TASK"
        else
            echo "Failed: $TASK"
            echo "$TASK" >&2
        fi
    fi

done
