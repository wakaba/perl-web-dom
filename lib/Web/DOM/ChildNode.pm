package Web::DOM::ChildNode;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;

sub previous_element_sibling ($) {
  my $self = shift;
  my $parent_id = $$self->[2]->{parent_node};
  return undef unless defined $parent_id;
  my $self_id = $$self->[1];
  my $children = $$self->[0]->{data}->[$parent_id]->{child_nodes};
  my $found;
  for (reverse 0..$#$children) {
    if ($children->[$_] == $self_id) {
      $found = 1;
    } elsif ($found and 
             $$self->[0]->{data}->[$children->[$_]]->{node_type} == ELEMENT_NODE) {
      return $$self->[0]->node ($children->[$_]);
    }
  }
  return undef;
} # previous_element_sibling

sub next_element_sibling ($) {
  my $self = shift;
  my $parent_id = $$self->[2]->{parent_node};
  return undef unless defined $parent_id;
  my $self_id = $$self->[1];
  my $children = $$self->[0]->{data}->[$parent_id]->{child_nodes};
  my $found;
  for (0..$#$children) {
    if ($children->[$_] == $self_id) {
      $found = 1;
    } elsif ($found and 
             $$self->[0]->{data}->[$children->[$_]]->{node_type} == ELEMENT_NODE) {
      return $$self->[0]->node ($children->[$_]);
    }
  }
  return undef;
} # next_element_sibling

# XXX before after replace remove

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
