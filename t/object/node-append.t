use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc,
    $doc->create_document_type_definition ('aa'),
    $doc->create_element_type_definition ('hoge'),
    $doc->create_notation ('bar'),
  ) {
    test {
      my $c = shift;
      
      $node->manakai_append_text ('hoge');
      is $node->text_content, undef;
      is $node->child_nodes->length, 0;

      is $node->manakai_append_text ('hoge'), $node;
      
      done $c;
    } n => 3, name => ['manakai_append_text', $node->node_type];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $code (
    sub { $doc->create_document_fragment },
    sub { $doc->create_element ('hoge') },
    sub { $doc->dom_config->{manakai_strict_document_children} = 0; $doc },
  ) {
    my $node = $code->();
    test {
      my $c = shift;
      
      $node->manakai_append_text ('hoge');
      is $node->text_content, 'hoge';
      is $node->child_nodes->length, 1;
      is $node->first_child->node_type, $doc->TEXT_NODE;
      is $node->first_child->data, 'hoge';

      is $node->manakai_append_text (''), $node;
      is $node->child_nodes->length, 1;

      $node->manakai_append_text ('foo');
      is $node->child_nodes->length, 1;
      is $node->text_content, 'hogefoo';

      $node->append_child ($doc->create_comment ('foo'));
      $node->manakai_append_text ('abc');
      is $node->child_nodes->length, 3;
      is $node->text_content, 'hogefooabc';

      done $c;
    } n => 10, name => ['manakai_append_text', $node->node_type];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_text_node (''),
    $doc->create_comment (''),
    $doc->create_processing_instruction ('foo', ''),
    $doc->create_attribute ('hoge'),
    $doc->create_attribute_definition ('abc'),
    $doc->create_general_entity ('aa'),
  ) {
    test {
      my $c = shift;
      
      $node->manakai_append_text ('hoge');
      is $node->text_content, 'hoge';

      is $node->manakai_append_text (''), $node;
      is $node->text_content, 'hoge';
      
      $node->manakai_append_text ('foo');
      is $node->text_content, 'hogefoo';

      done $c;
    } n => 4, name => ['manakai_append_text', $node->node_type];
  }
}

run_tests;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
