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
  my $df = $doc->create_document_fragment;
  isa_ok $df, 'Web::DOM::DocumentFragment';
  isa_ok $df, 'Web::DOM::Node';

  is $df->node_type, $df->DOCUMENT_FRAGMENT_NODE;
  is $df->node_name, '#document-fragment';
  is $df->parent_node, undef;

  is $df->namespace_uri, undef;
  is $df->prefix, undef;
  is $df->manakai_local_name, undef;
  is $df->local_name, undef;

  is $df->node_value, undef;
  $df->node_value ('hoge');
  is $df->node_value, undef;

  done $c;
} n => 11, name => 'create_document_gragment';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
