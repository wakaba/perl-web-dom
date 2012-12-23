package Web::DOM::NamedNodeMap;
use strict;
use warnings;
use Web::DOM::Collection;
push our @ISA, qw(Web::DOM::Collection);
our $VERSION = '1.0';
push our @CARP_NOT, qw(Web::DOM::Element);
use Web::DOM::Node;
use Web::DOM::TypeError;
use Web::DOM::Exception;

sub get_named_item ($$) {
  my $method = 'get_attribute_node';
  return ${$_[0]}->[0]->$method ($_[1]);
} # get_named_item

sub get_named_item_ns ($$$) {
  my $method = 'get_attribute_node_ns';
  return ${$_[0]}->[0]->$method ($_[1], $_[2]);
} # get_named_item_ns

sub set_named_item ($$) {
  my $method = 'set_attribute_node';
  if ($method eq 'set_attribute_node') {
    # WebIDL
    unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
      _throw Web::DOM::TypeError 'The argument is not a Node';
    }

    unless ($_[1]->node_type == ATTRIBUTE_NODE) {
      _throw Web::DOM::Exception 'HierarchyRequestError',
          'Specified type of node cannot be set';
    }
  }
  return ${$_[0]}->[0]->$method ($_[1]);
} # set_named_item

*set_named_item_ns = \&set_named_item;

sub remove_named_item ($$) {
  my $node = $_[0]->get_named_item ($_[1]);
  unless ($node) {
    _throw Web::DOM::Exception 'NotFoundError',
        'Specified node not found';
  }
  my $method = 'remove_attribute_node';
  ${$_[0]}->[0]->$method ($node);
  return $node;
} # remove_named_item

sub remove_named_item_ns ($$$) {
  my $node = $_[0]->get_named_item_ns ($_[1], $_[2]);
  unless ($node) {
    _throw Web::DOM::Exception 'NotFoundError',
        'Specified node not found';
  }
  my $method = 'remove_attribute_node';
  ${$_[0]}->[0]->$method ($node);
  return $node;
} # remove_named_item_ns

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
