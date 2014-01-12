use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Support;

# ABSTRACT: Determine what versions of things support what

use Moo;

=head1 SYNOPSIS

    use Git::Wrapper::Plus::Support;

    my $support = Git::Wrapper::Plus::Support->new(
        git => <git::wrapper>
    );
    if ( $support->supports_command( 'for-each-ref' ) ) {

    }
    if ( $support->supports_behaviour('add-updates-index') ) {

    }

=cut

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

=method C<supports_command>

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

=cut

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

=method C<supports_behaviour>

Incidates if a given command behaves in a certain way

This works by using a hand-coded table for interesting values
by processing C<git log> for git itself.

Returns C<undef> if the status of a commands behaviour is unknown ( that is, has not been added
to the map yet ), C<0> if it is not supported, and C<1> if it is.

    if ( $supporter->supports_behaviour('add-updates-index') ) ) {
        ...
    } else {
        ...
    }

B<Current behaviours>

=head4 C<add-updates-index>

Older versions of git required you to do:

    git update-index $FILE

Instead of

    git add $FILE

To update content.

=head4 C<can-checkout-detached>

Not all versions of Git can checkout a detached head.

=cut

our $behaviour_db = {
  'add-updates-index' => [
    {
      'min'      => '1.5.0',
      'min_tag'  => '1.5.0-rc0',
      'min_sha1' => '366bfcb68f4d98a43faaf17893a1aa0a7a9e2c58',
    },
  ],
  'can-checkout-detached' => [
    {
      'min'      => '1.5.0',
      'min_tag'  => '1.5.0-rc1',
      'min_sha1' => 'c847f537125ceab3425205721fdaaa834e6d8a83'
    }
  ],
};

sub supports_behaviour {
  my ( $self, $beh ) = @_;
  if ( not exists $behaviour_db->{$beh} ) {
    return undef;
  }
  for my $pair ( @{ $behaviour_db->{$beh} } ) {
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
      warn "Bad quality behaviour db entry with no range control";
      next;
    }
    next unless $self->versions->newer_than( $pair->{min} );
    next unless $self->versions->older_than( $pair->{max} );
    return 1;
  }
  return 0;
}

no Moo;
1;

