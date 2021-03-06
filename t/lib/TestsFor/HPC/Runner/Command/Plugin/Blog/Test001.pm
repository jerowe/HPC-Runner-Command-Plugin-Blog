package TestsFor::HPC::Runner::Command::Plugin::Test001;

use Test::Class::Moose;
use HPC::Runner::Command;
use Cwd;
use FindBin qw($Bin);
use File::Path qw(make_path remove_tree);
use IPC::Cmd qw[can_run];
use Data::Dumper;
use Capture::Tiny ':all';
use Slurp;
use File::Slurp;
use DateTime;

sub construct_001 {

    chdir("$Bin/test001");
    my $t = "$Bin/test001/script/test001.1.sh";

    my $dt = DateTime->now( time_zone => 'local' );

    my $ymd = $dt->ymd();

    MooseX::App::ParsedArgv->new(
        argv => [
            "execute_job",
            "--infile",
            $t,
            "--job_plugins",
            "Blog",
            "--logname",
            "001_job01",
            "--process_table",
            "$Bin/test001/hpc-runner/logs/$ymd-slurm_logs/001-process_table.md"
        ]
    );

    my $test = HPC::Runner::Command->new_with_command();

    return $test;
}

sub construct_002 {

    chdir("$Bin/test001");
    my $t = "$Bin/test001/script/test001.1.sh";

    MooseX::App::ParsedArgv->new( argv =>
            [ "submit_jobs", "--infile", $t, "--hpc_plugins", "Dummy,Blog" ]
    );

    my $test = HPC::Runner::Command->new_with_command();
    $test->logname('slurm_logs');

    return $test;
}

sub test_001 : Tags(prep) {
    my $test = shift;

    remove_tree("$Bin/test001");
    make_path("$Bin/test001/script");

    ok(1);
}

sub test_002 : Tags(prep) {
    my $test = shift;

    open( my $fh, ">$Bin/test001/script/test001.1.sh" );
    print $fh <<EOF;
#HPC jobname=job01
#HPC cpus_per_task=12
#HPC commands_per_node=1

#NOTE job_tags=Sample1
echo "hello world from job 1" && sleep 5

#NOTE job_tags=Sample2
echo "hello again from job 2" && sleep 5

#NOTE job_tags=Sample3
echo "goodbye from job 3"
EOF

    close($fh);

    ok(1);
}

sub test_003 : Tags(require) {
    my $self = shift;

    require_ok('HPC::Runner::Command::Plugin::Blog');
    ok(1);
}

sub test_004 : Tags(submit_jobs) {
    my $self = shift;

    my $test = construct_002;
    $test->execute();
    ok(1);
}

sub test_005 : Tags(execute_jobs) {
    my $self = shift;

    $ENV{SBATCH_JOB_ID} = '1234';
    my $test = construct_001;
    $test->gen_load_plugins();

    $test->execute();

    ok(1);
}

1;
