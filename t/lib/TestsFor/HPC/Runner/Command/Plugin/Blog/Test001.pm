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

    my @chars = ('a'..'z', 'A'..'Z', 0..9);
    my $string = join '', map { @chars[rand @chars]  } 1 .. 8;

    if(exists $ENV{'TMP'}){
        $test_dir = $ENV{TMP}."/hpcrunner/$string";
    }
    else{
        $test_dir = "/tmp/hpcrunner/$string";
    }

    make_path($test_dir);
    make_path("$test_dir/script");

    chdir($test_dir);

    if(can_run('git') && !-d $test_dir."/.git"){
        system('git init');
    }

    open( my $fh, ">$test_dir/script/test001.1.sh" );

    print $fh <<EOF;
echo "hello world from job 1" && sleep 5

echo "hello again from job 2" && sleep 5

echo "goodbye from job 3"

#NOTE job_tags=hello,world
echo "hello again from job 3" && sleep 5

EOF

    close($fh);

    return $test_dir;
}


sub test_shutdown {

    my $test_dir = make_test_dir;
    chdir("$Bin");
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
        ]
    );

    my $test = HPC::Runner::Command->new_with_command();

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
