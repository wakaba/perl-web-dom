package Web::DOM::NodeList;
use strict;
use warnings;
our $VERSION = '1.0';
use Carp;

use overload
    '@{}' => sub {
      return ${$_[0]}->[1] ||= do {
        my $list = $_[0]->to_a;
        Internals::SvREADONLY (@$list, 1);
        $list;
      };
    },
    '""' => sub {
      return ref ($_[0]) . '=DOM(' . ${$_[0]}->[2] . ')';
    },
    bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    fallback => 1;

sub item ($$) {
  # unsigned long
  return undef if $_[1] % 2**32 >= 2**31;
  return $_[0]->[$_[1] % 2**32]; # or undef
} # item

sub length ($) {
  return 0+@{$_[0]};
} # length

sub to_a ($) {
  my $node = ${$_[0]}->[0];
  my $int = $$node->[0];
  return [map { $int->node ($_) }
          @{$int->{data}->[$$node->[1]]->{child_nodes} or []}];
} # to_a
*as_list = \&to_a;

sub to_list ($) {
  my $node = ${$_[0]}->[0];
  my $int = $$node->[0];
  return (map { $int->node ($_) }
          @{$int->{data}->[$$node->[1]]->{child_nodes} or []});
} # to_list

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
