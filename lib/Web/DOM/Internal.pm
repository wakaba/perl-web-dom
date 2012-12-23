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
    next_node_id => 0,
    # data nodes rc

    ## Trees
    next_tree_id => 0,
    # tree_id

    ## Collections
    # cols
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
  2 => 'Web::DOM::Attr',
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
##   - {child_nodes}         - $node->child_nodes
##   - {attributes}          - $node->attributes
##   - {children}            - $node->children
##   - {"by_tag_name$;$ln"}  - $node->get_elements_by_tag_name ($ln)
##   - {"by_tag_name_ns$;$ns$;$ln"} - $node->get_elements_by_tag_name_ns ($ns, $ln)
##   - {images}              - $node->images

my $CollectionClass = {
  child_nodes => 'Web::DOM::NodeList',
  attributes => 'Web::DOM::NamedNodeMap',
}; # $CollectionClass

sub collection ($$$$) {
  my ($self, $key, $root_node, $filter) = @_;
  my $id = $$root_node->[1];
  return $self->{cols}->[$id]->{$key}
      if $self->{cols}->[$id]->{$key};
  my $class = $CollectionClass->{$key} || 'Web::DOM::HTMLCollection';
  eval qq{ require $class } or die $@;
  my $nl = bless \[$root_node, $filter], $class;
  weaken ($self->{cols}->[$id]->{$key} = $nl);
  return $nl;
} # collection

sub children_changed ($$$) {
  my $cols = $_[0]->{cols};
  for ($cols->[$_[1]]->{child_nodes},
       $cols->[$_[1]]->{children}) {
    delete $$_->[2] if $_;
  }

  if ($_[2] == 1) { # old child node is ELEMENT_NODE
    my @id = ($_[1]);
    while (@id) {
      my $id = shift @id;
      next unless defined $id;
      for my $key (keys %{$cols->[$id] or {}}) {
        delete ${$cols->[$id]->{$key}}->[2] if $cols->[$id]->{$key};
      }
      push @id, $_[0]->{data}->[$id]->{parent_node};
    }
  }
} # children_changed

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
    push @id, grep { not ref $_ } @{$self->{data}->[$id]->{attributes} or []};
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
    push @id, grep { not ref $_ } @{$self->{data}->[$id]->{attributes} or []};
  }
} # disconnect

## Move a node, with its descendants and their related objects, from
## the document to another (this) document.  Please note that this
## method is not enough for the "adopt" operation as defined in the
## DOM Standard; that operation requires more than this method does,
## including removal of the parent node of the node.  This method
## assumes that $node has no parent or owner.
sub adopt ($$) {
  my ($new_int, $node) = @_;
  my $old_int = $$node->[0];
  return if $old_int eq $new_int;

  my @old_id = ($$node->[1]);
  my $new_tree_id = $new_int->{next_tree_id}++;
  my %id_map;
  my @data;
  while (@old_id) {
    my $old_id = shift @old_id;
    my $new_id = $new_int->{next_node_id}++;
    $id_map{$old_id} = $new_id;

    my $data = $new_int->{data}->[$new_id]
        = delete $old_int->{data}->[$old_id];
    push @data, $data;

    delete $old_int->{tree_id}->[$old_id];
    $new_int->{tree_id}->[$new_id] = $new_tree_id;

    push @old_id, @{$data->{child_nodes} or []};
    push @old_id, grep { not ref $_ } @{$data->{attributes} or []};

    if (my $node = delete $old_int->{nodes}->[$old_id]) {
      weaken ($new_int->{nodes}->[$new_id] = $node);
      $$node->[0] = $new_int;
      $$node->[1] = $new_id;
    }

    if (my $cols = delete $old_int->{cols}->[$old_id]) {
      $new_int->{cols}->[$new_id] = $cols;
      for (values %$cols) {
        delete $$_->[2] if defined $_;
      }
    }

    $new_int->{rc}->[$new_id] = delete $old_int->{rc}->[$old_id]
        if $old_int->{rc}->[$old_id];
  }
  
  for my $data (@data) {
    @{$data->{child_nodes}} = map { $id_map{$_} } @{$data->{child_nodes}}
        if $data->{child_nodes};
    @{$data->{attributes}} = map {
      ref $_ ? $_ : $id_map{$_};
    } @{$data->{attributes}} if $data->{attributes};
    for (values %{$data->{attrs} or {}}) {
      for my $ln (keys %$_) {
        if (defined $_->{$ln} and not ref $_->{$ln}) {
          $_->{$ln} = $id_map{$_->{$ln}};
        }
      }
    }
    for (qw(parent_node owner_element)) {
      $data->{$_} = $id_map{$data->{$_}} if defined $data->{$_};
    }
  }
} # adopt

# XXX should we drop the "rc" concept and hard code that the node ID
# "0" can't be freed until the nodes within the document has been
# freed?
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
    delete $self->{cols}->[$_];
  }
} # gc

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
