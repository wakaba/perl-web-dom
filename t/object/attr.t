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
  my $el = $doc->create_element ('a');
  $el->set_attribute (hoge => 'aa r');

  my $attr = $el->attributes->[0];
  is $attr->node_type, $attr->ATTRIBUTE_NODE;
  is $attr->node_name, 'hoge';
  is $attr->name, 'hoge';
  is $attr->manakai_name, 'hoge';
  is $attr->local_name, 'hoge';
  is $attr->manakai_local_name, 'hoge';
  is $attr->namespace_uri, undef;
  is $attr->prefix, undef;
  ok not $attr->has_attributes;
  is $attr->attributes, undef;
  is $attr->parent_node, undef;
  is $attr->previous_sibling, undef;
  is $attr->next_sibling, undef;
  is $attr->node_value, 'aa r';
  is $attr->text_content, 'aa r';
  is $attr->owner_document, $doc;
  ok $attr->specified;

  done $c;
} n => 17, name => 'basic node operations';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('fff', 'aa:hoge' => 'aa r');

  my $attr = $el->attributes->[0];
  is $attr->node_type, $attr->ATTRIBUTE_NODE;
  is $attr->node_name, 'aa:hoge';
  is $attr->name, 'aa:hoge';
  is $attr->manakai_name, 'aa:hoge';
  is $attr->local_name, 'hoge';
  is $attr->manakai_local_name, 'hoge';
  is $attr->namespace_uri, 'fff';
  is $attr->prefix, 'aa';
  ok not $attr->has_attributes;
  is $attr->attributes, undef;
  is $attr->parent_node, undef;
  is $attr->previous_sibling, undef;
  is $attr->next_sibling, undef;
  is $attr->node_value, 'aa r';
  is $attr->text_content, 'aa r';
  is $attr->owner_document, $doc;
  ok $attr->specified;

  done $c;
} n => 17, name => 'basic node operations, namespaced';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('ff');
  $el->set_attribute ('aab' => 'e ');

  my $attr = $el->attributes->[0];
  $attr->node_value ("\x{5000}aa ");
  is $attr->node_value, "\x{5000}aa ";
  is $attr->value, "\x{5000}aa ";
  is $attr->text_content, "\x{5000}aa ";

  $attr->value ('0');
  is $attr->value, '0';
  is $attr->node_value, '0';
  is $attr->text_content, '0';

  $attr->text_content ('');
  is $attr->value, '';
  is $attr->node_value, '';
  is $attr->text_content, '';

  done $c;
} n => 9, name => 'node_value setter';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aaa', 'gg:gff', 'aa');

  my $attr = $el->attributes->[0];

  $attr->prefix (undef);
  is $attr->name, 'gff';
  is $attr->node_name, 'gff';
  is $attr->manakai_name, 'gff';

  $attr->prefix ('aaaa');
  is $attr->name, 'aaaa:gff';
  is $attr->node_name, 'aaaa:gff';
  is $attr->manakai_name, 'aaaa:gff';
  is $attr->prefix, 'aaaa';
  is $attr->local_name, 'gff';
  is $attr->namespace_uri, 'aaa';

  done $c;
} n => 9, name => 'prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute (hoge => 'aa');

  my $attr = $el->attributes->[0];
  my $oe = $attr->owner_element;
  isa_ok $oe, 'Web::DOM::Element';
  is $oe, $el;

  done $c;
} n => 2, name => 'owner_element simple attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aaa', hoge => 'aa');

  my $attr = $el->attributes->[0];
  my $oe = $attr->owner_element;
  isa_ok $oe, 'Web::DOM::Element';
  is $oe, $el;

  done $c;
} n => 2, name => 'owner_element node attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute (hoge => 12);
  
  my $attr = $el->attributes->[0];
  ok $attr->specified;

  $attr->specified (0);
  ok $attr->specified;

  $attr->specified (1);
  ok $attr->specified;

  done $c;
} n => 3, name => 'specified';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
