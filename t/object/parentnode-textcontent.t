use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Document;

{
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_document_fragment,
    $doc->create_element ('aa'),
  ) {
    test {
      my $c = shift;

      is $node->text_content, '';

      $node->text_content ('abc');
      is $node->text_content, 'abc';

      is $node->child_nodes->length, 1;
      my $text = $node->child_nodes->[0];
      is $text->node_type, $text->TEXT_NODE;
      is $text->data, 'abc';
      is $text->parent_node, $node;

      is $$node->[0]->{tree_id}->[$$node->[1]],
          $$text->[0]->{tree_id}->[$$text->[1]];

      $node->text_content ('bb cc');
      is $node->text_content, 'bb cc';

      is $node->child_nodes->length, 1;
      my $text2 = $node->child_nodes->[0];
      is $text2->node_type, $text2->TEXT_NODE;
      is $text2->data, 'bb cc';
      is $text2->parent_node, $node;
      is $text->data, 'abc';
      is $text->parent_node, undef;

      is $$node->[0]->{tree_id}->[$$node->[1]],
          $$text2->[0]->{tree_id}->[$$text2->[1]];
      isnt $$node->[0]->{tree_id}->[$$node->[1]],
          $$text->[0]->{tree_id}->[$$text->[1]];

      my $text3 = $doc->create_text_node ('aa');
      $node->append_child ($text3);
      is $node->text_content, 'bb ccaa';

      $node->text_content ('bb ccaa');
      is $node->text_content, 'bb ccaa';

      is $node->child_nodes->length, 1;
      my $text4 = $node->child_nodes->[0];
      is $text4->node_type, $text4->TEXT_NODE;
      is $text4->data, 'bb ccaa';
      is $text4->parent_node, $node;
      is $text->parent_node, undef;
      is $text2->parent_node, undef;
      is $text3->parent_node, undef;

      is $$node->[0]->{tree_id}->[$$node->[1]],
          $$text4->[0]->{tree_id}->[$$text4->[1]];
      isnt $$node->[0]->{tree_id}->[$$node->[1]],
          $$text3->[0]->{tree_id}->[$$text3->[1]];
      isnt $$node->[0]->{tree_id}->[$$node->[1]],
          $$text2->[0]->{tree_id}->[$$text2->[1]];
      isnt $$node->[0]->{tree_id}->[$$node->[1]],
          $$text->[0]->{tree_id}->[$$text->[1]];

      $node->text_content ('');
      is $node->text_content, '';

      is $node->child_nodes->length, 0;
      is $text->parent_node, undef;
      is $text2->parent_node, undef;
      is $text3->parent_node, undef;
      is $text4->parent_node, undef;

      isnt $$node->[0]->{tree_id}->[$$node->[1]],
          $$text4->[0]->{tree_id}->[$$text4->[1]];
      isnt $$node->[0]->{tree_id}->[$$node->[1]],
          $$text3->[0]->{tree_id}->[$$text3->[1]];
      isnt $$node->[0]->{tree_id}->[$$node->[1]],
          $$text2->[0]->{tree_id}->[$$text2->[1]];
      isnt $$node->[0]->{tree_id}->[$$node->[1]],
          $$text->[0]->{tree_id}->[$$text->[1]];

      done $c;
    } n => 39, name => ['text_content', $node->node_type];
  }

  for my $node (
    $doc->create_document_fragment,
    $doc->create_element ('aa'),
  ) {
    test {
      my $c = shift;

      my $el1 = $doc->create_element ('aa');
      $el1->text_content ('abc');
      my $text1 = $doc->create_text_node ('bbb');
      my $el2 = $doc->create_element ('aa');
      my $comment1 = $doc->create_comment ('af');
      $el2->text_content ('abc d');
      $node->append_child ($el1);
      $node->append_child ($text1);
      $node->append_child ($el2);
      $node->append_child ($comment1);

      is $node->text_content, 'abcbbbabc d';

      $node->text_content ('fa aa');
      is $node->text_content, 'fa aa';

      is $el1->parent_node, undef;
      is $text1->parent_node, undef;
      is $el2->parent_node, undef;
      is $comment1->parent_node, undef;

      is $el1->text_content, 'abc';
      is $text1->text_content, 'bbb';
      is $el2->text_content, 'abc d';
      is $comment1->text_content, 'af';

      done $c;
    } n => 10, name => ['text_content', $node->node_type];
  }

  for my $node (
    $doc->create_document_fragment,
    $doc->create_element ('aa'),
  ) {
    test {
      my $c = shift;

      my $el1 = $doc->create_element ('aa');
      $el1->text_content ('abc');
      my $text1 = $doc->create_text_node ('bbb');
      my $el2 = $doc->create_element ('aa');
      my $el3 = $doc->create_element ('aa');
      my $text2 = $doc->create_text_node ('bA');
      my $text3 = $doc->create_text_node ('zz');
      my $comment1 = $doc->create_comment ('af');
      $node->append_child ($el1);
      $node->append_child ($text1);
      $node->append_child ($el2);
      $el2->append_child ($el3);
      $el3->append_child ($text2);
      $el3->append_child ($text3);
      $node->append_child ($comment1);

      is $node->text_content, 'abcbbbbAzz';

      $node->text_content ('');
      is $node->text_content, '';

      is $el1->parent_node, undef;
      is $text1->parent_node, undef;
      is $el2->parent_node, undef;
      is $comment1->parent_node, undef;
      is $node->child_nodes->length, 0;

      done $c;
    } n => 7, name => ['text_content', $node->node_type];
  }

  for my $node (
    $doc->create_document_fragment,
    $doc->create_element ('aa'),
  ) {
    test {
      my $c = shift;

      my $called;
      my $el1 = $doc->create_element ('aa');
      $el1->text_content ('abc');
      $el1->first_child->set_user_data (destroy => bless sub {
                                             $called = 1;
                                           }, 'test::DestroyCallback');
      ok not $called;

      $el1->text_content ('abc');

      ok $called;

      done $c;
    } n => 2, name => ['text_content', $node->node_type, 'destroy'];
  }
}

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
