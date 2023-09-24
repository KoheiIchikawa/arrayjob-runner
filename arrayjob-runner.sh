#!/bin/bash

usage() {
    echo "Usage: $0 -f <tasklist> [-n <tasks_per_job>] -s <task_program> -- [additional options for sbatch...]"
    exit 1
}

TASK_LIST=""
TASKS_PER_JOB="1"
TASK_SCRIPT=""

while getopts "f:n:s:" opt; do
    case $opt in
        f)
            TASK_LIST="$OPTARG"
            if [ ! -f "$TASK_LIST" ]; then
                echo "Error: '$TASK_LIST' is not found." >&2
                usage
            fi
            ;;
        n)
            TASKS_PER_JOB="$OPTARG"
            if [[ ! "$TASKS_PER_JOB" =~ ^[0-9]+$ ]]; then
                echo "Error: -n option requires an integer." >&2
                usage
            fi
            ;;
        s)
            TASK_SCRIPT="$OPTARG"
            if [ ! -x "$TASK_SCRIPT" ]; then
                echo "Error: '$TASK_SCRIPT' is not found or not executable." >&2
                usage
            fi
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$TASK_LIST" ]; then
    echo "Error: -f option is required." >&2
    usage
fi

if [ -z "$TASK_SCRIPT" ]; then
    echo "Error: -s option is required." >&2
    usage
fi

[[ ! "$TASK_SCRIPT" =~ ^(/|\./|\.\./|~) ]] && TASK_SCRIPT="./$TASK_SCRIPT"

JOB_NAME=$(basename "$TASK_SCRIPT")

TOTAL_TASKS=$(wc -l < "$TASK_LIST")
N=$(( (TOTAL_TASKS + TASKS_PER_JOB - 1) / TASKS_PER_JOB ))

echo "Processing tasks in $TASK_LIST with $TASK_SCRIPT, $TASKS_PER_JOB tasks each."
echo "Total tasks: $TOTAL_TASKS"
echo "Submitting job: sbatch --job-name=$JOB_NAME --array=1-$N $@ job.sh $TASK_LIST $TASKS_PER_JOB $TASK_SCRIPT"

sbatch --job-name=$JOB_NAME --array=1-$N $@ job.sh "$TASK_LIST" "$TASKS_PER_JOB" "$TASK_SCRIPT"
