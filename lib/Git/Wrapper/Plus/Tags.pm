use strict;
use warnings;

package Git::Wrapper::Plus::Tags;

# ABSTRACT: Extract all tags from a repository

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Git::Wrapper::Plus::Tags",
    "interface":"class",
    "inherits":"Moo::Object"
}

=end MetaPOD::JSON

=cut

use Moo;

=head1 SYNOPSIS

This tool basically gives a more useful interface around

    git tag

Namely, each tag returned is a tag object, and you can view tag properties with it.

    use Git::Wrapper::Plus::Tags;

    my $tags_finder = Git::Wrapper::Plus::Tags->new(
        git => $wrapper
    );

    # All tags
    for my $tag ( $tags_finder->tags ) {
        printf "%s - %s\n", $tag->name, $tag->sha1;
    }
    # Tag 1.1
    for my $tag ( $tags_finder->get_tag('1.1') ) {
        ...
    }
    # All tags starting with 1.1
    for my $tag ( $tags_finder->get_tag('1.*') ) {
        ...
    }
    # All tags that point directly to the SHA1 for current master
    for my $tag ( $tags_finder->tags_for_rev('master') ) {
        ...
    }

=cut

=attr C<git>

B<REQUIRED>: A Git::Wrapper compatible object.

=cut

has git => is => ro =>, required => 1;

=attr C<refs>

B<OPTIONAL>: Git::Wrapper::Plus::Refs instance, auto-built if not specified.

=cut

has 'refs' => is => ro =>, lazy => 1, builder => 1;

sub _build_refs {
  my ($self) = @_;
  require Git::Wrapper::Plus::Refs;
  return Git::Wrapper::Plus::Refs->new( git => $self->git );
}

sub _to_tag {
  my ( $self, $ref ) = @_;
  require Git::Wrapper::Plus::Ref::Tag;
  return Git::Wrapper::Plus::Ref::Tag->new_from_Ref($ref);
}

sub _to_tags {
  my ( $self, @refs ) = @_;
  return map { $self->_to_tag($_) } @refs;
}

# There's 2 types of results that come back from git ls-remote
#
# tags, and heavy tags ( usually annotations )
#
# puretags look like
#
#    abffab foo         # pointer to the commit
#
# While heavy tags come in pairs
#
#   fabfab  foo         # heavy tag pointer
#   abffab  foo^{}      # pointer to the actual commit
#
# However, we don't really care about the second half of the latter kind.
#
sub _grep_commit_pointers {
  my ( $self, @refs ) = @_;
  my (@out);
  for my $ref (@refs) {
    next if $ref->name =~ /[^][{][}]\z/msx;
    push @out, $ref;
  }
  return @out;
}

=method C<tags>

A C<List> of L<< C<::Ref::Tag> objects|Git::Wrapper::Plus::Ref::Tag >>

    for my $tag ( $tag_finder->tags() ) {

    }

=cut

sub tags {
  my ($self) = @_;
  return $self->get_tag(q[**]);
}

=method C<get_tag>

    for my $tag ( $tags->get_tag('1.000') ) {

    }

    for my $tag ( $tags->get_tag('1.*') ) {

    }

Note: This can easily return multiple values.

For instance, C<tags> is implemented as

    my ( @tags ) = $branches->get_tag('**');

Mostly, because the underlying mechanism is implemented in terms of L<< C<fnmatch(3)>|fnmatch(3) >>

If the tag does not exist, or no tag match the expression, C<< get_tag >>  will return an empty list.

So in the top example, C<match> is C<undef> if C<1.000> does not exist.

=cut

sub get_tag {
  my ( $self, $name ) = @_;
  return $self->_to_tags( $self->_grep_commit_pointers( $self->refs->get_ref( 'refs/tags/' . $name ) ) );
}

=method C<tag_sha1_map>

A C<HashRef> of C<< sha1 => [ L<< tag|Git::Wrapper::Plus::Ref::Tag >>,  L<< tag|Git::Wrapper::Plus::Ref::Tag >> ] >> entries.

    my $hash = $tag_finder->tag_sha1_map();
    for my $sha ( keys %{$hash} ) {
        my (@tags) = @{ $hash->{ $sha } };
        ...
    }

=cut

sub tag_sha1_map {
  my ($self) = @_;

  my %hash;
  for my $tag ( $self->tags ) {
    my $sha1 = $tag->sha1;
    if ( not exists $hash{$sha1} ) {
      $hash{$sha1} = [];
    }
    push @{ $hash{$sha1} }, $tag;
  }
  return \%hash;
}

=method C<tags_for_rev>


A C<List> of L<< C<::Ref::Tag> objects|Git::Wrapper::Plus::Ref::Tag >> that point to the given C<SHA1>.


    for my $tag ( $tag_finder->tags_for_rev( $sha1_or_commitish_etc ) ) {
        ...
    }

=cut

sub tags_for_rev {
  my ( $self, $rev ) = @_;
  my (@shas) = $self->git->rev_parse($rev);
  if ( scalar @shas != 1 ) {
    require Carp;
    Carp::croak("Could not resolve a SHA1 from rev $rev");
  }
  my ($sha) = shift @shas;
  my $map = $self->tag_sha1_map;
  return unless exists $map->{$sha};
  return @{ $map->{$sha} };
}

no Moo;

1;
