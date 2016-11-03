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

with 'HPC::Runner::Command::Utils::Log';

=head1 HPC::Runner::Command::Plugin::Logger::Blog;

Pretty log files in a hexo blog!

=cut

=head2 Attributes

=cut

=head2 Subroutines

=cut

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

    ##TODO FIX THIS
    my($dt, $ymd, $hms) = $self->datetime_now();
    my ( $lf, $pid ) = $self->get_title;

    $DB::single = 2;

    $self->print_log_yaml( $p, $lf, $dt, $pid );

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
    my $task_tags      = $self->pop_note_meta;

    #Do I need this?
    #if ($task_tags && $pid) {
	#$self->set_task_tag( $pid => $task_tags );
    #}

    #Move this to main
    push( @{$orig_tags}, hostname );

    if ($task_tags) {
        foreach my $m (@$task_tags) {
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
	#PID is also in the file name
        $pid     = $self->get_task_tag($counter);
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
