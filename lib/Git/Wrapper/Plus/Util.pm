use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Util;
BEGIN {
  $Git::Wrapper::Plus::Util::AUTHORITY = 'cpan:KENTNL';
}
{
  $Git::Wrapper::Plus::Util::VERSION = '0.001001';
}

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

__END__

=pod

=encoding UTF-8

=head1 NAME

Git::Wrapper::Plus::Util - Misc plumbing tools for Git::Wrapper::Plus

=head1 VERSION

version 0.001001

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
