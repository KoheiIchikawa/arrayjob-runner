# arrayjob-runner

`arrayjob-runner` is a tool designed to divide a list of tasks into arbitrary subsets, and then run them concurrently using Slurm ArrayJob. It was developed to eliminate the repetitive process of coding similar tasks for each ArrayJob. By centralizing shared implementations, this tool offers a simplified and easily reusable approach.

## Features:

- **Task Division**: Split large task lists into manageable and effient sized chunks for parallel execution.
- **Costom Task Program**: Supports user-defined tasks.

## Prerequisites:

Ensure you have Slurm set up and configured properly on your system.

## Usage:

1. Prepare a list of task.

    Typically, a file listing the files to be processed is used. Each line is split and passed to the task processing program as a command-line argument.

    ```
    /path/to/file001
    /path/to/file002
    /path/to/file003
    ...
    ```

    For a quick way to generate a task list from the files in a given directory, you can use the following command:

    ```
    find /path/to/directory -type f > tasklist.txt
    ```

2. Prepare a task program or a script

    A program that accepts a single command-line argument and processes it accordingly. If the processing fails, it should return a non-zero exit status. Tasks that return a non-zero exit status are logged in the standard error. You can use `task_template.sh` as a template.

    This program can also be executed manually for testing purposes. Before running bulk processes with ArrayJob, you can perform a preliminary test by providing a test input as a command-line argument and executing this program.


3. Run `arrayjob-runner.sh`:

    ```
    ./arrayjob-runner.sh -f <tasklist> [-n <tasks_per_job>] -s <task_program> -- [additional options for sbatch...]
    ```
    This program splits the `tasklist` into chunks of `tasks_per_job` lines each, and creates an ArrayJob. The specified `task_program` is used for processing the tasks. If `tasks_per_job` is omitted, the `tasklist` is divided line by line, generating an ArrayJob that creates a job for each line. `tasks_per_job` is useful for adjusting the granularity of individual jobs in an ArrayJob. If each task is too small and there's concern that creating a separate job for every line in the `tasklist` would introduce significant overhead, specify `tasks_per_job` to adjust the number of tasks handled by a single job in an ArrayJob.

    You can specify command-line arguments to be passed to `sbatch` after `--`, such as designating the required CPU or memory for each job within the ArrayJob. For easy tracking of tasks that produce errors, consider separately redirecting the standard error output.

    Example:
    ```
    ./arrayjob-runner.sh -f tasklist.txt -s task.sh -- -e slurm-%A_%a.err
    cat slurm-*.err > failed_tasklist.txt
    ```    
