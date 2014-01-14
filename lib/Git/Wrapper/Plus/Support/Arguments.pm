use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Support::Arguments;

# ABSTRACT: Database of command argument support data

# AUTHORITY

use Moo qw( has );

has 'entries' => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_entries {
  my $hash = {};
  require Git::Wrapper::Plus::Support::RangeDictionary;
  $hash->{'cat-file'} = Git::Wrapper::Plus::Support::RangeDictionary->new();
  $hash->{'cat-file'}->add_range(
    '-e' => {
      'min'      => '1.0.0',
      'min_tag'  => '0.99.9l',
      'min_sha1' => '7950571ad75c1c97e5e53626d8342b01b167c790',
    },
  );
  return $hash;
}

sub commands {
  my ($self)  = @_;
  my (@items) = sort keys %{ $self->entries };
  return @items;
}

sub arguments {
  my ( $self, $command ) = @_;
  return unless $self->has_command($command);
  return $self->entries->{$command}->entries;
}

sub has_command {
  my ( $self, $command ) = @_;
  return exists $self->entries->{$command};
}

sub has_argument {
  my ( $self, $command, $argument ) = @_;
  return unless $self->has_command($command);
  return $self->entries->{$command}->has_entry($argument);
}

sub argument_supports {
  my ( $self, $command, $argument, $version_object ) = @_;
  return unless $self->has_argument( $command, $argument );
  return $self->entries->{$command}->entry_supports( $argument, $version_object );
}

no Moo;
1;

