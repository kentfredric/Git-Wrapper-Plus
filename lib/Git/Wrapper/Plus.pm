use strict;
use warnings;

package Git::Wrapper::Plus;

# ABSTRACT: A Toolkit for working with Git::Wrapper in an OO Way.

=head1 DESCRIPTION

Initially, I started off with C<Dist::Zilla::Util::> and friends, but I soon discovered so many quirks
in C<git>, especially multi-version support, and that such a toolkit would be more useful independent.

So C<Git::Wrapper::Plus> is a collection of tools for using C<Git::Wrapper>, aiming to work on all versions of Git since at least Git C<1.3>.

For instance, you probably don't realise this, but on older C<git>'s, 

    echo > file
    git add file
    git commit
    echo 2 > file
    git add file
    git commit

does nothing, because on Git 1.3, C<git add> is only for the addition to tree, not subsequent updates.

    echo > file
    git add file
    git commit
    echo 2 > file
    git update-index file
    git commit

Is how it works there.

And you'd have probably not realised this till you had a few smoke reports back with failures on old Gits.

And there's more common failures, like some commands simply don't exist on old gits.

=cut

=head1 MODULES

=head2 C<Git::Wrapper::Plus::Refs>

L<< C<Git::Wrapper::Plus::Refs>|Git::Wrapper::Plus::Refs >> is a low level interface to refs.

Other modules build on specific types of refs, but this one is generic.

=head2 C<Git::Wrapper::Plus::Branches>

L<< C<Git::Wrapper::Plus::Branches>|Git::Wrapper::Plus::Branches >> is a general purpose interface to branches.

This builds upon C<::Refs>

=head2 C<Git::Wrapper::Plus::Tags>

L<< C<Git::Wrapper::Plus::Tags>|Git::Wrapper::Plus::Tags >> is a general purpose interface to tags.

This builds upon C<::Refs>

=cut

1;
