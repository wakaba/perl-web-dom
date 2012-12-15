package Web::DOM::HTMLCollection;
use strict;
use warnings;
use Web::DOM::Collection;
push our @ISA, qw(Web::DOM::Collection);
our $VERSION = '1.0';

sub named_item ($$) {
  # XXX
} # named_item

sub to_list ($) {
  my $node = ${$_[0]}->[0];
  my $int = $$node->[0];
  return (map { $int->node ($_) } (${$_[0]}->[1]->($node)));
} # to_list

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
