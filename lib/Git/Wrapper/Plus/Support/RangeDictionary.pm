use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Support::RangeDictionary;

# ABSTRACT: A key -> range list mapping for support features

# AUTHORITY

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

