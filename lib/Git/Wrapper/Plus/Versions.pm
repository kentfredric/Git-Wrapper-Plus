use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Versions;

# ABSTRACT: Analyse and compare git versions

use Moo;
use Sort::Versions;

has git => required => 1, is => ro =>;

sub current_version {
  my ($self) = @_;
  return $self->git->version;
}

sub newer_than {
  my ( $self, $v ) = @_;
  return versioncmp( $self->current_version, $v ) >= 0;
}

sub older_than {
  my ( $self, $v ) = @_;
  return versioncmp( $self->current_version, $v ) < 0;
}

no Moo;
1;

