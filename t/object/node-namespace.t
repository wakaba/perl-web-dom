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
  my $el = $doc->create_element_ns (undef, 'hoge');

  is $el->lookup_prefix (undef), undef;
  is $el->lookup_prefix (''), undef;
  is $el->lookup_prefix ('hoge'), undef;
  is $el->lookup_prefix ('123'), undef;
  is $el->lookup_namespace_uri (undef), undef;
  is $el->lookup_namespace_uri (''), undef;
  is $el->lookup_namespace_uri ('hoge'), undef;
  is $el->lookup_namespace_uri ('http://foo/'), undef;
  ok $el->is_default_namespace (undef);
  ok $el->is_default_namespace ('');
  ok not $el->is_default_namespace ('http://foo/');

  done $c;
} n => 11, name => 'null namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://foo/', 'hoge');

  is $el->lookup_prefix (undef), undef;
  is $el->lookup_prefix (''), undef;
  is $el->lookup_prefix ('hoge'), undef;
  is $el->lookup_prefix ('123'), undef;
  is $el->lookup_prefix ('http://foo/'), undef;
  is $el->lookup_namespace_uri (undef), 'http://foo/';
  is $el->lookup_namespace_uri (''), 'http://foo/';
  is $el->lookup_namespace_uri ('hoge'), undef;
  is $el->lookup_namespace_uri ('http://foo/'), undef;
  ok not $el->is_default_namespace (undef);
  ok not $el->is_default_namespace ('');
  ok $el->is_default_namespace ('http://foo/');
  ok not $el->is_default_namespace ('http://bar/');

  done $c;
} n => 13, name => 'element default namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://foo/', 'aa:hoge');

  is $el->lookup_prefix (undef), undef;
  is $el->lookup_prefix (''), undef;
  is $el->lookup_prefix ('hoge'), undef;
  is $el->lookup_prefix ('123'), undef;
  is $el->lookup_prefix ('http://foo/'), 'aa';
  is $el->lookup_namespace_uri (undef), undef;
  is $el->lookup_namespace_uri (''), undef;
  is $el->lookup_namespace_uri ('aa'), 'http://foo/';
  is $el->lookup_namespace_uri ('hoge'), undef;
  is $el->lookup_namespace_uri ('http://foo/'), undef;
  ok $el->is_default_namespace (undef);
  ok $el->is_default_namespace ('');
  ok not $el->is_default_namespace ('http://foo/');
  ok not $el->is_default_namespace ('http://bar/');

  done $c;
} n => 14, name => 'element prefixed namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://foo/', 'aa:hoge');
  $el->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', xmlns => 'http://bar/');

  is $el->lookup_prefix (undef), undef;
  is $el->lookup_prefix (''), undef;
  is $el->lookup_prefix ('hoge'), undef;
  is $el->lookup_prefix ('123'), undef;
  is $el->lookup_prefix ('http://foo/'), 'aa';
  is $el->lookup_prefix ('http://bar/'), undef;
  is $el->lookup_namespace_uri (undef), 'http://bar/';
  is $el->lookup_namespace_uri (''), 'http://bar/';
  is $el->lookup_namespace_uri ('aa'), 'http://foo/';
  is $el->lookup_namespace_uri ('hoge'), undef;
  is $el->lookup_namespace_uri ('http://foo/'), undef;
  ok not $el->is_default_namespace (undef);
  ok not $el->is_default_namespace ('');
  ok not $el->is_default_namespace ('http://foo/');
  ok $el->is_default_namespace ('http://bar/');

  done $c;
} n => 15, name => 'element prefixed namespace, has xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://foo/', 'aa:hoge');
  $el->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', xmlns => '');

  is $el->lookup_prefix (undef), undef;
  is $el->lookup_prefix (''), undef;
  is $el->lookup_prefix ('hoge'), undef;
  is $el->lookup_prefix ('123'), undef;
  is $el->lookup_prefix ('http://foo/'), 'aa';
  is $el->lookup_prefix ('http://bar/'), undef;
  is $el->lookup_namespace_uri (undef), undef;
  is $el->lookup_namespace_uri (''), undef;
  is $el->lookup_namespace_uri ('aa'), 'http://foo/';
  is $el->lookup_namespace_uri ('hoge'), undef;
  is $el->lookup_namespace_uri ('http://foo/'), undef;
  ok $el->is_default_namespace (undef);
  ok $el->is_default_namespace ('');
  ok not $el->is_default_namespace ('http://foo/');
  ok not $el->is_default_namespace ('http://bar/');

  done $c;
} n => 15, name => 'element prefixed namespace, has xmlns=""';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://foo/', 'aa:hoge');
  $el->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', "xmlns:foo" => 'http://bar/');

  is $el->lookup_prefix (undef), undef;
  is $el->lookup_prefix (''), undef;
  is $el->lookup_prefix ('hoge'), undef;
  is $el->lookup_prefix ('123'), undef;
  is $el->lookup_prefix ('http://foo/'), 'aa';
  is $el->lookup_prefix ('http://bar/'), 'foo';
  is $el->lookup_namespace_uri (undef), undef;
  is $el->lookup_namespace_uri (''), undef;
  is $el->lookup_namespace_uri ('aa'), 'http://foo/';
  is $el->lookup_namespace_uri ('foo'), 'http://bar/';
  is $el->lookup_namespace_uri ('hoge'), undef;
  is $el->lookup_namespace_uri ('http://foo/'), undef;
  ok $el->is_default_namespace (undef);
  ok $el->is_default_namespace ('');
  ok not $el->is_default_namespace ('http://foo/');
  ok not $el->is_default_namespace ('http://bar/');

  done $c;
} n => 16, name => 'element prefixed namespace, has xmlns:foo';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://foo/', 'aa:hoge');
  $el->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', "xmlns:foo" => '');

  is $el->lookup_prefix (undef), undef;
  is $el->lookup_prefix (''), undef;
  is $el->lookup_prefix ('hoge'), undef;
  is $el->lookup_prefix ('123'), undef;
  is $el->lookup_prefix ('http://foo/'), 'aa';
  is $el->lookup_prefix ('http://bar/'), undef;
  is $el->lookup_namespace_uri (undef), undef;
  is $el->lookup_namespace_uri (''), undef;
  is $el->lookup_namespace_uri ('aa'), 'http://foo/';
  is $el->lookup_namespace_uri ('foo'), undef;
  is $el->lookup_namespace_uri ('hoge'), undef;
  is $el->lookup_namespace_uri ('http://foo/'), undef;
  ok $el->is_default_namespace (undef);
  ok $el->is_default_namespace ('');
  ok not $el->is_default_namespace ('http://foo/');
  ok not $el->is_default_namespace ('http://bar/');

  done $c;
} n => 16, name => 'element prefixed namespace, has xmlns:foo=""';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://foo/', 'aa:hoge');
  $el->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', "xmlns:aa" => 'http://bar/');

  is $el->lookup_prefix (undef), undef;
  is $el->lookup_prefix (''), undef;
  is $el->lookup_prefix ('hoge'), undef;
  is $el->lookup_prefix ('123'), undef;
  is $el->lookup_prefix ('http://foo/'), 'aa';
  is $el->lookup_prefix ('http://bar/'), undef; # DOM3 vs DOM4
  is $el->lookup_namespace_uri (undef), undef;
  is $el->lookup_namespace_uri (''), undef;
  is $el->lookup_namespace_uri ('aa'), 'http://foo/';
  is $el->lookup_namespace_uri ('foo'), undef;
  is $el->lookup_namespace_uri ('hoge'), undef;
  is $el->lookup_namespace_uri ('http://foo/'), undef;
  ok $el->is_default_namespace (undef);
  ok $el->is_default_namespace ('');
  ok not $el->is_default_namespace ('http://foo/');
  ok not $el->is_default_namespace ('http://bar/');

  done $c;
} n => 16, name => 'element prefixed namespace, has xmlns:foo';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('foo');
  $el->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns:bar', 'http://foo/');
  $el->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns:foo', 'http://foo/');
  
  is $el->lookup_prefix ('http://foo/'), 'bar';

  done $c;
} n => 1, name => 'lookup_prefix multiple';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('foo');
  $el->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns', 'http://foo/');
  $el->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns:foo', 'http://foo/');
  
  is $el->lookup_prefix ('http://foo/'), 'foo';

  done $c;
} n => 1, name => 'lookup_prefix multiple';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns (undef, 'hoge');
  my $el2 = $doc->create_element_ns (undef, 'hoge');
  $el1->append_child ($el2);

  $el1->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns:foo', 'http://foo/');
  $el2->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns:foo', '');
  $el1->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns:bar', 'http://bar/');

  is $el2->lookup_prefix ('http://foo/'), 'foo';
  is $el2->lookup_prefix ('http://bar/'), 'bar';
  is $el2->lookup_prefix ('http://baz/'), undef;
  is $el2->lookup_prefix (undef), undef;
  is $el2->lookup_prefix (''), undef;

  is $el2->lookup_namespace_uri (undef), undef;
  is $el2->lookup_namespace_uri (''), undef;
  is $el2->lookup_namespace_uri ('foo'), undef;
  is $el2->lookup_namespace_uri ('bar'), 'http://bar/';

  ok $el2->is_default_namespace (undef);
  ok $el2->is_default_namespace ('');
  ok not $el2->is_default_namespace ('http://foo/');
  ok not $el2->is_default_namespace ('http://bar/');
  ok not $el2->is_default_namespace ('http://baz/');

  done $c;
} n => 14, name => 'lookup_prefix xmlns:foo=""';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://hoge/', 'hoge');
  my $el2 = $doc->create_element_ns (undef, 'hoge');
  $el1->append_child ($el2);

  $el1->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns:foo', 'http://foo/');
  $el2->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns:foo', '');
  $el1->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns:bar', 'http://bar/');

  is $el2->lookup_prefix ('http://foo/'), 'foo';
  is $el2->lookup_prefix ('http://bar/'), 'bar';
  is $el2->lookup_prefix ('http://baz/'), undef;
  is $el2->lookup_prefix ('http://hoge/'), undef;
  is $el2->lookup_prefix (undef), undef;
  is $el2->lookup_prefix (''), undef;

  is $el2->lookup_namespace_uri (undef), 'http://hoge/';
  is $el2->lookup_namespace_uri (''), 'http://hoge/';
  is $el2->lookup_namespace_uri ('foo'), undef;
  is $el2->lookup_namespace_uri ('bar'), 'http://bar/';

  ok not $el2->is_default_namespace (undef);
  ok not $el2->is_default_namespace ('');
  ok not $el2->is_default_namespace ('http://foo/');
  ok not $el2->is_default_namespace ('http://bar/');
  ok not $el2->is_default_namespace ('http://baz/');
  ok $el2->is_default_namespace ('http://hoge/');

  done $c;
} n => 16, name => 'lookup_prefix xmlns:foo=""';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element_ns ('http://hoge/', 'hoge');
  my $el2 = $doc->create_element_ns (undef, 'hoge');
  $el1->append_child ($el2);

  $el1->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns:foo', 'http://foo/');
  $el2->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns:foo', '');
  $el1->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns:bar', 'http://bar/');
  $el2->set_attribute_ns
      ('http://www.w3.org/2000/xmlns/', 'xmlns', '');

  is $el2->lookup_prefix ('http://foo/'), 'foo';
  is $el2->lookup_prefix ('http://bar/'), 'bar';
  is $el2->lookup_prefix ('http://baz/'), undef;
  is $el2->lookup_prefix ('http://hoge/'), undef;
  is $el2->lookup_prefix (undef), undef;
  is $el2->lookup_prefix (''), undef;

  is $el2->lookup_namespace_uri (undef), undef;
  is $el2->lookup_namespace_uri (''), undef;
  is $el2->lookup_namespace_uri ('foo'), undef;
  is $el2->lookup_namespace_uri ('bar'), 'http://bar/';

  ok $el2->is_default_namespace (undef);
  ok $el2->is_default_namespace ('');
  ok not $el2->is_default_namespace ('http://foo/');
  ok not $el2->is_default_namespace ('http://bar/');
  ok not $el2->is_default_namespace ('http://baz/');
  ok not $el2->is_default_namespace ('http://hoge/');

  done $c;
} n => 16, name => 'lookup_prefix xmlns:foo=""';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  is $doc->lookup_namespace_uri (undef), undef;
  is $doc->lookup_namespace_uri (''), undef;
  is $doc->lookup_namespace_uri ('foo'), undef;
  is $doc->lookup_namespace_uri ('http://foo/'), undef;
  is $doc->lookup_prefix (undef), undef;
  is $doc->lookup_prefix (''), undef;
  is $doc->lookup_prefix ('http://foo/'), undef;
  ok $doc->is_default_namespace (undef);
  ok $doc->is_default_namespace ('');
  ok not $doc->is_default_namespace ('http://hoge/');
  
  done $c;
} n => 10, name => 'document empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://foo/', 'foo:bar');
  $doc->append_child ($el);

  is $doc->lookup_namespace_uri (undef), undef;
  is $doc->lookup_namespace_uri (''), undef;
  is $doc->lookup_namespace_uri ('foo'), 'http://foo/';
  is $doc->lookup_namespace_uri ('http://foo/'), undef;
  is $doc->lookup_namespace_uri ('http://bar/'), undef;
  is $doc->lookup_prefix (undef), undef;
  is $doc->lookup_prefix (''), undef;
  is $doc->lookup_prefix ('http://foo/'), 'foo';
  is $doc->lookup_prefix ('http://bar/'), undef;
  ok $doc->is_default_namespace (undef);
  ok $doc->is_default_namespace ('');
  ok not $doc->is_default_namespace ('http://foo/');
  ok not $doc->is_default_namespace ('http://bar/');
  
  done $c;
} n => 13, name => 'document has document element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute ('hoge');

  is $attr->lookup_namespace_uri (undef), undef;
  is $attr->lookup_namespace_uri (''), undef;
  is $attr->lookup_namespace_uri ('foo'), undef;
  is $attr->lookup_namespace_uri ('http://foo/'), undef;
  is $attr->lookup_prefix (undef), undef;
  is $attr->lookup_prefix (''), undef;
  is $attr->lookup_prefix ('http://foo/'), undef;
  ok $attr->is_default_namespace (undef);
  ok $attr->is_default_namespace ('');
  ok not $attr->is_default_namespace ('http://hoge/');
  
  done $c;
} n => 10, name => 'attribute no owner';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://foo/', 'foo:bar');
  my $attr = $doc->create_attribute ('hoge');
  $el->set_attribute_node ($attr);

  is $attr->lookup_namespace_uri (undef), undef;
  is $attr->lookup_namespace_uri (''), undef;
  is $attr->lookup_namespace_uri ('foo'), 'http://foo/';
  is $attr->lookup_namespace_uri ('http://foo/'), undef;
  is $attr->lookup_namespace_uri ('http://bar/'), undef;
  is $attr->lookup_prefix (undef), undef;
  is $attr->lookup_prefix (''), undef;
  is $attr->lookup_prefix ('http://foo/'), 'foo';
  is $attr->lookup_prefix ('http://bar/'), undef;
  ok $attr->is_default_namespace (undef);
  ok $attr->is_default_namespace ('');
  ok not $attr->is_default_namespace ('http://foo/');
  ok not $attr->is_default_namespace ('http://bar/');
  
  done $c;
} n => 13, name => 'attribute has owner';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('foo', '', '');

  is $dt->lookup_namespace_uri (undef), undef;
  is $dt->lookup_namespace_uri (''), undef;
  is $dt->lookup_namespace_uri ('foo'), undef;
  is $dt->lookup_namespace_uri ('http://foo/'), undef;
  is $dt->lookup_prefix (undef), undef;
  is $dt->lookup_prefix (''), undef;
  is $dt->lookup_prefix ('http://foo/'), undef;
  ok $dt->is_default_namespace (undef);
  ok $dt->is_default_namespace ('');
  ok not $dt->is_default_namespace ('http://hoge/');
  
  done $c;
} n => 10, name => 'document_type';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;

  is $df->lookup_namespace_uri (undef), undef;
  is $df->lookup_namespace_uri (''), undef;
  is $df->lookup_namespace_uri ('foo'), undef;
  is $df->lookup_namespace_uri ('http://foo/'), undef;
  is $df->lookup_prefix (undef), undef;
  is $df->lookup_prefix (''), undef;
  is $df->lookup_prefix ('http://foo/'), undef;
  ok $df->is_default_namespace (undef);
  ok $df->is_default_namespace ('');
  ok not $df->is_default_namespace ('http://hoge/');
  
  done $c;
} n => 10, name => 'document_fragment';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://foo/', 'foo:bar');
  my $text = $doc->create_text_node ('foo');
  $el->append_child ($text);

  is $text->lookup_namespace_uri (undef), undef;
  is $text->lookup_namespace_uri (''), undef;
  is $text->lookup_namespace_uri ('foo'), 'http://foo/';
  is $text->lookup_namespace_uri ('http://foo/'), undef;
  is $text->lookup_namespace_uri ('http://bar/'), undef;
  is $text->lookup_prefix (undef), undef;
  is $text->lookup_prefix (''), undef;
  is $text->lookup_prefix ('http://foo/'), 'foo';
  is $text->lookup_prefix ('http://bar/'), undef;
  ok $text->is_default_namespace (undef);
  ok $text->is_default_namespace ('');
  ok not $text->is_default_namespace ('http://foo/');
  ok not $text->is_default_namespace ('http://bar/');
  
  done $c;
} n => 13, name => 'text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://foo/', 'foo:bar');
  my $comment = $doc->create_comment ('foo');
  $el->append_child ($comment);

  is $comment->lookup_namespace_uri (undef), undef;
  is $comment->lookup_namespace_uri (''), undef;
  is $comment->lookup_namespace_uri ('foo'), 'http://foo/';
  is $comment->lookup_namespace_uri ('http://foo/'), undef;
  is $comment->lookup_namespace_uri ('http://bar/'), undef;
  is $comment->lookup_prefix (undef), undef;
  is $comment->lookup_prefix (''), undef;
  is $comment->lookup_prefix ('http://foo/'), 'foo';
  is $comment->lookup_prefix ('http://bar/'), undef;
  ok $comment->is_default_namespace (undef);
  ok $comment->is_default_namespace ('');
  ok not $comment->is_default_namespace ('http://foo/');
  ok not $comment->is_default_namespace ('http://bar/');
  
  done $c;
} n => 13, name => 'comment';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
