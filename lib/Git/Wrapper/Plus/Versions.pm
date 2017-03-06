use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Versions;

our $VERSION = '0.004011';

# ABSTRACT: Analyze and compare git versions

# AUTHORITY

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Git::Wrapper::Plus::Versions",
    "interface":"class",
    "inherits":"Moo::Object"
}

=end MetaPOD::JSON

=cut

use Moo qw( has );
use Sort::Versions qw( versioncmp );

=head1 SYNOPSIS

    use Git::Wrapper::Plus::Versions;
    my $v = Git::Wrapper::Plus::Versions->new(
        git => $git_wrapper
    );

    print $v->current_version; # Current V String.

    # Larger or equal to 1.5
    if ( $v->newer_than('1.5') ) {

    }

    # Lesser than 1.5
    if ( $v->older_than('1.5') ) {

    }

=cut

=attr C<git>

B<REQUIRED>: A Git::Wrapper compatible object.

=cut

has git => required => 1, is => ro =>;

=method C<current_version>

Reports the current C<git> version.

=cut

sub current_version {
  my ($self) = @_;
  return $self->git->version;
}

=method C<newer_than>

    if ( $v->newer_than('1.5') ) {

    }

Reports if git is 1.5 or larger.

=cut

sub newer_than {
  my ( $self, $v ) = @_;
  return versioncmp( $self->current_version, $v ) >= 0;
}

=method C<older_than>

    if ( $v->older_than('1.5') ) {

    }

Reports if git is C<< <1.5 >>

=cut

sub older_than {
  my ( $self, $v ) = @_;
  return versioncmp( $self->current_version, $v ) < 0;
}

no Moo;
1;

