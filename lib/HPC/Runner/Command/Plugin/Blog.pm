package HPC::Runner::Command::Plugin::Blog;

our $VERSION = '0.01';

use Moose::Role;
use Data::Dumper;
use Cwd;

use File::Path qw(make_path remove_tree);
use namespace::autoclean;
use YAML;
use YAML::XS 'LoadFile';
use DateTime;
use DateTime::TimeZone;
use List::Uniq ':all';
use File::Details;
use Data::Dumper;
use Moose::Util::TypeConstraints;
use Env;
use Sys::Hostname;

#use Carp::Always;

=head1 HPC::Runner::Command::Plugin::Logger::Blog;

Pretty log files in a hexo blog!

=cut

=head2 Attributes

=cut

#Move his to main app

has 'tags' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    required => 0,
    default  => sub {
        return [];
    },
);

has 'project_data' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

=head2 Subroutines

=cut

#TODO This should be in Git
#sub git_things {
    #my $self = shift;

    #$self->init_git;
    #$self->dirty_run;
    #$self->git_info;
    #if ( $self->tags ) {
        #push( @{ $self->tags }, "$self->{version}" );
    #}
    #else {
        #$self->tags( [ $self->version ] );
    #}
    #my @tmp = uniq( @{ $self->tags } );
    #$self->tags( \@tmp );
#}

#sub set_weblogdir {
    #my $self = shift;
    #my $logdir;

    #$DB::single = 2;

    ##$self->git_things;

    #if (-e getcwd()."/.project.yml") {
        #my $yaml = LoadFile( $self->git_dir . "/.project.yml" )
            #or die print
            #"Could not open .project.yml! Is this a HPC::Runner::Web project? $!\n";
        #$self->project_data($yaml);
        #$DB::single = 2;
    #}
    #else{

    #}

    ##$logdir = $yaml->{'BlogDir'};
    #$logdir = getcwd()."/www";
    #make_path(getcwd()."/www");
    ##$logdir .= "/" . $self->version;

    #$logdir = $logdir . "/" . $self->set_logfile . "-" . $self->logname;
    #$logdir =~ s/\.md//g;
    #$logdir =~ s/\.log//g;

    #$DB::single = 2;

    #make_path($logdir) if !-d $logdir;

    #return $logdir;
#}

#before 'execute' => sub {
    #my $self = shift;

    #$self->env_log;
#};

###TODO Change this to make it Jekyll Aware
sub env_log {
    my $self = shift;

    my($dt, $ymd, $hms) = $self->datetime_now;
    my $tt = $dt->strftime('%F %T %z');

    open( my $p, ">>" . $self->logdir . "/$ymd-ENV.md" )
        or die print "Couldn't open log file what is happening here!? $!\n";

    $DB::single = 2;

    my $hash = { title => "ENV",  date => "$tt" };
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
    #print $p "## Git Things\n\n";

    #print $p "Current branch: " . $self->current_branch . "\n";
    #print $p "Current version: " . $self->version . "\n";

    close $p;

}

sub print_process_log_header {
    my $self = shift;

    my($dt, $ymd, $hms) = $self->datetime_now;
    my $tt = $dt->strftime('%F %T %z');

    open(my $p, ">>" . $self->process_table )
        or die print "Couldn't open log file what is happening here!? $!\n";

    #my $tags = $self->tags;
    #push( @$tags, 'process_table' );

    #$hash = { title => "Process Table", tags => $tags, date => "$tt" };
    my $hash = { title => "Process Table",  date => "$tt" };
    print $p Dump $hash;
    print $p "---\n\n";

    #print $p
        #"|SchedulerID |JobName |Version |Job Tags |Cmd PID |Exit Code |Process Duration|\n";
    close $p;
}

before 'init_log' => sub {
    my $self = shift;

    my $tt = $self->logfile;
    if ( $tt =~ m/\.log$/ ) {
        $tt =~ s/\.log/\.md/g;
    }
    elsif ( $tt !~ m/\.md$/ ) {
        $tt .= ".md";
    }

    $self->logfile($tt);
};

after 'init_log' => sub {
    my $self = shift;

    open( my $p, ">>" . $self->logdir . "/" . $self->logfile )
        or die print "Couldn't open log file what is happening here!? $!\n";

    my $tt = $self->dt;
    my ( $lf, $pid ) = $self->get_title;

    $DB::single = 2;

    $self->print_log_yaml( $p, $lf, $tt, $pid );

    close $p;
};

sub print_log_yaml {
    my $self = shift;
    my $p    = shift;
    my $lf   = shift;
    my $tt   = shift;
    my $pid  = shift;

    $DB::single = 2;
    if ( $self->can('job_scheduler_id') ) {
        push( @{ $self->tags }, "SchedulerID_$self->{job_scheduler_id}" )
            if $self->job_scheduler_id;
    }
    if ( $self->can('jobname') ) {
        push( @{ $self->tags }, "Jobname_$self->{jobname}" )
            if $self->jobname;
    }

    #Already in main
    my $orig_tags = $self->tags;
    my $meta      = $self->pop_note_meta;
    if ($meta) {
        $self->set_job_tag( $pid => $meta );
    }

    #Move this to main
    push( @{$orig_tags}, hostname );

    if ($meta) {
        foreach my $m (@$meta) {
            next unless $m;
            push( @$orig_tags, $m );
        }
    }
    @{$orig_tags} = uniq( @{$orig_tags} );

    my $hash = { title => $lf, tags => $orig_tags, date => "$tt" };

    print $p Dump $hash;
    print $p "---\n\n";

    print $p "### DateTime: $tt\n";
    if ($pid) {
        print $p "### ProcessID: $pid\n";
    }
    if ( $self->job_scheduler_id ) {
        print $p "### SchedulerID: " . $self->job_scheduler_id . "\n";
    }
    print $p "\n\n";
}

sub get_title {
    my $self = shift;
    my ( $tt, $lf, $pid, $cc, $counter );

    $lf = $self->logfile;
    $lf =~ s/\.md//;

    if ( $lf =~ m/(CMD_\d+)/ ) {
        my $t = $1;
        if ( $lf =~ m/CMD_\d+-(\d+)/ ) {
            $cc = $1;
        }

        $lf = $t;
    }

    if ( $lf =~ m/CMD_(\d+)/ ) {
        $counter = $1;
        $pid     = $self->get_job_tag($counter);
    }

    elsif ( $lf =~ m/MAIN/ ) {
        $lf = "MAIN";
    }

    if ( $self->logname ) {
        if ($cc) {
            $lf = $self->logname . " $lf $cc";
        }
        else {
            $lf = $self->logname . " $lf";
        }
    }

    return ( $lf, $pid );
}

##Avoid stupidly long log files - or hexo will DIE

#before 'log_cmd_messages' => sub {
    #my $self    = shift;
    #my $level   = shift;
    #my $message = shift;
    #my $cmdpid  = shift;

    #my $details = File::Details->new( $self->logdir . "/" . $self->logfile );
    #my $size    = $details->size();

##Make it an excerpt
##Forget this - will include postprocessing script
##if($size > 800) {
##open(my $p, ">>".$self->logdir."/".$self->logfile) or die print "Couldn't open log file what is happening here!? $!\n";
##print $p  "<!-- more -->\n\n";
##close $p;
##}

    ##10000
    #return unless $size > 10000;

    #my $logfile     = $self->logdir . "/" . $self->logfile;
    #my $postprocess = <<EOF;
    #sed -i '50 c\<!-- more -->' $logfile
#EOF

    ##print "Postprocess is: $postprocess\n";
    #system($postprocess);

    #my $lf = $self->logfile;
    #if ( $lf =~ m/CMD_(\d+)-(\d+)/ ) {
        #my (@match) = $lf =~ m/CMD_(\d+)-(\d+)/;
        #my ( $n, $nn ) = ( $match[0], $match[1] );
        #my $old = $nn;
        #$nn = sprintf( "%.f", $nn );
        #$nn = $nn + 1;
        #$lf =~ s/CMD_$n-$old/CMD_$n-$nn/;
        #$self->logfile($lf);
        #$self->command_log( $self->init_log );
    #}
    #elsif ( $lf =~ m/CMD_(\d+)/ ) {
        #my $n = $1;
        #$lf =~ s/CMD_$n/CMD_$n-001/;
        #$DB::single = 2;
        #$self->logfile($lf);
        #$self->command_log( $self->init_log );
    #}
#};

###TODO extend this in HPC-Runner-Web for ENV tags
#sub log_table {
    #my $self     = shift;
    #my $cmdpid   = shift;
    #my $exitcode = shift;
    #my $duration = shift;

    ####Add Exit Code to front matter tags
    ###Should have something so that on multipart logs its ok
    #my $logfile  = $self->logdir . "/" . $self->logfile;
    #my $add_tags = <<EOF;
#sed -i '/tags:/a\\  - ExitCode$exitcode' $logfile
#EOF
    #system($add_tags);
    ####PostProcess?
    #my $postprocess = <<EOF;
    #sed -i '50 c\<!-- more -->' $logfile
#EOF
    #system($postprocess);

    #open( my $pidtablefh, ">>" . $self->process_table )
        #or die print "Couldn't open process file $!\n";
    #my $aref = $self->get_job_tag($cmdpid) || [];

    #my $job_tags = join( ", ", @{$aref} ) || "";
    #my $version = $self->version;

    #if ( $self->can('job_scheduler_id') && $self->can('jobname') ) {
        #my $schedulerid = $self->job_scheduler_id // '';
        #my $jobname     = $self->jobname          // '';

        #print $pidtablefh <<EOF;
#|$schedulerid|$jobname|$version|$job_tags|$cmdpid|$exitcode|$duration|
#EOF
    #}
    #else {
        ##print $pidtablefh "### $self->{cmd}\n";
        #print $pidtablefh <<EOF;
#|$cmdpid|$exitcode|$duration|
#EOF
    #}
#}

1;

__END__

=encoding utf-8

=head1 NAME

HPC::Runner::Command::Plugin::Blog - Blah blah blah

=head1 SYNOPSIS

  use HPC::Runner::Command::Plugin::Blog;

=head1 DESCRIPTION

HPC::Runner::Command::Plugin::Blog is

=head1 AUTHOR

Jillian Rowe E<lt>jillian.e.rowe@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2016- Jillian Rowe

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
