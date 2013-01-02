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
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('aa');

  is $el->inner_html, '';

  $el->inner_html ('<p title>ho&ge</P>foo<p>bar');
  is $el->inner_html, '<p title="">ho&amp;ge</p>foo<p>bar</p>';

  $el->inner_html (undef);
  is $el->inner_html, '';

  $el->inner_html ('<tr><td>hoge<th>foo');
  is $el->inner_html, 'hogefoo';

  done $c;
} n => 4, name => 'element.inner_html html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('table');

  is $el->inner_html, '';

  $el->inner_html ('<p title>ho&ge</P>foo<p>bar');
  is $el->inner_html, '<p title="">ho&amp;ge</p>foo<p>bar</p>';

  $el->inner_html ('<tr><td>hoge<th>foo');
  is $el->inner_html, '<tbody><tr><td>hoge</td><th>foo</th></tr></tbody>';

  $el->inner_html (undef);
  is $el->inner_html, '';

  done $c;
} n => 4, name => 'element.inner_html html table';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/svg', 'g');

  is $el->inner_html, '';

  $el->inner_html ('<p title>ho&ge</P>foo<p>bar');
  is $el->inner_html, '<p title="">ho&amp;ge</p>foo<p>bar</p>';

  $el->inner_html (undef);
  is $el->inner_html, '';

  $el->inner_html ('<tr><td>hoge<th>fo<![CDATA[o]]>');
  is $el->inner_html, 'hogefo<!--[CDATA[o]]-->';

  done $c;
} n => 4, name => 'element.inner_html html svg';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $df = $doc->create_document_fragment;

  is $df->inner_html, '';

  $df->inner_html ('hoge<p>foo');
  is $df->inner_html, 'hoge<p>foo</p>';

  $df->inner_html (undef);
  is $df->inner_html, '';

  $df->inner_html ('hoge<p>foo<tr>aa');
  is $df->inner_html, 'hoge<p>fooaa</p>';

  done $c;
} n => 4, name => 'df.inner_html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);

  is $doc->inner_html, '';

  $doc->inner_html ('hoge<p>foo<p>bar');
  is $doc->inner_html,
      '<html><head></head><body>hoge<p>foo</p><p>bar</p></body></html>';

  $doc->inner_html (undef);
  is $doc->inner_html, '<html><head></head><body></body></html>';

  $doc->inner_html ('hoge<P>foo<tr>aa');
  is $doc->inner_html, '<html><head></head><body>hoge<p>fooaa</p></body></html>';

  $doc->inner_html ('<!DOCTYPE HTML><title>ho<>&amp;ge');
  is $doc->inner_html, '<!DOCTYPE html><html><head><title>ho&lt;&gt;&amp;ge</title></head><body></body></html>';

  done $c;
} n => 5, name => 'doc.inner_html';

run_tests;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
