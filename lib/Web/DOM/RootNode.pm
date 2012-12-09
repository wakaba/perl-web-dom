package Web::DOM::RootNode;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;

# XXX children

sub first_element_child ($) {
  my $self = shift;
  for (@{$$self->[2]->{child_nodes}}) {
    if ($$self->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE) {
      return $$self->[0]->node ($_);
    }
  }
  return undef;
} # first_element_child

sub last_element_child ($) {
  my $self = shift;
  for (reverse @{$$self->[2]->{child_nodes}}) {
    if ($$self->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE) {
      return $$self->[0]->node ($_);
    }
  }
  return undef;
} # last_element_child

sub child_element_count ($) {
  my $self = shift;
  my @el = grep {
    $$self->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE;
  } @{$$self->[2]->{child_nodes}};
  return scalar @el;
} # child_element_count

# XXX prepend append

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
