use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Support;

# ABSTRACT: Determine what versions of things support what

# AUTHORITY

use Moo qw( has );

=head1 SYNOPSIS

    use Git::Wrapper::Plus::Support;

    my $support = Git::Wrapper::Plus::Support->new(
        git => <git::wrapper>
    );
    if ( $support->supports_command( 'for-each-ref' ) ) {

    }
    if ( $support->supports_behavior('add-updates-index') ) {

    }

=cut

has 'git' => ( is => ro =>, required => 1 );

has 'versions' => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_versions {
  my ( $self, ) = @_;
  require Git::Wrapper::Plus::Versions;
  return Git::Wrapper::Plus::Versions->new( git => $self->git );
}

has 'commands' => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_commands {
  require Git::Wrapper::Plus::Support::Commands;
  return Git::Wrapper::Plus::Support::Commands->new();
}

has 'behaviors' => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_behaviors {
  require Git::Wrapper::Plus::Support::Behaviors;
  return Git::Wrapper::Plus::Support::Behaviors->new();
}


=method C<supports_command>

Determines if a given command is supported on the current git.

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

    for-each-ref init init-db update-cache update-index ls-remote cat-file show-diff write-tree commit-tree

=cut

sub supports_command {
  my ( $self, $command ) = @_;
  return unless $self->commands->has_entry($command);
  return 1 if $self->commands->entry_supports( $command, $self->versions );
  return 0;
}

=method C<supports_behavior>

Indicates if a given command behaves in a certain way

This works by using a hand-coded table for interesting values
by processing C<git log> for git itself.

Returns C<undef> if the status of a commands behavior is unknown ( that is, has not been added
to the map yet ), C<0> if it is not supported, and C<1> if it is.

    if ( $supporter->supports_behavior('add-updates-index') ) ) {
        ...
    } else {
        ...
    }

B<Current behaviors>

=head4 C<add-updates-index>

Older versions of git required you to do:

    git update-index $FILE

Instead of

    git add $FILE

To update content.

=head4 C<can-checkout-detached>

Not all versions of Git can checkout a detached head.

=head4 C<2-arg-cat-file>

The syntax:

    git cat-file <type> <commitish>

Should be supported everywhere that matters ( since 0.99 ), but it was not always git syntax.

=cut

sub supports_behavior {
  my ( $self, $beh ) = @_;
  return unless $self->behaviors->has_entry($beh);
  return 1 if $self->behaviors->entry_supports( $beh, $self->versions );
  return 0;
}

no Moo;
1;

