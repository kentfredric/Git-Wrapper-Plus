use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Git::Wrapper::Plus::Support::Behaviors;

# ABSTRACT: Database of Git Behaviour Support

# AUTHORITY

use Moo qw( extends );
extends 'Git::Wrapper::Plus::Support::RangeDictionary';

sub BUILD {
  my ($self) = @_;
  $self->add_range(
    'add-updates-index' => {
      'min'      => '1.5.0',
      'min_tag'  => '1.5.0-rc0',
      'min_sha1' => '366bfcb68f4d98a43faaf17893a1aa0a7a9e2c58',
    },
  );
  $self->add_range(
    'can-checkout-detached' => {
      'min'      => '1.5.0',
      'min_tag'  => '1.5.0-rc1',
      'min_sha1' => 'c847f537125ceab3425205721fdaaa834e6d8a83',
    },
  );
  $self->add_range(
    '2-arg-cat-file' => {
      'min_sha1' => 'bf0c6e839c692142784caf07b523cd69442e57a5',
      'min_tag'  => '0.99',
      'min'      => '0.99',
    },
  );
  return $self;
}

no Moo;
1;

