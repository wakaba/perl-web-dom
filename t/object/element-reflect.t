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
  my $el = $doc->create_element_ns (undef, 'aA');

  my $list1 = $el->manakai_ids;
  is_deeply $list1, [];

  $el->set_attribute (id => 'foo');

  my $list2 = $el->manakai_ids;
  is_deeply $list2, ['foo'];

  $el->set_attribute_ns ('http://hoge/', 'id' => 'bar');

  my $list3 = $el->manakai_ids;
  is_deeply $list3, ['foo'];

  is_deeply $list1, [];
  isnt $list2, $list1;
  isnt $list3, $list1;

  done $c;
} n => 6, name => 'manakai_ids';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
