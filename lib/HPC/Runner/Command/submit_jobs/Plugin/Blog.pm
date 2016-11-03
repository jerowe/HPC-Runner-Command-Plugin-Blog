package HPC::Runner::Command::submit_jobs::Plugin::Blog;

use Moose::Role;
use Data::Dumper;
use YAML;
use YAML::XS 'LoadFile';
use File::Basename;
use File::Path qw(make_path remove_tree);

with 'HPC::Runner::Command::Plugin::Blog';

after 'execute' => sub {
    my $self = shift;

    $self->env_log;
    $self->print_process_log_header;
};

sub env_log {
    my $self = shift;

    my($dt, $ymd, $hms) = $self->datetime_now;
    my $tt = $dt->strftime('%F %T %z');

    open( my $p, ">>" . $self->logdir . "/$ymd-ENV.md" )
        or die print "Couldn't open log file what is happening here!? $!\n";

    my $tags = $self->tags;

    #TODO if length tags

    my $hash = { title => "ENV", tags => $tags,  date => "$tt" };
    print $p Dump $hash;
    print $p "---\n\n";

    print $p "## Environment\n\n";

    #Print modules if they are there
    print $p "### Modules\n" if $ENV{'LOADEDMODULES'};
    print $p "```bash\n" . $ENV{'LOADEDMODULES'} . "\n```\n"
        if $ENV{'LOADEDMODULES'};

    print $p "### Path\n";
    my $path = $ENV{'PATH'};
    if ($path) {
        my @tmp = split( ':', $path );
        print $p "```bash\n" . join( "\n", @tmp ) . "\n```\n";
    }

    #TODO Add back in Git Versioning
    print $p "## Git Things\n\n" if $self->has_git;

    print $p "Current branch: " . $self->current_branch . "\n" if $self->has_current_branch;
    print $p "Current version: " . $self->version . "\n" if $self->has_version;

    close $p;
}

sub print_process_log_header {
    my $self = shift;

    my($dt, $ymd, $hms) = $self->datetime_now;
    my $tt = $dt->strftime('%F %T %z');

    if(! -e $self->process_table){
        make_path(dirname($self->process_table));
    }

    open(my $p, ">" . $self->process_table )
        or die $self->app_log->warn("Couldn't open log file please make sure you have the necessary permissions. $!\n");

    my $tags = $self->tags;
    push( @$tags, 'task_table' );

    my $hash = { title => "Process Table", tags => $tags, date => "$tt" };
    print $p Dump $hash;
    print $p "---\n\n";

    print $p "||Version|| Scheduler Id || Jobname || Task Tags || ProcessID || ExitCode || Duration ||\n";

    close $p;
}

around 'create_plugin_str' => sub {

    my $orig = shift;
    my $self = shift;

    $self->job_plugins( [] ) unless $self->job_plugins;

    push(
        @{ $self->job_plugins },
        'Blog'
    );

    my $val = $self->$orig(@_);

    return $val;
};

1;
