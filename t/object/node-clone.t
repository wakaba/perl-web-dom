use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $clone = $doc->clone_node;
  isa_ok $clone, 'Web::DOM::Document';
  ok not $clone->isa ('Web::DOM::XMLDocument');
  isnt $clone, $doc;
  is $clone->node_type, $clone->DOCUMENT_NODE;
  ok not $clone->manakai_is_html;
  is $clone->manakai_compat_mode, 'no quirks';
  is $clone->child_nodes->length, 0;
  is $clone->content_type, 'application/xml';
  is $clone->url, 'about:blank';
  # original unique origin

  done $c;
} n => 9, name => 'document empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $clone = $doc->clone_node (1);
  isa_ok $clone, 'Web::DOM::Document';
  ok not $clone->isa ('Web::DOM::XMLDocument');
  isnt $clone, $doc;
  is $clone->node_type, $clone->DOCUMENT_NODE;
  ok not $clone->manakai_is_html;
  is $clone->manakai_compat_mode, 'no quirks';
  is $clone->child_nodes->length, 0;
  is $clone->content_type, 'application/xml';
  is $clone->url, 'about:blank';
  # original unique origin

  done $c;
} n => 9, name => 'document empty deep';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $doc->append_child ($el);

  my $clone = $doc->clone_node;
  isa_ok $clone, 'Web::DOM::Document';
  ok not $clone->isa ('Web::DOM::XMLDocument');
  isnt $clone, $doc;
  is $clone->node_type, $clone->DOCUMENT_NODE;
  ok not $clone->manakai_is_html;
  is $clone->manakai_compat_mode, 'no quirks';
  is $clone->child_nodes->length, 0;
  is $clone->content_type, 'application/xml';
  is $clone->url, 'about:blank';
  # original unique origin

  done $c;
} n => 9, name => 'document not empty not deep';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $doc->append_child ($el);

  my $clone = $doc->clone_node (1);
  isa_ok $clone, 'Web::DOM::Document';
  ok not $clone->isa ('Web::DOM::XMLDocument');
  isnt $clone, $doc;
  is $clone->node_type, $clone->DOCUMENT_NODE;
  ok not $clone->manakai_is_html;
  is $clone->manakai_compat_mode, 'no quirks';
  is $clone->child_nodes->length, 1;
  is $clone->content_type, 'application/xml';
  is $clone->url, 'about:blank';
  # original unique origin

  my $el2 = $clone->first_child;
  is $el2->tag_name, $el->tag_name;
  is $el2->first_child, undef;
  isnt $el2, $el;

  done $c;
} n => 12, name => 'document deep';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new->implementation->create_document;
  my $clone = $doc->clone_node;
  isa_ok $clone, 'Web::DOM::XMLDocument';
  is $clone->first_child, undef;
  ok not $clone->manakai_is_html;
  done $c;
} n => 3, name => 'xmldocument';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  $doc->manakai_is_html (1);

  my $clone = $doc->clone_node (1);
  isa_ok $clone, 'Web::DOM::Document';
  ok not $clone->manakai_is_html;

  done $c;
} n => 2, name => 'htmldocument';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el = $doc->create_element ('a');
  $df->append_child ($el);

  my $clone = $df->clone_node (0);
  isa_ok $clone, 'Web::DOM::DocumentFragment';
  is $clone->node_type, $clone->DOCUMENT_FRAGMENT_NODE;
  is $clone->first_child, undef;
  is $clone->owner_document, $doc;

  isnt $clone, $df;
  
  done $c;
} n => 5, name => 'document fragment';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el = $doc->create_element ('a');
  $df->append_child ($el);
  my $el2 = $doc->create_element ('b');
  $el->append_child ($el2);

  my $clone = $df->clone_node (1);
  isa_ok $clone, 'Web::DOM::DocumentFragment';
  is $clone->node_type, $clone->DOCUMENT_FRAGMENT_NODE;
  is $clone->owner_document, $doc;

  is $clone->first_child->first_child->local_name, 'b';

  isnt $clone, $df;
  
  done $c;
} n => 5, name => 'document fragment with children';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('af', 'bb', 'cc');

  my $clone = $dt->clone_node (1);
  isa_ok $clone, 'Web::DOM::DocumentType';
  is $clone->node_type, $clone->DOCUMENT_TYPE_NODE;
  is $clone->name, 'af';
  is $clone->public_id, 'bb';
  is $clone->system_id, 'cc';
  is $clone->owner_document, $doc;
  
  done $c;
} n => 6, name => 'document type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $text = $doc->create_text_node ('aaa b');
  my $clone = $text->clone_node;
  isa_ok $clone, 'Web::DOM::Text';
  is $clone->node_type, $clone->TEXT_NODE;
  is $clone->data, 'aaa b';
  done $c;
} n => 3, name => 'text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $comment = $doc->create_comment ('aaa b');
  my $clone = $comment->clone_node;
  isa_ok $clone, 'Web::DOM::Comment';
  is $clone->node_type, $clone->COMMENT_NODE;
  is $clone->data, 'aaa b';
  done $c;
} n => 3, name => 'comment';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('aa', 'aaa b');
  my $clone = $pi->clone_node;
  isa_ok $clone, 'Web::DOM::ProcessingInstruction';
  is $clone->node_type, $clone->PROCESSING_INSTRUCTION_NODE;
  is $clone->target, 'aa';
  is $clone->data, 'aaa b';
  done $c;
} n => 4, name => 'pi';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_ns ('hoge', 'fuga:aAa');
  $attr->value ('aaabb');
  $attr->specified (0);
  
  my $clone = $attr->clone_node;
  isa_ok $clone, 'Web::DOM::Attr';
  is $clone->node_type, $clone->ATTRIBUTE_NODE;
  is $clone->prefix, 'fuga';
  is $clone->namespace_uri, 'hoge';
  is $clone->local_name, 'aAa';
  is $clone->value, 'aaabb';
  ok $clone->specified;
  is $clone->owner_element, undef;

  done $c;
} n => 8, name => 'attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('hoge', 'fuga:aAa');
  $el->text_content ('aaabb');
  
  my $clone = $el->clone_node;
  isa_ok $clone, 'Web::DOM::Element';
  is $clone->node_type, $clone->ELEMENT_NODE;
  is $clone->prefix, 'fuga';
  is $clone->namespace_uri, 'hoge';
  is $clone->local_name, 'aAa';
  is $clone->text_content, '';
  is $clone->parent_node, undef;

  done $c;
} n => 7, name => 'element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('hoge', 'fuga:aAa');
  $el->text_content ('aaabb');
  
  my $clone = $el->clone_node (1);
  isa_ok $clone, 'Web::DOM::Element';
  is $clone->node_type, $clone->ELEMENT_NODE;
  is $clone->prefix, 'fuga';
  is $clone->namespace_uri, 'hoge';
  is $clone->local_name, 'aAa';
  is $clone->text_content, 'aaabb';
  is $clone->parent_node, undef;

  done $c;
} n => 7, name => 'element deep';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('hoge', 'fuga:aAa');
  $el->text_content ('aaabb');
  $el->append_child ($doc->create_element ('fuga'));
  
  my $clone = $el->clone_node (1);
  isa_ok $clone, 'Web::DOM::Element';
  is $clone->node_type, $clone->ELEMENT_NODE;
  is $clone->prefix, 'fuga';
  is $clone->namespace_uri, 'hoge';
  is $clone->local_name, 'aAa';
  is $clone->text_content, 'aaabb';
  is $clone->child_nodes->length, 2;
  is $clone->last_child->local_name, 'fuga';
  is $clone->parent_node, undef;

  done $c;
} n => 9, name => 'element deep';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns
      ('http://www.w3.org/1999/xhtml', 'fuga:aAa');
  $el->text_content ('aaabb');
  
  my $clone = $el->clone_node (1);
  isa_ok $clone, 'Web::DOM::Element';
  is $clone->node_type, $clone->ELEMENT_NODE;
  is $clone->prefix, 'fuga';
  is $clone->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $clone->local_name, 'aAa';
  is $clone->text_content, 'aaabb';
  is $clone->parent_node, undef;

  done $c;
} n => 7, name => 'element html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns
      ('http://www.w3.org/1999/xhtml', 'fuga:aAa');
  $el->text_content ('aaabb');
  $el->set_attribute (hoge => 'fuga');
  $el->set_attribute_ns ('aaa', hoge => 'fuga2');
  
  my $clone = $el->clone_node (1);
  isa_ok $clone, 'Web::DOM::Element';
  is $clone->node_type, $clone->ELEMENT_NODE;
  is $clone->prefix, 'fuga';
  is $clone->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $clone->local_name, 'aAa';
  is $clone->text_content, 'aaabb';
  is $clone->parent_node, undef;
  is $clone->get_attribute_ns (undef, 'hoge'), 'fuga';
  is $clone->get_attribute_ns ('aaa', 'hoge'), 'fuga2';

  done $c;
} n => 9, name => 'element html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  $el1->append_child ($el2);

  my $el3 = $el2->clone_node (1);
  isnt $el3, $el2;
  is $el3->parent_node, undef;
  is $el2->parent_node, $el1;

  done $c;
} n => 3, name => 'parent_node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_attribute ('a');
  $el1->set_attribute_node ($el2);

  my $el3 = $el2->clone_node (1);
  isnt $el3, $el2;
  is $el3->owner_element, undef;
  is $el2->owner_element, $el1;

  done $c;
} n => 3, name => 'owner_element';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
