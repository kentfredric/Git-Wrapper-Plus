use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Support::RangeSet;
$Git::Wrapper::Plus::Support::RangeSet::VERSION = '0.004000';
# ABSTRACT: A set of ranges of supported things

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

use Moo qw( has );

has 'items' => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_items {
  return [];
}

sub add_range_object {
  my ( $self, $range_object ) = @_;
  push @{ $self->items }, $range_object;
  return $self;
}

sub add_range {
  my ( $self, @args ) = @_;
  my $config;
  if ( 1 == @args ) {
    $config = $args[0];
  }
  else {
    $config = {@args};
  }
  require Git::Wrapper::Plus::Support::Range;
  return $self->add_range_object( Git::Wrapper::Plus::Support::Range->new($config) );
}

sub supports_version {
  my ( $self, $version_object ) = @_;
  for my $item ( @{ $self->items } ) {
    my $cmp = $item->supports_version($version_object);
    return $cmp if defined $cmp;
  }
  return;
}

no Moo;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Git::Wrapper::Plus::Support::RangeSet - A set of ranges of supported things

=head1 VERSION

version 0.004000

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
