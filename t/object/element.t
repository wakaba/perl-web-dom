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

  done $c;
} name => 'basic', n => 3;

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
