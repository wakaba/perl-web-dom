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
  $text->node_value ('fuga');
  is $text->node_value, 'fuga';
  is $text->data, 'fuga';
  $text->data ('abc');
  is $text->node_value, 'abc';
  is $text->data, 'abc';

  done $c;
} n => 16, name => 'create_text_node';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
