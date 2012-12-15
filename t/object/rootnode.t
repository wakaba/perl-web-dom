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
    $node->append_child ($doc->create_processing_instruction ('x', ''));
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

{
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->implementation->create_document,
    $doc->create_element ('a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      my $called;
      $node->set_user_data (destroy => bless sub {
                              $called = 1;
                            }, 'test::DestroyCallback');
      
      my $col = $node->children;
      isa_ok $col, 'Web::DOM::HTMLCollection';
      ok not $col->isa ('Web::DOM::NodeList');
      
      is $col->length, 0;
      is scalar @$col, 0;

      undef $node;
      ok not $called;
      
      undef $col;
      ok $called;
      
      done $c;
    } n => 6, name => ['children empty', $node->node_type];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->implementation->create_document,
    $doc->create_element ('a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      my $doc = new Web::DOM::Document;
      my $node = $doc->create_element ('a');
      my $called;
      $node->set_user_data (destroy => bless sub {
                              $called = 1;
                            }, 'test::DestroyCallback');

      my $el1 = $doc->create_comment ('a');
      my $el2 = $doc->create_processing_instruction ('b', '');
      my $el3 = $doc->create_element ('a');
      my $el4 = $doc->create_element ('a');
      $node->append_child ($el1);
      $node->append_child ($el2);
      $node->append_child ($el3);
      $el3->append_child ($el4);

      my $col = $node->children;
      isa_ok $col, 'Web::DOM::HTMLCollection';
      ok not $col->isa ('Web::DOM::NodeList');
      
      is $col->length, 1;
      is scalar @$col, 1;

      is $col->[0], $el3;
      is $col->[1], undef;

      undef $node;
      undef $el1;
      undef $el2;
      undef $el3;
      undef $el4;
      ok not $called;

      is $col->[0]->parent_node->children, $col;
      isnt $col->[0]->parent_node->child_nodes, $col;

      undef $col;
      ok $called;
      
      done $c;
    } n => 10, name => ['children has children', $node->node_type];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->create_element ('a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      my $doc = new Web::DOM::Document;
      my $node = $doc->create_element ('a');
      my $called;
      $node->set_user_data (destroy => bless sub {
                              $called = 1;
                            }, 'test::DestroyCallback');

      my $el1 = $doc->create_element ('a');
      my $el2 = $doc->create_element ('b', '');
      my $el3 = $doc->create_element ('a');
      my $el4 = $doc->create_element ('a');
      $node->append_child ($el1);
      $node->append_child ($el2);
      $node->append_child ($el3);
      $el3->append_child ($el4);

      my $col = $node->children;
      isa_ok $col, 'Web::DOM::HTMLCollection';
      ok not $col->isa ('Web::DOM::NodeList');
      
      is $col->length, 3;
      is scalar @$col, 3;

      is $col->[0], $el1;
      is $col->[1], $el2;
      is $col->[2], $el3;
      is $col->[3], undef;

      undef $node;
      undef $el1;
      undef $el2;
      undef $el3;
      undef $el4;
      ok not $called;

      is $col->[0]->parent_node->children, $col;
      isnt $col->[0]->parent_node->child_nodes, $col;

      undef $col;
      ok $called;
      
      done $c;
    } n => 12, name => ['children has children', $node->node_type];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->implementation->create_document,
    $doc->create_element ('a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      my $col = $node->get_elements_by_tag_name ('*');
      isa_ok $col, 'Web::DOM::HTMLCollection';
      is scalar @$col, 0;
      is $col->length, 0;
      is $col->[0], undef;
      done $c;
    } n => 4, name => ['get_elements_by_tag_name * empty', $node->node_type];
  }
}

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc->implementation->create_document,
    $doc->create_element ('a'),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      my $doc = $node->owner_document || $node;
      my $el1 = $doc->create_element ('a');
      $node->append_child ($el1);
      my $el2 = $doc->create_element ('b');
      $el1->append_child ($el2);
      my $text1 = $doc->create_text_node ('c');
      $el1->append_child ($text1);
      my $el3 = $doc->create_element ('d');
      $el1->append_child ($el3);
      my $el4 = $doc->create_element ('e');
      $el1->append_child ($el4);
      my $col = $node->get_elements_by_tag_name ('*');
      isa_ok $col, 'Web::DOM::HTMLCollection';
      is scalar @$col, 4;
      is $col->length, 4;
      is $col->[0], $el1;
      is $col->[1], $el2;
      is $col->[2], $el3;
      is $col->[3], $el4;
      is $col->[4], undef;
      done $c;
    } n => 8, name => ['get_elements_by_tag_name * not empty', $node->node_type];
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $cl1 = $doc->get_elements_by_tag_name ('*');
  my $cl2 = $doc->get_elements_by_tag_name ('*');

  ok $cl1 eq $cl2;
  ok not $cl1 ne $cl2;

  my $node = $doc->create_element ('a');

  my $cl3 = $node->get_elements_by_tag_name ('*');
  my $cl4 = $node->get_elements_by_tag_name ('*');
  
  ok $cl1 ne $cl3;
  ok not $cl1 eq $cl3;
  ok $cl3 eq $cl4;
  ok not $cl3 ne $cl4;
  
  done $c;
} n => 6, name => 'get_elements_by_tag_name * eq';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element ('a');
  my $col = $node->get_elements_by_tag_name ('*');

  my $el1 = $doc->create_element ('a');
  $node->append_child ($el1);

  is $col->length, 1;

  my $el2 = $doc->create_element ('b');
  $el1->append_child ($el2);

  is $col->length, 2;

  my $el3 = $doc->create_text_node ('c');
  $el2->append_child ($el3);

  is $col->length, 2;

  $node->remove_child ($el1);
  
  is $col->length, 0;

  done $c;
} n => 4, name => 'get_elements_by_tag_name * descendant mutation';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
