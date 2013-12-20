use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Versions;
BEGIN {
  $Git::Wrapper::Plus::Versions::AUTHORITY = 'cpan:KENTNL';
}
{
  $Git::Wrapper::Plus::Versions::VERSION = '0.001000';
}

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

__END__

=pod

=encoding UTF-8

=head1 NAME

Git::Wrapper::Plus::Versions - Analyse and compare git versions

=head1 VERSION

version 0.001000

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
