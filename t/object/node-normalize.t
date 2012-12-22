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
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->normalize;

  is $el->child_nodes->length, 0;
  done $c;
} n => 1, name => 'normalize empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('');
  $el->append_child ($text1);

  $el->normalize;

  is $el->child_nodes->length, 0;
  is $text1->parent_node, undef;

  is $text1->data, '';

  done $c;
} n => 3, name => 'normalize an empty text node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('bb');
  $el->append_child ($text1);

  $el->normalize;

  is $el->child_nodes->length, 1;
  is $el->first_child, $text1;
  is $text1->parent_node, $el;

  is $text1->data, 'bb';

  done $c;
} n => 4, name => 'normalize a text node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('bb');
  my $text2 = $doc->create_text_node ('cc');
  $el->append_child ($text1);
  $el->append_child ($text2);

  $el->normalize;

  is $el->child_nodes->length, 1;
  is $el->first_child, $text1;
  is $text1->parent_node, $el;
  is $text2->parent_node, undef;

  is $text1->data, 'bbcc';
  is $text2->data, 'cc';

  done $c;
} n => 6, name => 'normalize two text nodes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('bb');
  my $text2 = $doc->create_text_node ('cc1');
  my $text3 = $doc->create_text_node ('cc2');
  my $el1 = $doc->create_element ('foo');
  my $text4 = $doc->create_text_node ('cc3');
  my $text5 = $doc->create_text_node ('cc4');
  $el->append_child ($text1);
  $el->append_child ($text2);
  $el->append_child ($text3);
  $el->append_child ($el1);
  $el->append_child ($text4);
  $el->append_child ($text5);

  $el->normalize;

  is $el->child_nodes->length, 3;
  is $el->child_nodes->[0], $text1;
  is $el->child_nodes->[1], $el1;
  is $el->child_nodes->[2], $text4;
  is $text1->parent_node, $el;
  is $text2->parent_node, undef;
  is $text3->parent_node, undef;
  is $el1->parent_node, $el;
  is $text4->parent_node, $el;
  is $text5->parent_node, undef;

  is $text1->data, 'bbcc1cc2';
  is $text2->data, 'cc1';
  is $text3->data, 'cc2';
  is $text4->data, 'cc3cc4';
  is $text5->data, 'cc4';

  done $c;
} n => 15, name => 'normalize many nodes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('bb');
  my $text2 = $doc->create_text_node ('cc1');
  my $text3 = $doc->create_text_node ('cc2');
  my $el1 = $doc->create_element ('foo');
  my $text4 = $doc->create_text_node ('cc3');
  my $text5 = $doc->create_text_node ('cc4');
  my $text6 = $doc->create_text_node ('');
  $el->append_child ($text1);
  $el->append_child ($text2);
  $el->append_child ($text3);
  $el->append_child ($el1);
  $el1->append_child ($text4);
  $el1->append_child ($text5);
  $el->append_child ($text6);

  $el->normalize;

  is $el->child_nodes->length, 2;
  is $el->child_nodes->[0], $text1;
  is $el->child_nodes->[1], $el1;
  is $el1->child_nodes->length, 1;
  is $el1->child_nodes->[0], $text4;
  is $text1->parent_node, $el;
  is $text2->parent_node, undef;
  is $text3->parent_node, undef;
  is $el1->parent_node, $el;
  is $text4->parent_node, $el1;
  is $text5->parent_node, undef;
  is $text6->parent_node, undef;

  is $text1->data, 'bbcc1cc2';
  is $text2->data, 'cc1';
  is $text3->data, 'cc2';
  is $text4->data, 'cc3cc4';
  is $text5->data, 'cc4';
  is $text6->data, '';

  is $$el->[0]->{tree_id}->[$$el->[1]],
      $$text1->[0]->{tree_id}->[$$text1->[1]];
  is $$el->[0]->{tree_id}->[$$el->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];
  is $$el->[0]->{tree_id}->[$$el->[1]],
      $$text4->[0]->{tree_id}->[$$text4->[1]];
  isnt $$el->[0]->{tree_id}->[$$el->[1]],
      $$text2->[0]->{tree_id}->[$$text2->[1]];
  isnt $$el->[0]->{tree_id}->[$$el->[1]],
      $$text3->[0]->{tree_id}->[$$text3->[1]];
  isnt $$text2->[0]->{tree_id}->[$$text2->[1]],
      $$text3->[0]->{tree_id}->[$$text3->[1]];
  isnt $$el->[0]->{tree_id}->[$$el->[1]],
      $$text5->[0]->{tree_id}->[$$text5->[1]];
  isnt $$el->[0]->{tree_id}->[$$el->[1]],
      $$text6->[0]->{tree_id}->[$$text6->[1]];

  done $c;
} n => 26, name => 'normalize many nodes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('bb');
  my $text2 = $doc->create_text_node ('cc');
  $el->append_child ($text1);
  $el->append_child ($text2);
  my $called;
  $text2->set_user_data (destroy => bless sub {
                           $called = 1;
                         }, 'test::DestroyCallback');
  undef $text2;

  $el->normalize;

  ok $called;
  done $c;
} n => 1, name => 'normalize two text nodes, destroy';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('');
  $el->append_child ($text1);
  my $called;
  $text1->set_user_data (destroy => bless sub {
                           $called = 1;
                         }, 'test::DestroyCallback');
  undef $text1;

  $el->normalize;

  ok $called;
  done $c;
} n => 1, name => 'normalize two text nodes, destroy';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('');
  my $text2 = $doc->create_text_node ('abc');
  $el->append_child ($text1);
  $el->append_child ($text2);

  $el->normalize;

  is $el->child_nodes->length, 1;
  is $el->first_child, $text2;
  is $text2->data, 'abc';

  is $text2->parent_node, $el;
  is $text1->parent_node, undef;

  done $c;
} n => 5, name => 'normalize empty - nonempty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('');
  my $text2 = $doc->create_text_node ('');
  my $text3 = $doc->create_text_node ('');
  my $text4 = $doc->create_text_node ('abc');
  my $text5 = $doc->create_text_node ('');
  $el->append_child ($text1);
  $el->append_child ($text2);
  $el->append_child ($text3);
  $el->append_child ($text4);
  $el->append_child ($text5);

  $el->normalize;

  is $el->child_nodes->length, 1;
  is $el->first_child, $text4;
  is $text4->data, 'abc';
  is $text1->data, '';
  is $text2->data, '';
  is $text3->data, '';
  is $text5->data, '';

  is $text4->parent_node, $el;
  is $text1->parent_node, undef;
  is $text2->parent_node, undef;
  is $text3->parent_node, undef;
  is $text5->parent_node, undef;

  done $c;
} n => 12, name => 'normalize empty - nonempty';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
