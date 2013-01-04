use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $text = $doc->create_text_node ('hoge');
  isa_ok $text, 'Web::DOM::Text';
  isa_ok $text, 'Web::DOM::CharacterData';
  isa_ok $text, 'Web::DOM::Node';

  is $text->node_type, $text->TEXT_NODE;
  is $text->node_name, '#text';
  is $text->first_child, undef;
  is $text->namespace_uri, undef;
  is $text->prefix, undef;
  is $text->manakai_local_name, undef;
  is $text->local_name, undef;

  is $text->data, 'hoge';
  is $text->node_value, 'hoge';
  is $text->text_content, 'hoge';

  $text->node_value ('fuga');
  is $text->node_value, 'fuga';
  is $text->data, 'fuga';
  is $text->text_content, 'fuga';

  $text->data ('abc');
  is $text->node_value, 'abc';
  is $text->data, 'abc';
  is $text->text_content, 'abc';

  $text->text_content ('abc');
  is $text->node_value, 'abc';
  is $text->data, 'abc';
  is $text->text_content, 'abc';

  done $c;
} n => 22, name => 'create_text_node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $text = $doc->create_text_node ('aaa');
  $text->data (undef);
  is $text->data, '';
  done $c;
} n => 1, name => 'data TreatNullAs=EmptyString';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $text = $doc->create_text_node ('');
  is $text->whole_text, '';
  done $c;
} n => 1, name => 'whole_text no parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $text = $doc->create_text_node ('a');
  is $text->whole_text, 'a';
  done $c;
} n => 1, name => 'whole_text no parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('bb');
  my $text = $doc->create_text_node ('abc');
  $el->append_child ($text);
  is $text->whole_text, 'abc';
  done $c;
} n => 1, name => 'whole_text only child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('bb');
  my $text1 = $doc->create_text_node ('124');
  my $text2 = $doc->create_text_node ('abc');
  my $text3 = $doc->create_text_node ('xy');
  $el->append_child ($text1);
  $el->append_child ($text2);
  $el->append_child ($text3);
  is $text1->whole_text, '124abcxy';
  is $text2->whole_text, '124abcxy';
  is $text3->whole_text, '124abcxy';
  done $c;
} n => 3, name => 'whole_text only child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('bb');
  my $text1 = $doc->create_text_node ('124');
  my $text2 = $doc->create_text_node ('');
  my $text3 = $doc->create_text_node ('xy');
  my $el2 = $doc->create_element ('b');
  my $text4 = $doc->create_text_node ('r');
  my $el3 = $doc->create_element ('b');
  my $text5 = $doc->create_text_node ('');
  $el->append_child ($text1);
  $el->append_child ($text2);
  $el->append_child ($text3);
  $el->append_child ($el2);
  $el->append_child ($text4);
  $el->append_child ($el3);
  $el->append_child ($text5);
  is $text1->whole_text, '124xy';
  is $text2->whole_text, '124xy';
  is $text3->whole_text, '124xy';
  is $text4->whole_text, 'r';
  is $text5->whole_text, '';
  done $c;
} n => 5, name => 'whole_text only child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('aa');
  my $text = $doc->create_text_node ('hoge');
  $el->append_child ($text);

  my $text2 = $text->split_text (3);
  isa_ok $text2, 'Web::DOM::Text';
  is $text2->node_type, $text2->TEXT_NODE;
  is $text->data, 'hog';
  is $text2->data, 'e';
  is $text2->owner_document, $doc;
  is $text->parent_node, $el;
  is $text2->parent_node, $el;
  is $el->child_nodes->length, 2;
  is $el->text_content, 'hoge';
  done $c;
} n => 9, name => 'split_text has_parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('aa');
  my $text = $doc->create_text_node ('hoge');
  $el->append_child ($text);

  my $text2 = $text->split_text (4);
  isa_ok $text2, 'Web::DOM::Text';
  is $text2->node_type, $text2->TEXT_NODE;
  is $text->data, 'hoge';
  is $text2->data, '';
  is $text2->owner_document, $doc;
  is $text->parent_node, $el;
  is $text2->parent_node, $el;
  is $el->child_nodes->length, 2;
  is $el->text_content, 'hoge';
  done $c;
} n => 9, name => 'split_text has_parent new text is empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('aa');
  my $text = $doc->create_text_node ('hoge');
  $el->append_child ($text);

  my $text2 = $text->split_text (0);
  isa_ok $text2, 'Web::DOM::Text';
  is $text2->node_type, $text2->TEXT_NODE;
  is $text->data, '';
  is $text2->data, 'hoge';
  is $text2->owner_document, $doc;
  is $text->parent_node, $el;
  is $text2->parent_node, $el;
  is $el->child_nodes->length, 2;
  is $el->text_content, 'hoge';
  done $c;
} n => 9, name => 'split_text has_parent old text is empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('aa');
  my $text = $doc->create_text_node ('hoge');
  $el->append_child ($text);

  my $text2 = $text->split_text (2**32 + 3);
  isa_ok $text2, 'Web::DOM::Text';
  is $text2->node_type, $text2->TEXT_NODE;
  is $text->data, 'hog';
  is $text2->data, 'e';
  is $text2->owner_document, $doc;
  is $text->parent_node, $el;
  is $text2->parent_node, $el;
  is $el->child_nodes->length, 2;
  is $el->text_content, 'hoge';
  done $c;
} n => 9, name => 'split_text int';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('aa');
  my $text = $doc->create_text_node ('hoge');
  $el->append_child ($text);

  my $text2 = $text->split_text (-2**32 + 3);
  isa_ok $text2, 'Web::DOM::Text';
  is $text2->node_type, $text2->TEXT_NODE;
  is $text->data, 'hog';
  is $text2->data, 'e';
  is $text2->owner_document, $doc;
  is $text->parent_node, $el;
  is $text2->parent_node, $el;
  is $el->child_nodes->length, 2;
  is $el->text_content, 'hoge';
  done $c;
} n => 9, name => 'split_text int';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('aa');
  my $text = $doc->create_text_node ('hoge');
  $el->append_child ($text);

  dies_here_ok {
    $text->split_text (5);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'IndexSizeError';
  is $@->message, 'Offset is greater than the length';

  is $text->data, 'hoge';
  is $text->parent_node, $el;
  is $el->child_nodes->length, 1;

  done $c;
} n => 7, name => 'split_text out of range';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('aa');
  my $text = $doc->create_text_node ("ho\x{10004}a");
  $el->append_child ($text);

  my $text2 = $text->split_text (3);
  isa_ok $text2, 'Web::DOM::Text';
  is $text2->node_type, $text2->TEXT_NODE;
  is $text->data, "ho\x{D800}";
  is $text2->data, "\x{DC04}a";
  is $text2->owner_document, $doc;
  is $text->parent_node, $el;
  is $text2->parent_node, $el;
  is $el->child_nodes->length, 2;
  is $el->text_content, "ho\x{D800}\x{DC04}a";
  done $c;
} n => 9, name => 'split_text has_parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $text = $doc->create_text_node ('hoge');

  my $text2 = $text->split_text (3);
  isa_ok $text2, 'Web::DOM::Text';
  is $text2->node_type, $text2->TEXT_NODE;
  is $text->data, 'hog';
  is $text2->data, 'e';
  is $text2->owner_document, $doc;
  is $text->parent_node, undef;
  is $text2->parent_node, undef;

  done $c;
} n => 7, name => 'split_text no parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $text = $doc->create_text_node ('hoge');
  ok not $text->serialize_as_cdata;
  
  $text->serialize_as_cdata (1);
  ok $text->serialize_as_cdata;

  $text->serialize_as_cdata (undef);
  ok not $text->serialize_as_cdata;

  done $c;
} n => 3, name => 'serialize_as_cdata';

run_tests;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
