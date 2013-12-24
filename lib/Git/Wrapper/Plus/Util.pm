use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Util;

# ABSTRACT: Misc plumbing tools for Git::Wrapper::Plus

use Sub::Exporter::Progressive -setup => {
  exports => [qw( exit_status_handler )],
  groups  => {
    default => [qw( exit_status_handler )],
  }
};

use Try::Tiny;
use Scalar::Util qw(blessed);

sub exit_status_handler {
  my ( $callback, $status_map ) = @_;
  my $return = 1;
  &try(
    $callback,
    catch {
      undef $return;
      if ( not ref $_ ) {
        die $_;
      }
      if ( not blessed $_ ) {
        die $_;
      }
      if ( not $_->isa('Git::Wrapper::Exception') ) {
        die $_;
      }
      for my $status ( sort keys %{$status_map} ) {
        if ( $status == $_->status ) {
          $return = $status_map->{$status}->($_);
          return;
        }
      }
      die $_;
    }
  );
  return 1 if $return;
  return;
}

1;

