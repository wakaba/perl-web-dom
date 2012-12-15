package Web::DOM::Internal;
use strict;
use warnings;
use Exporter::Lite;

our @EXPORT;

my $Text = {};

sub text ($$) {
  return defined $_[1] ? $Text->{$_[1]} ||= \(''.$_[1]) : undef;
} # text

push @EXPORT, qw(HTML_NS XML_NS XMLNS_NS);
sub HTML_NS () { q<http://www.w3.org/1999/xhtml> }
sub XML_NS () { q<http://www.w3.org/XML/1998/namespace> }
sub XMLNS_NS () { q<http://www.w3.org/2000/xmlns/> }

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
    # child_nodes
    # XXX searches
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

my $NodeClassByNodeType = {
  3 => 'Web::DOM::Text',
  7 => 'Web::DOM::ProcessingInstruction',
  8 => 'Web::DOM::Comment',
  10 => 'Web::DOM::DocumentType',
  11 => 'Web::DOM::DocumentFragment',
};

sub node ($$) {
  my ($self, $id) = @_;
  return $self->{nodes}->[$id] if $self->{nodes}->[$id];

  my $data = $self->{data}->[$id];
  my $class;
  my $nt = $data->{node_type};
  if ($nt == 1) {
    $class = 'Web::DOM::Element';
    # XXX Element subclasses
  } elsif ($nt == 9) {
    $class = $data->{is_XMLDocument}
        ? 'Web::DOM::XMLDocument' : 'Web::DOM::Document';
  } else {
    $class = $NodeClassByNodeType->{$nt};
  }
  eval qq{ require $class } or die $@;
  my $node = bless \[$self, $id, $data], $class;
  weaken ($self->{nodes}->[$id] = $node);
  return $node;
} # node

## Live collection data structure
##
##   0 - The root node
##   1 - Filter
##   2 - List of the nodes in the collection
##
## $self->{cols}->[$root_node_id]->
## 
##   - {child_nodes}                           - $node->child_nodes
##   - {images}                                - $node->images
##   - {children}                              - $node->children
##   - {get_elements_by_tag_name}->{$tag_name} - get_* rooted at $node
##   - {get_elements_by_tag_name_ns}->{$ns}->{$ln} - ditto
##   ...

sub child_nodes ($$) {
  my ($self, $id) = @_;
  return $self->{cols}->[$id]->{child_nodes}
      if $self->{cols}->[$id]->{child_nodes};
  my $node = $self->node ($id);
  require Web::DOM::NodeList;
  my $nl = bless \[$node], 'Web::DOM::NodeList';
  weaken ($self->{cols}->[$id]->{child_nodes} = $nl);
  return $nl;
} # child_nodes

sub html_collection ($$$$) {
  my ($self, $key, $root_node, $filter) = @_;
  my $id = $$root_node->[1];
  return $self->{cols}->[$id]->{$key}
      if $self->{cols}->[$id]->{$key};
  require Web::DOM::HTMLCollection;
  my $nl = bless \[$root_node, $filter], 'Web::DOM::HTMLCollection';
  weaken ($self->{cols}->[$id]->{$key} = $nl);
  return $nl;
} # html_collection

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
    warn "Potential memory leak detected" if $@ =~ /during global destruction/;
  }
} # DESTROY

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
