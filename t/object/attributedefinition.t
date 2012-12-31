use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;
use Web::DOM::AttributeDefinition;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_attribute_definition ('hoge');
  is $node->node_type, $node->ATTRIBUTE_DEFINITION_NODE;
  is $node->node_name, 'hoge';
  is $node->node_value, '';
  is $node->text_content, '';
  $node->node_value ('foo');
  is $node->node_value, 'foo';
  is $node->text_content, 'foo';
  $node->node_value (undef);
  is $node->node_value, '';
  is $node->text_content, '';
  $node->node_value ('0');
  is $node->node_value, '0';
  is $node->text_content, '0';
  is $node->owner_element_type_definition, undef;
  done $c;
} n => 11, name => 'basic node properties';

test {
  my $c = shift;
  is NO_TYPE_ATTR, 0;
  ok CDATA_ATTR;
  ok ID_ATTR;
  ok IDREF_ATTR;
  ok IDREFS_ATTR;
  ok ENTITY_ATTR;
  ok ENTITIES_ATTR;
  ok NMTOKEN_ATTR;
  ok NMTOKENS_ATTR;
  ok NOTATION_ATTR;
  ok ENUMERATION_ATTR;
  ok UNKNOWN_ATTR;
  done $c;
} n => 12, name => 'declared type';

test {
  my $c = shift;
  is +Web::DOM::AttributeDefinition->NO_TYPE_ATTR, 0;
  ok +Web::DOM::AttributeDefinition->CDATA_ATTR;
  ok +Web::DOM::AttributeDefinition->ID_ATTR;
  ok +Web::DOM::AttributeDefinition->IDREF_ATTR;
  ok +Web::DOM::AttributeDefinition->IDREFS_ATTR;
  ok +Web::DOM::AttributeDefinition->ENTITY_ATTR;
  ok +Web::DOM::AttributeDefinition->ENTITIES_ATTR;
  ok +Web::DOM::AttributeDefinition->NMTOKEN_ATTR;
  ok +Web::DOM::AttributeDefinition->NMTOKENS_ATTR;
  ok +Web::DOM::AttributeDefinition->NOTATION_ATTR;
  ok +Web::DOM::AttributeDefinition->ENUMERATION_ATTR;
  ok +Web::DOM::AttributeDefinition->UNKNOWN_ATTR;
  done $c;
} n => 12, name => 'declared type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_definition ('hoge');
  is $attr->NO_TYPE_ATTR, 0;
  ok $attr->CDATA_ATTR;
  ok $attr->ID_ATTR;
  ok $attr->IDREF_ATTR;
  ok $attr->IDREFS_ATTR;
  ok $attr->ENTITY_ATTR;
  ok $attr->ENTITIES_ATTR;
  ok $attr->NMTOKEN_ATTR;
  ok $attr->NMTOKENS_ATTR;
  ok $attr->NOTATION_ATTR;
  ok $attr->ENUMERATION_ATTR;
  ok $attr->UNKNOWN_ATTR;
  done $c;
} n => 12, name => 'declared type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('aa');
  is $adef->declared_type, $adef->NO_TYPE_ATTR;

  $adef->declared_type (ENUMERATION_ATTR);
  is $adef->declared_type, ENUMERATION_ATTR;

  $adef->declared_type (UNKNOWN_ATTR + 2**16);
  is $adef->declared_type, UNKNOWN_ATTR;

  $adef->declared_type (-2**16 + NOTATION_ATTR - 0.3);
  is $adef->declared_type, NOTATION_ATTR;

  $adef->declared_type (undef);
  is $adef->declared_type, 0;

  done $c;
} n => 5, name => 'declared_type';

test {
  my $c = shift;
  is UNKNOWN_DEFAULT, 0;
  ok FIXED_DEFAULT;
  ok REQUIRED_DEFAULT;
  ok IMPLIED_DEFAULT;
  ok EXPLICIT_DEFAULT;
  done $c;
} n => 5, name => 'default type';

test {
  my $c = shift;
  is +Web::DOM::AttributeDefinition->UNKNOWN_DEFAULT, 0;
  ok +Web::DOM::AttributeDefinition->FIXED_DEFAULT;
  ok +Web::DOM::AttributeDefinition->REQUIRED_DEFAULT;
  ok +Web::DOM::AttributeDefinition->IMPLIED_DEFAULT;
  ok +Web::DOM::AttributeDefinition->EXPLICIT_DEFAULT;
  done $c;
} n => 5, name => 'default type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_definition ('hoge');
  is $attr->UNKNOWN_DEFAULT, 0;
  ok $attr->FIXED_DEFAULT;
  ok $attr->REQUIRED_DEFAULT;
  ok $attr->IMPLIED_DEFAULT;
  ok $attr->EXPLICIT_DEFAULT;
  done $c;
} n => 5, name => 'default type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('aa');
  is $adef->default_type, $adef->UNKNOWN_DEFAULT;

  $adef->default_type (REQUIRED_DEFAULT);
  is $adef->default_type, REQUIRED_DEFAULT;

  $adef->default_type (IMPLIED_DEFAULT + 2**16);
  is $adef->default_type, IMPLIED_DEFAULT;

  $adef->default_type (-2**16 + EXPLICIT_DEFAULT - 0.3);
  is $adef->default_type, EXPLICIT_DEFAULT;

  $adef->default_type (undef);
  is $adef->default_type, 0;

  done $c;
} n => 5, name => 'default_type';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
