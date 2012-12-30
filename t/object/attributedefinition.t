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
  done $c;
} n => 10, name => 'basic node properties';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
