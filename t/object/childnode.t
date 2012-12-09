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
    $doc->create_element ('a'),
    $doc->create_text_node ('a'),
    $doc->create_comment ('a'),
    $doc->create_processing_instruction ('a', ''),
    $doc->implementation->create_document_type ('a', '', ''),
  ) {
    test {
      my $c = shift;
      is $node->previous_element_sibling, undef;
      is $node->next_element_sibling, undef;
      done $c;
    } n => 2, name => ['element_child', $node->node_type, 'no parent'];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_element ('a'),
    $doc->create_text_node ('a'),
    $doc->create_comment ('a'),
    $doc->create_processing_instruction ('a', ''),
  ) {
    my $el = $doc->create_element ('a');
    $el->append_child ($node);
    test {
      my $c = shift;
      is $node->previous_element_sibling, undef;
      is $node->next_element_sibling, undef;
      done $c;
    } n => 2, name => ['element_child', $node->node_type, 'only child'];
  }

  for my $node (
    $doc->implementation->create_document_type ('a', '', ''),
  ) {
    $doc->append_child ($node);
    test {
      my $c = shift;
      is $node->previous_element_sibling, undef;
      is $node->next_element_sibling, undef;
      done $c;
    } n => 2, name => ['element_child', $node->node_type, 'only child'];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_element ('a'),
    $doc->create_text_node ('a'),
    $doc->create_comment ('a'),
    $doc->create_processing_instruction ('a', ''),
  ) {
    my $el = $doc->create_element ('a');
    $el->append_child ($node);
    my $el2 = $doc->create_element ('a');
    $el->append_child ($el2);
    test {
      my $c = shift;
      is $node->previous_element_sibling, undef;
      is $node->next_element_sibling, $el2;
      done $c;
    } n => 2, name => ['element_child', $node->node_type, 'has sibling'];
  }

  for my $node (
    $doc->implementation->create_document_type ('a', '', ''),
  ) {
    $doc->append_child ($node);
    my $el = $doc->create_element ('a');
    $doc->append_child ($el);
    test {
      my $c = shift;
      is $node->previous_element_sibling, undef;
      is $node->next_element_sibling, $el;
      done $c;
    } n => 2, name => ['element_child', $node->node_type, 'has sibling'];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_element ('a'),
    $doc->create_text_node ('a'),
    $doc->create_comment ('a'),
    $doc->create_processing_instruction ('a', ''),
  ) {
    my $el = $doc->create_element ('a');
    my $el2 = $doc->create_element ('a');
    $el->append_child ($el2);
    $el->append_child ($node);
    test {
      my $c = shift;
      is $node->previous_element_sibling, $el2;
      is $node->next_element_sibling, undef;
      done $c;
    } n => 2, name => ['element_child', $node->node_type, 'has sibling'];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_element ('a'),
    $doc->create_text_node ('a'),
    $doc->create_comment ('a'),
    $doc->create_processing_instruction ('a', ''),
  ) {
    my $el = $doc->create_element ('a');
    my $el2 = $doc->create_element ('a');
    $el->append_child ($doc->create_text_node (''));
    $el->append_child ($node);
    $el->append_child ($doc->create_text_node (''));
    $el->append_child ($el2);
    $el->append_child ($doc->create_text_node (''));
    test {
      my $c = shift;
      is $node->previous_element_sibling, undef;
      is $node->next_element_sibling, $el2;
      done $c;
    } n => 2, name => ['element_child', $node->node_type, 'has sibling'];
  }

  for my $node (
    $doc->implementation->create_document_type ('a', '', ''),
  ) {
    $doc->append_child ($node);
    my $el = $doc->create_element ('a');
    $doc->append_child ($doc->create_comment (''));
    $doc->append_child ($el);
    $doc->append_child ($doc->create_comment (''));
    test {
      my $c = shift;
      is $node->previous_element_sibling, undef;
      is $node->next_element_sibling, $el;
      done $c;
    } n => 2, name => ['element_child', $node->node_type, 'has sibling'];
  }
}

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
