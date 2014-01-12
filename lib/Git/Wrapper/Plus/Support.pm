use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Support;
BEGIN {
  $Git::Wrapper::Plus::Support::AUTHORITY = 'cpan:KENTNL';
}
$Git::Wrapper::Plus::Support::VERSION = '0.002001';
# ABSTRACT: Determine what versions of things support what

use Moo;














has 'git' => ( is => ro =>, required => 1 );

has 'versions' => ( is => ro =>, lazy => 1, builder => 1 );
has 'version'  => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_versions {
  my ( $self, ) = @_;
  require Git::Wrapper::Plus::Versions;
  return Git::Wrapper::Plus::Versions->new( git => $self->git );
}

our $command_db = {
  'for-each-ref' => [ { 'min' => '1.4.4' }, ],
  'init'         => [ { 'min' => '1.5.0' }, ],
  'init-db'      => [ { 'min' => '0.99' }, ],
};























sub supports_command {
  my ( $self, $command ) = @_;
  if ( not exists $command_db->{$command} ) {
    return undef;
  }
  for my $pair ( @{ $command_db->{$command} } ) {
    if ( exists $pair->{min} and not exists $pair->{max} ) {
      if ( $self->versions->newer_than( $pair->{min} ) ) {
        return 1;
      }
      return 0;
    }
    if ( exists $pair->{max} and not exists $pair->{min} ) {
      if ( $self->versions->older_than( $pair->{max} ) ) {
        return 1;
      }
      return 0;
    }
    if ( not exists $pair->{max} and not exists $pair->{min} ) {
      warn "Bad quality command db entry with no range control";
      next;
    }
    next unless $self->versions->newer_than( $pair->{min} );
    next unless $self->versions->older_than( $pair->{max} );
    return 1;
  }
  return 0;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Git::Wrapper::Plus::Support - Determine what versions of things support what

=head1 VERSION

version 0.002001

=head1 SYNOPSIS

    use Git::Wrapper::Plus::Support;

    my $support = Git::Wrapper::Plus::Support->new(
        git => <git::wrapper>
    );
    if ( $support->supports_command( 'for-each-ref' ) ) {

    }

=head1 METHODS

=head2 C<supports_command>

Determines if a given command is suppported on the current git.

This works by using a hand-coded table for interesting values
by processing C<git log> for git itself.

Returns C<undef> if the status of a command is unknown ( that is, has not been added
to the map yet ), C<0> if it is not supported, and C<1> if it is.

    if ( $supporter->supports_command('for-each-ref') ) ) {
        ...
    } else {
        ...
    }

B<Currently indexed commands>

    for-each-ref init init-db

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
