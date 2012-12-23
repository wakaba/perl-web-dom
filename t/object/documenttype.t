use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type ('hoge', '', '');
  isa_ok $dt, 'Web::DOM::DocumentType';
  isa_ok $dt, 'Web::DOM::Node';
  
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->node_name, 'hoge';
  is $dt->name, 'hoge';
  is $dt->public_id, '';
  is $dt->system_id, '';

  is $dt->namespace_uri, undef;
  is $dt->prefix, undef;
  is $dt->manakai_local_name, undef;
  is $dt->local_name, undef;
  is $dt->first_child, undef;

  is $dt->node_value, undef;
  is $dt->text_content, undef;

  $dt->node_value ('hoge');
  is $dt->node_value, undef;
  is $dt->text_content, undef;

  $dt->text_content ('hoge');
  is $dt->node_value, undef;
  is $dt->text_content, undef;

  done $c;
} n => 18, name => 'document type attributes - empty ids';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dt = $doc->implementation->create_document_type
      ('hoge', 'ho "\'ge', 'fu\'"ga');
  isa_ok $dt, 'Web::DOM::DocumentType';
  isa_ok $dt, 'Web::DOM::Node';
  
  is $dt->node_type, $dt->DOCUMENT_TYPE_NODE;
  is $dt->node_name, 'hoge';
  is $dt->name, 'hoge';
  is $dt->public_id, q{ho "'ge};
  is $dt->system_id, q{fu'"ga};

  is $dt->first_child, undef;

  done $c;
} n => 8, name => 'document type attributes';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
