package HPC::Runner::Command::new::Plugin::Blog;

use Moose::Role;

use File::Path qw(make_path remove_tree);
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

extends 'HPC::Runner::Command';
with 'HPC::Runner::Command::Utils::Log';
with 'HPC::Runner::Command::Plugin::Blog';

=head1 HPC::Runner::Command::new::Plugin::Blog;

Base class for HPC::Runner::submit_jobs::Plugin::Blog and HPC::Runner::execute_job::Plugin::Blog

=cut

=head2 Attributes

=cut

=head2 Subroutines

=cut

after 'execute' => sub {
    my $self = shift;

    make_path( $self->projectname . "/hpcrunner/www" );

    chdir 'hpc-runner/www'
        or die $self->app_log->fatal("Could not change to www directory!");

    if ( !$self->debug_commands ) {
        return;
    }

    $self->app_log->info(
        "Creating new notebook this could take some time...");
    $self->execute_command("hexo init hexo ")
        or die $self->log->fatal("Could not run hexo init");

    $self->execute_command( "npm install",
        "Installing npm packages... This could take some take" )
        or die $self->log->fatal("Could not complete npm install!");
    $self->execute_command("npm install hexo-generator-feed --save");

};

sub debug_commands {
    my $self = shift;

    if ( !can_run('npm') ) {
        $self->app_log->warn(
            "NPM is not installed or not in your path! You must install Nodejs/npm in order to view your new lab notebook!"
        );
        return 0;
    }
    elsif ( !can_run('hexo') ) {
        $self->app_log->warn(
            "Hexo is not installed or not in your path! You must install hexo in order to view your new lab notebook!"
        );
        return 0;
    }
}

1;
