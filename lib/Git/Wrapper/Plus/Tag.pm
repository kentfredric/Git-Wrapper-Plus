use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Tag;
BEGIN {
  $Git::Wrapper::Plus::Tag::AUTHORITY = 'cpan:KENTNL';
}
{
  $Git::Wrapper::Plus::Tag::VERSION = '0.001000';
}

# ABSTRACT: A single tag object

use Moo;
extends 'Git::Wrapper::Plus::Ref';


sub new_from_Ref {
  my ( $class, $object ) = @_;
  if ( not $object->can('name') ) {
    require Carp;
    return Carp::croak("Object $object does not respond to ->name, cannot Ref -> Tag");
  }
  my $name = $object->name;
  if ( $name =~ qr{\Arefs/tags/(.+\z)}msx ) {
    return $class->new(
      git  => $object->git,
      name => $1,
    );
  }
  require Carp;
  Carp::croak("Path $name is not in refs/tags/*, cannot convert to Tag object");
}


sub refname {
  my ($self) = @_;
  return 'refs/tags/' . $self->name;
}


sub verify {
  my ( $self, ) = @_;
  return $self->git->tag( '-v', $self->name );
}


## no critic (ProhibitBuiltinHomonyms)

sub delete {
  my ( $self, ) = @_;
  return $self->git->tag( '-d', $self->name );
}

no Moo;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Git::Wrapper::Plus::Tag - A single tag object

=head1 VERSION

version 0.001000

=head1 METHODS

=head2 C<new_from_Ref>

Convert a Git::Refs::Ref to a Git::Tags::Tag

    my $tag = $class->new_from_Ref( $ref );

=head2 C<verify>

=head2 C<delete>

=head1 ATTRIBUTES

=head2 C<name>

=head2 C<git>

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
