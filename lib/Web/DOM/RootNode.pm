package Web::DOM::RootNode;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;

sub get_elements_by_tag_name ($$) {
  my $self = $_[0];
  my $ln = ''.$_[1];
  if ($ln eq '*') {
    return $$self->[0]->html_collection ('by_tag_name'. $; . $ln, $self, sub {
      my $node = $_[0];
      my $data = $$node->[0]->{data};
      my @node_id = @{$data->[$$node->[1]]->{child_nodes} or []};
      my @id;
      while (@node_id) {
        my $id = shift @node_id;
        next unless $data->[$id]->{node_type} == ELEMENT_NODE;
        push @id, $id;
        unshift @node_id, @{$data->[$id]->{child_nodes} or []};
      }
      return @id;
    });
  } else {
    die "not implemented yet";
  }
} # get_elements_by_tag_name

sub children ($) {
  my $self = shift;
  return $$self->[0]->html_collection ('children', $self, sub {
    my $node = $_[0];
    return grep {
      $$node->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE;
    } @{$$node->[0]->{data}->[$$node->[1]]->{child_nodes} or []};
  });
} # children

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
