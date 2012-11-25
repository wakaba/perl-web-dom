use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Implementation;

test {
  my $c = shift;
  
  my $impl = Web::DOM::Implementation->new;
  my $doc = $impl->create_document;

  isa_ok $doc, 'Web::DOM::XMLDocument';
  isa_ok $doc, 'Web::DOM::Document';
  is $doc->node_type, $doc->DOCUMENT_NODE;

  done $c;
} name => 'basic', n => 3;

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
