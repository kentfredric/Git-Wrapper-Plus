use 5.006;    # our
use strict;
use warnings;

package Git::Wrapper::Plus::Util;

our $VERSION = '0.004012';

# ABSTRACT: Misc plumbing tools for Git::Wrapper::Plus

# AUTHORITY

use Sub::Exporter::Progressive -setup => {
  exports => [qw( exit_status_handler )],
  groups  => {
    default => [qw( exit_status_handler )],
  },
};

use Try::Tiny qw( try catch );
use Scalar::Util qw(blessed);

=func C<exit_status_handler>

C<Git::Wrapper> throws exceptions in a few cases, and some of these
cases are considered normal flow control for C<Git::Wrapper::Plus>.

For instance, some functions in C<git> emit no output, and return an exit code.

C<Git::Wrapper> treats that circumstance as a fatal exception!.

Its messy getting all the right C<try/catch> stuff going, and checking
for the object type, and then checking if the exception type is recognized or not,
and only then determining if the status was white-listed.

So:

    use Git::Wrapper::Plus::Util qw(exit_status_handler);

    my $ok = exit_status_handler ( $code , {
        1 => sub { undef }
    });

The above code normally executes C<$code>, and returns C<1> if no exception occurred.

If an exception occurred, and it is not a C<Git::Wrapper::Exception>, it is simply re-thrown.

And for any status codes listed in the map, the attached C<sub> is executed, and C<exit_status_handler>
propagates its return value.

Any other circumstances ( like a status code not existing in the map ) are simply re-thrown.

=cut

sub exit_status_handler {
  my ( $callback, $status_map ) = @_;
  my $return = 1;
  try {
    $callback->();
  }
  catch {
    ## no critic (ErrorHandling::RequireUseOfExceptions)
    undef $return;
    die $_ unless ref;
    die $_ unless blessed $_;
    die $_ unless $_->isa('Git::Wrapper::Exception');
    for my $status ( sort keys %{$status_map} ) {
      if ( $status == $_->status ) {
        $return = $status_map->{$status}->($_);
        return;
      }
    }
    die $_;
  };
  return 1 if $return;
  return;
}

1;

