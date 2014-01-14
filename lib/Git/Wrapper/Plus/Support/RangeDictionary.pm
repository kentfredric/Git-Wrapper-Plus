use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Support::RangeDictionary;
$Git::Wrapper::Plus::Support::RangeDictionary::VERSION = '0.003102';
# ABSTRACT: A key -> range list mapping for support features

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

use Moo qw( has );

has 'dictionary' => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_dictionary {
  return {};
}

sub _add_dictionary_object {
  my ( $self, $name, $set_object ) = @_;
  $self->dictionary->{$name} = $set_object;
  return $self;
}

sub _add_dictionary_range_object {
  my ( $self, $name, $range ) = @_;
  if ( not exists $self->dictionary->{$name} ) {
    require Git::Wrapper::Plus::Support::RangeSet;
    $self->dictionary->{$name} = Git::Wrapper::Plus::Support::RangeSet->new();
  }
  $self->dictionary->{$name}->add_range_object($range);
  return $self;
}

sub add_range {
  my ( $self, $name, @args ) = @_;
  my $config;
  if ( 1 == @args ) {
    $config = $args[0];
  }
  else {
    $config = {@args};
  }
  require Git::Wrapper::Plus::Support::Range;
  return $self->_add_dictionary_range_object( $name, Git::Wrapper::Plus::Support::Range->new($config) );
}

sub has_entry {
  my ( $self, $name ) = @_;
  return exists $self->dictionary->{$name};
}

sub entries {
  my ($self)    = @_;
  my (@entries) = sort keys %{ $self->dictionary };
  return @entries;
}

sub entry_supports {
  my ( $self, $name, $version_object ) = @_;
  return unless $self->has_entry($name);
  return $self->dictionary->{$name}->supports_version($version_object);
}

no Moo;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Git::Wrapper::Plus::Support::RangeDictionary - A key -> range list mapping for support features

=head1 VERSION

version 0.003102

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
