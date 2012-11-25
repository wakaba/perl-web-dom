use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;

  my $impl1 = $doc1->implementation;
  my $impl2 = $doc2->implementation;

  ok $impl1;
  like $impl1, qr{^Web::DOM::Implementation=};

  ok $impl1 eq $impl1;
  ok not $impl1 ne $impl1;
  ok not $impl2 eq $impl1;
  ok $impl2 ne $impl1;
  ok $impl1 ne undef;
  ok not $impl1 eq undef;
  is $impl1 cmp $impl1, 0;
  isnt $impl1 cmp $impl2, 0;

  # XXX test unitinialized warning by eq/ne/cmp-ing with undef
  
  done $c;
} name => 'eq', n => 10;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $dom1 = $doc->implementation;
  my $dom2 = $doc->implementation;

  is $dom1, $dom2;

  my $dom_s = $dom1 . '';

  undef $dom1;
  undef $dom2;

  is $doc->implementation . '', $dom_s;
  isnt $doc->implementation, $dom_s;

  done $c;
} n => 3;

test {
  my $c = shift;
  
  my $impl = Web::DOM::Implementation->new;
  isa_ok $impl, 'Web::DOM::Implementation';
  
  done $c;
} name => 'constructor', n => 1;

{
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

test {
  my $c = shift;

  my $invoked;
  my $doc = new Web::DOM::Document;
  $doc->set_user_data (destroy => bless sub {
                         $invoked = 1;
                       }, 'test::DestroyCallback');

  my $impl = $doc->implementation;

  undef $doc;
  ok !$invoked;

  undef $impl;
  ok $invoked;

  done $c;
} name => 'destroy', n => 2;

test {
  my $c = shift;

  my $impl = new Web::DOM::Implementation;
  my $doc = $impl->create_document;
  
  isa_ok $doc, 'Web::DOM::Document';
  isa_ok $doc, 'Web::DOM::XMLDocument';

  is $doc->node_type, $doc->DOCUMENT_NODE;
  is $doc->first_child, undef;

  is $doc->url, 'about:blank';
  is $doc->document_uri, $doc->url;
  is $doc->content_type, 'application/xml';
  is $doc->character_set, 'utf-8';
  is !!$doc->manakai_is_html, !!0;
  is $doc->compat_mode, 'CSS1Compat';
  is $doc->manakai_compat_mode, 'no quirks';

  done $c;
} name => 'create_document';

# XXX create_document arguments tests

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
