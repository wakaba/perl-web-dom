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
  my $node = $doc->create_general_entity ('hoge');
  is $node->node_type, $node->ENTITY_NODE;
  is $node->node_name, 'hoge';
  is $node->node_value, '';
  is $node->text_content, '';
  $node->node_value ('foo');
  is $node->node_value, 'foo';
  is $node->text_content, 'foo';
  $node->node_value ('bar');
  is $node->node_value, 'bar';
  is $node->text_content, 'bar';
  $node->node_value (undef);
  is $node->node_value, '';
  is $node->text_content, '';
  done $c;
} n => 10, name => 'basic node properties';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_general_entity ('hoge');
  
  $node->public_id ('hoge');
  is $node->public_id, 'hoge';
  
  $node->public_id ('hoge "');
  is $node->public_id, 'hoge "';
  
  $node->public_id (undef);
  is $node->public_id, '';

  done $c;
} n => 3, name => 'public_id setter';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_general_entity ('hoge');
  
  $node->system_id ('hoge');
  is $node->system_id, 'hoge';
  
  $node->system_id ('hoge "');
  is $node->system_id, 'hoge "';
  
  $node->system_id (undef);
  is $node->system_id, '';

  done $c;
} n => 3, name => 'system_id setter';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
