use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Document;

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc,
    $doc->create_element ('a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      is $node->first_element_child, undef;
      is $node->last_element_child, undef;
      is $node->child_element_count, 0;
      done $c;
    } n => 3, name => ['element_child', $node->node_type, 'empty'];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc,
    $doc->create_element ('a'),
    $doc->create_document_fragment,
  ) {
    my $el1 = $doc->create_element ('a');
    $node->append_child ($el1);
    test {
      my $c = shift;
      is $node->first_element_child, $el1;
      is $node->last_element_child, $el1;
      is $node->child_element_count, 1;
      done $c;
    } n => 3, name => ['element_child', $node->node_type, 'a child'];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_element ('a'),
    $doc->create_document_fragment,
  ) {
    my $el1 = $doc->create_element ('a');
    my $el2 = $doc->create_element ('a');
    $node->append_child ($el1);
    $node->append_child ($el2);
    test {
      my $c = shift;
      is $node->first_element_child, $el1;
      is $node->last_element_child, $el2;
      is $node->child_element_count, 2;
      done $c;
    } n => 3, name => ['element_child', $node->node_type, 'two element children'];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_element ('a'),
    $doc->create_document_fragment,
  ) {
    my $el1 = $doc->create_element ('a');
    my $el2 = $doc->create_element ('a');
    $node->append_child ($doc->create_text_node ('x'));
    $node->append_child ($el1);
    $node->append_child ($doc->create_text_node ('x'));
    $node->append_child ($el2);
    $node->append_child ($doc->create_comment ('x'));
    test {
      my $c = shift;
      is $node->first_element_child, $el1;
      is $node->last_element_child, $el2;
      is $node->child_element_count, 2;
      done $c;
    } n => 3, name => ['element_child', $node->node_type, 'two element children with garbages'];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc,
    $doc->create_element ('a'),
    $doc->create_document_fragment,
  ) {
    my $el1 = $doc->create_element ('a');
    $node->append_child ($doc->create_comment ('x'));
    $node->append_child ($el1);
    $node->append_child ($doc->create_processing_instruction ('x'));
    $node->append_child ($doc->create_comment ('x'));
    test {
      my $c = shift;
      is $node->first_element_child, $el1;
      is $node->last_element_child, $el1;
      is $node->child_element_count, 1;
      done $c;
    } n => 3, name => ['element_child', $node->node_type, 'a element child with garbages'];
  }
}

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
