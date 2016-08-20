package TestsFor::HPC::Runner::Command::Plugin::Test001;

use Test::Class::Moose;
use HPC::Runner::Command;
use Cwd;
use FindBin qw($Bin);
use File::Path qw(make_path remove_tree);
use IPC::Cmd qw[can_run];
use Data::Dumper;
use Capture::Tiny ':all';
use DateTime;

sub make_test_dir{
    my $test_dir;

    if(exists $ENV{'TMP'}){
        $test_dir = $ENV{TMP}."/hpcrunner/test001";
    }
    else{
        $test_dir = "/tmp/hpcrunner/test001";
    }

    make_path($test_dir);

    chdir($test_dir);
    if(can_run('git') && !-d $test_dir."/.git"){
        system('git init');
    }

    return $test_dir;
}

sub test_shutdown {

    my $test_dir = make_test_dir;
    chdir("$Bin");
    remove_tree($test_dir);
}

sub construct_001 {

    my $test_dir = make_test_dir;
    my $t = "$test_dir/script/test001.1.sh";

    my $dt = DateTime->now( time_zone => 'local' );

    my $ymd = $dt->ymd();

    #TODO How to decide version?
    MooseX::App::ParsedArgv->new(
        argv => [
            "execute_job",
            "--infile",
            $t,
            "--job_plugins",
            "Blog",
            "--version",
            "0.01",
            "--logname",
            "001_job01",
            "--process_table",
            "$test_dir/hpc-runner/0.01/logs/$ymd-slurm_logs/001-process_table.md"
        ]
    );

    my $test = HPC::Runner::Command->new_with_command();
    $test->version("0.01");

    return $test;
}

sub construct_002 {

    my $test_dir = make_test_dir;
    my $t = "$test_dir/script/test001.1.sh";

    MooseX::App::ParsedArgv->new( argv =>
            [ "submit_jobs", "--infile", $t, "--hpc_plugins", "Dummy,Blog" ]
    );

    my $test = HPC::Runner::Command->new_with_command();
    $test->logname('slurm_logs');

    return $test;
}

sub test_002 : Tags(prep) {
    my $test = shift;

    my $test_dir = make_test_dir;
    make_path("$test_dir/script");

    open( my $fh, ">$test_dir/script/test001.1.sh" );
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

    if( can_run('git') ){
        system('git add -A');
        system('git commit -m "test commit"');
    }

    ok(1);
}

sub test_003 : Tags(require) {
    my $self = shift;

    require_ok('HPC::Runner::Command::Plugin::Blog');
    ok(1);
}

sub test_004 : Tags(submit_jobs) {

    my $test = construct_002;

    capture { $test->execute() };

    ok(1);
}

sub test_005 : Tags(execute_jobs) {
    my $self = shift;

    diag('testing execute jobs!');
    $ENV{SBATCH_JOB_ID} = '1234';
    my $test = construct_001;

    $test->execute();

    ok(1);
}

1;
