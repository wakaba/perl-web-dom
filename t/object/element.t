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
  my $el = $doc->create_element ('el');

  isa_ok $el, 'Web::DOM::Element';
  is $el->node_type, $el->ELEMENT_NODE;
  is $el->local_name, 'el';
  is $el->manakai_local_name, 'el';
  is $el->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el->prefix, undef;
  is $el->tag_name, 'el';
  is $el->manakai_tag_name, 'el';
  is $el->node_name, $el->tag_name;

  is $el->node_value, undef;
  $el->node_value ('hoge');
  is $el->node_value, undef;

  done $c;
} name => 'basic / XHTML', n => 11;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('abc');
  is $el->local_name, 'abc';
  is $el->manakai_local_name, 'abc';
  is $el->prefix, undef;
  is $el->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el->tag_name, 'ABC';
  is $el->manakai_tag_name, 'abc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / HTML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns (undef, 'abc');
  is $el->local_name, 'abc';
  is $el->manakai_local_name, 'abc';
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->tag_name, 'abc';
  is $el->manakai_tag_name, 'abc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / null in HTML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns
      ('http://www.w3.org/1999/xhtml', 'HoGe:aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, 'HoGe';
  is $el->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el->tag_name, 'HOGE:ABC';
  is $el->manakai_tag_name, 'HoGe:aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / HTML prefixed in HTML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://hoge', 'aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, undef;
  is $el->namespace_uri, 'http://hoge';
  is $el->tag_name, 'aBc';
  is $el->manakai_tag_name, 'aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / XML in HTML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://hoge', 'AA:aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, 'AA';
  is $el->namespace_uri, 'http://hoge';
  is $el->tag_name, 'AA:aBc';
  is $el->manakai_tag_name, 'AA:aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / XML prefixed in HTML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (undef, 'aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->tag_name, 'aBc';
  is $el->manakai_tag_name, 'aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / null in XML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/1999/xhtml', 'aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, undef;
  is $el->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el->tag_name, 'aBc';
  is $el->manakai_tag_name, 'aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / HTML in XML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://hoge', 'aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, undef;
  is $el->namespace_uri, 'http://hoge';
  is $el->tag_name, 'aBc';
  is $el->manakai_tag_name, 'aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / XML in XML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://hoge', 'AA:aBc');
  is $el->local_name, 'aBc';
  is $el->manakai_local_name, 'aBc';
  is $el->prefix, 'AA';
  is $el->namespace_uri, 'http://hoge';
  is $el->tag_name, 'AA:aBc';
  is $el->manakai_tag_name, 'AA:aBc';
  is $el->node_name, $el->tag_name;
  done $c;
} n => 7, name => 'names / XML prefixed in XML';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('hoGe');
  ok $el->manakai_element_type_match
      ('http://www.w3.org/1999/xhtml', 'hoGe');
  ok not $el->manakai_element_type_match
      ('http://www.w3.org/1999/xhtml', 'hoge');
  ok not $el->manakai_element_type_match (undef, 'hoGe');
  ok not $el->manakai_element_type_match ('', 'hoGe');

  done $c;
} n => 4, name => 'manakai_element_type_match';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element_ns (undef, 'hoGe');
  ok not $el->manakai_element_type_match
      ('http://www.w3.org/1999/xhtml', 'hoGe');
  ok not $el->manakai_element_type_match
      ('http://www.w3.org/1999/xhtml', 'hoge');
  ok $el->manakai_element_type_match (undef, 'hoGe');
  ok $el->manakai_element_type_match ('', 'hoGe');

  done $c;
} n => 4, name => 'manakai_element_type_match';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  
  is $el->manakai_base_uri, undef;

  $el->manakai_base_uri ('http://foo/');
  is $el->manakai_base_uri, 'http://foo/';

  $el->manakai_base_uri ('0');
  is $el->manakai_base_uri, '0';

  $el->manakai_base_uri (undef);
  is $el->manakai_base_uri, undef;

  done $c;
} n => 4, name => 'manakai_base_uri';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
