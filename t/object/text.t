use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
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

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
