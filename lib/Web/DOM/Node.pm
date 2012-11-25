package Web::DOM::Node;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Exception;
use Carp;
our @CARP_NOT = qw(Web::DOM::Exception);
use Exporter::Lite;

## Node
##   <http://dom.spec.whatwg.org/#interface-node>

use overload
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

our @EXPORT = qw(
  ELEMENT_NODE DOCUMENT_NODE DOCUMENT_TYPE_NODE DOCUMENT_FRAGMENT_NODE
);

sub ELEMENT_NODE () { 1 }
sub DOCUMENT_NODE () { 9 }
sub DOCUMENT_TYPE_NODE () { 10 }
sub DOCUMENT_FRAGMENT_NODE () { 11 }
# XXX

sub node_type ($) {
  return ${$_[0]}->[2]->{node_type};
} # node_type

sub local_name ($) {
  return ${$_[0]}->[2]->{local_name};
} # local_name

sub owner_document ($) {
  return ${$_[0]}->[0]->node (0);
} # owner_document

sub parent_node ($) {
  my $self = shift;
  my $pid = $$self->[2]->{parent_node};
  return undef unless defined $pid;
  return $$self->[0]->node ($pid);
} # parent_node

sub append_child ($$) {
  return $_[0]->insert_before ($_[1], undef);
} # append_child

sub insert_before ($$$) {
  my ($parent, $node, $child) = @_;

  # pre-insert
  my $parent_nt = $$parent->[2]->{node_type};

  # 1.
  if ($parent_nt == ELEMENT_NODE or
      $parent_nt == DOCUMENT_FRAGMENT_NODE or
      $parent_nt == DOCUMENT_NODE) {
    #
  } else {
    _throw Web::DOM::Exception 'HierarchyRequestError',
        'The parent node is of disallowed type';
  }

  # 2.
  {
    # XXX different doc
    my $id = $$parent->[1];
    while (defined $id) {
      if ($id == $$node->[1]) {
        _throw Web::DOM::Exception 'HierarchyRequestError',
            'The new child node is an inclusive ancestors of the parent node';
      }
      $id = $$parent->[0]->{data}->[$id]->{parent_node};
    }
  }
  
  # 3.
  if (defined $child) {
    # XXX different doc
    my $parent = $$child->[2]->{parent_node};
    if (defined $parent and $parent != $$parent->[1]) {
      _throw Web::DOM::Exception 'NotFoundError',
          'The reference child is not a child of the parent node';
    }
  }

  # XXX

  push @{$$parent->[2]->{child_nodes} ||= []}, $$node->[1];
  $$node->[2]->{parent_node} = $$parent->[1];
  $$parent->[0]->connect ($$node->[1] => $$parent->[1]);
  return $node;
} # insert_before

sub first_child ($) {
  my $self = shift;
  my $id = $$self->[2]->{child_nodes}->[0];
  return undef unless $id;
  return $$self->[0]->node ($id);
} # first_child

sub remove_child ($$) {
  my ($parent, $child) = @_;
  # XXX
  my $id = $$child->[1];
  @{$$parent->[2]->{child_nodes}} = grep { $_ ne $id } @{$$parent->[2]->{child_nodes}};
  delete $$child->[2]->{parent_node};
  $$child->[0]->disconnect ($$child->[1]);
  return $child;
} # remove_child

sub get_elements_by_tag_name ($$) {
  my ($self, $ln) = @_;
  # XXX
  return $$self->[0]->search ($$self->[1], $ln);
} # get_elements_by_tag_name

sub set_user_data ($$$) {
  ${$_[0]}->[2]->{user_data}->{$_[1]} = $_[2];
} # set_user_data

sub DESTROY ($) {
  my $self = shift;
  $$self->[0]->gc ($$self->[1]);
} # DESTROY

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
