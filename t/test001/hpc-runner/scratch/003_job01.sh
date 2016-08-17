#!/bin/bash
#
#SBATCH --share
#SBATCH --get-user-env
#SBATCH --job-name=003_job01
#SBATCH --output=/home/jillian/Dropbox/projects/perl/HPC-Runner-Command-Plugin-Blog/t/test001/hpc-runner/logs/2016-08-17-slurm_logs/003_job01.log
#SBATCH --cpus-per-task=12

cd /home/jillian/Dropbox/projects/perl/HPC-Runner-Command-Plugin-Blog/t/test001
hpcrunner.pl execute_job \
	--procs 4 \
	--infile /home/jillian/Dropbox/projects/perl/HPC-Runner-Command-Plugin-Blog/t/test001/hpc-runner/scratch/003_job01.in \
	--outdir /home/jillian/Dropbox/projects/perl/HPC-Runner-Command-Plugin-Blog/t/test001/hpc-runner/scratch \
	--logname 003_job01 \
	--process_table /home/jillian/Dropbox/projects/perl/HPC-Runner-Command-Plugin-Blog/t/test001/hpc-runner/logs/2016-08-17-slurm_logs/001-process_table.md \
	--metastr '{"total_processes":3,"jobname":"job01","commands":1,"tally_commands":"3-3/3","batch_index":"3/3","batch":"003","total_batches":3}'