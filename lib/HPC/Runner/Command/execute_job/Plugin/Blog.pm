package HPC::Runner::Command::execute_job::Plugin::Blog;
use Moose::Role;
use File::Copy qw(move);

with 'HPC::Runner::Command::Plugin::Blog';

=head1 HPC::Runner::Command::execute_job::Plugin::Blog

=head2 Subroutines

=head3 before log_cmd_messages

Static blog generators are not built for stupidly large files

=cut

before 'log_cmd_messages' => sub {
    my $self    = shift;
    my $level   = shift;
    my $message = shift;
    my $cmdpid  = shift;

    my $details = File::Details->new( $self->logdir . "/" . $self->logfile );
    my $size    = $details->size();

    #10000
    return unless $size > 10000;

    my $logfile     = $self->logdir . "/" . $self->logfile;
    my $postprocess = <<EOF;
    sed -i '50 c\<!-- more -->' $logfile
EOF

    #print "Postprocess is: $postprocess\n";
    system($postprocess);

    my $lf = $self->logfile;
    if ( $lf =~ m/CMD_(\d+)-(\d+)/ ) {
        my (@match) = $lf =~ m/CMD_(\d+)-(\d+)/;
        my ( $n, $nn ) = ( $match[0], $match[1] );
        my $old = $nn;
        $nn = sprintf( "%.f", $nn );
        $nn = $nn + 1;
        $nn = sprintf( "%03d", $nn );
        $lf =~ s/CMD_$n-$old/CMD_$n-$nn/;
        $self->logfile($lf);
        $self->command_log( $self->init_log );
    }
    elsif ( $lf =~ m/CMD_(\d+)/ ) {

        my $n = $1;

        #Rename the old file to -000
        my $old_lf = $self->logfile;
        my $move_lf = $old_lf;
        $move_lf =~ s/CMD_$n/CMD_$n-000/;

        move($self->logdir."/".$old_lf, $self->logdir."/".$move_lf);

        #Create new log file
        $lf =~ s/CMD_$n/CMD_$n-001/;

        #$DB::single = 2;
        $self->logfile($lf);
        $self->command_log( $self->init_log );
    }
};

1;
