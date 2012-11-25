package Web::DOM::Internal;
use strict;
use warnings;

## Internal data structure for DOM tree.
##
## This module is for internal use only.  Applications should not use
## this module directly.
##
## This module has no test by itself.  Tests for Node and its
## subclasses covers this module.

package Web::DOM::Internal::Objects;
use Scalar::Util qw(weaken);

## Nodes of a DOM document share an object store, which is represented
## by this class.  Each node in the store is distinguished by the node
## ID.  Node ID #0 is always the |Document| node for the tree.
##
## Nodes of the document form several trees, which are identified by
## tree IDs.  This ID is used for, e.g., garbage collection.
##
## Objects belongging to the store is not limited to nodes.  Non-node
## objects controlled by the store include |HTMLCollection| objects
## returned by the |get_elements_by_tag_name| method and DOM range
## objects.

sub new ($) {
  return bless {
    ## Nodes
    next_node_id => 0, # data nodes rc

    ## Trees
    next_tree_id => 0, # tree_id

    ## Collections
    # searches
  }, $_[0];
} # new

## Various characteristics of the node is put into the "data" hash
## reference for the node.

sub add_data ($$) {
  my $self = shift;
  my $id = $self->{next_node_id}++;
  $self->{data}->[$id] = $_[0];
  $self->{tree_id}->[$id] = $self->{next_tree_id}++;
  return $id;
} # add_data

## The |Node| object exposed to the application is a blessed reference
## to the array reference, which consists of following members:
##
##   0 - The object store object
##   1 - The node ID
##   2 - The node data
##
## Its the reference to the reference, not just the reference, to
## allow overloading of |@{}| and |%{}| in some kinds of nodes.

sub node ($$) {
  my ($self, $id) = @_;
  return $self->{nodes}->[$id] || do {
    my $data = $self->{data}->[$id];
    my $class = {
      1 => 'Web::DOM::Element',
      9 => 'Web::DOM::Document',
      10 => 'Web::DOM::DocumentType',
      11 => 'Web::DOM::DocumentFragment',
    }->{$data->{node_type}};
    # XXX Element subclasses
    eval qq{ require $class } or die $@;
    my $node = bless \[$self, $id, $data], $class;
    weaken ($self->{nodes}->[$id] = $node);
    $node;
  };
} # node

## The |HTMLCollection| for ... XXX

sub search ($$$) {
  my ($self, $id, $local_name) = @_;
  return $self->{searches}->{$id, $local_name} ||= do {
    my $search = bless \[$self, $id, $local_name], 'Web::DOM::HTMLCollection';
    weaken ($self->{searches}->{$id, $local_name} = $search);
    $search;
  };
} # search

sub impl ($) {
  my $self = shift;
  return $self->{impl} || do {
    require Web::DOM::Implementation;
    my $impl = bless \[$self], 'Web::DOM::Implementation';
    weaken ($self->{impl} = $impl);
    $impl;
  };
} # impl

sub connect ($$$) {
  my ($self, $id => $parent_id) = @_;
  my @id = ($id);
  my $tree_id = $self->{tree_id}->[$parent_id];
  while (@id) {
    my $id = shift @id;
    $self->{tree_id}->[$id] = $tree_id;
    push @id, @{$self->{data}->[$id]->{child_nodes} or []};
  }
} # connect

sub disconnect ($$) {
  my ($self, $id) = @_;
  my @id = ($id);
  my $tree_id = $self->{next_tree_id}++;
  while (@id) {
    my $id = shift @id;
    $self->{tree_id}->[$id] = $tree_id;
    push @id, @{$self->{data}->[$id]->{child_nodes} or []};
  }
} # disconnect

sub gc ($$) {
  my ($self, $id) = @_;
  delete $self->{nodes}->[$id];
  my $tree_id = $self->{tree_id}->[$id];
  my @id = grep { defined $self->{tree_id}->[$_] and 
                  $self->{tree_id}->[$_] == $tree_id } 0..$#{$self->{tree_id}};
  for (@id) {
    return if $self->{nodes}->[$_] or $self->{rc}->[$_];
  }
  for (@id) {
    delete $self->{data}->[$_];
    delete $self->{tree_id}->[$_];
    delete $self->{rc}->[$_];
  }
} # gc

# XXX searches vs gc

sub DESTROY ($) {
  {
    local $@;
    eval { die };
    if ($@ =~ /during global destruction/) {
      warn "Detected (possibly) memory leak";
    }
  }
} # DESTROY

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
