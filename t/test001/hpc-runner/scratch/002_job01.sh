#!/bin/bash
#
#SBATCH --share
#SBATCH --get-user-env
#SBATCH --job-name=002_job01
#SBATCH --output=/home/jillian/Dropbox/projects/perl/HPC-Runner-Command-Plugin-Blog/t/test001/hpc-runner/logs/2016-08-17-slurm_logs/002_job01.log
#SBATCH --cpus-per-task=12

cd /home/jillian/Dropbox/projects/perl/HPC-Runner-Command-Plugin-Blog/t/test001
hpcrunner.pl execute_job \
	--procs 4 \
	--infile /home/jillian/Dropbox/projects/perl/HPC-Runner-Command-Plugin-Blog/t/test001/hpc-runner/scratch/002_job01.in \
	--outdir /home/jillian/Dropbox/projects/perl/HPC-Runner-Command-Plugin-Blog/t/test001/hpc-runner/scratch \
	--logname 002_job01 \
	--process_table /home/jillian/Dropbox/projects/perl/HPC-Runner-Command-Plugin-Blog/t/test001/hpc-runner/logs/2016-08-17-slurm_logs/001-process_table.md \
	--metastr '{"batch":"002","total_batches":3,"batch_index":"2/3","tally_commands":"2-2/3","total_processes":3,"jobname":"job01","commands":1}'