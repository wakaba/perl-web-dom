use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

{
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  my $called;
  $node->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');

  my $nl = $node->attributes;
  isa_ok $nl, 'Web::DOM::NamedNodeMap';
  is scalar @$nl, 0;
  is $nl->length, 0;

  undef $node;
  ok not $called;

  undef $nl;
  ok $called;

  done $c;
} n => 5, name => 'attributes empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  $node->set_attribute (hoge => 1);
  $node->set_attribute (abc => 2);
  my $called;
  $node->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');

  my $nl = $node->attributes;
  isa_ok $nl, 'Web::DOM::NamedNodeMap';
  is scalar @$nl, 2;
  is $nl->length, 2;

  undef $node;
  ok not $called;

  undef $nl;
  ok $called;

  done $c;
} n => 5, name => 'attributes not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element ('a');

  my $nl = $node->attributes;
  my $nl2 = $node->attributes;
  
  is $nl2, $nl;

  my $node2 = $doc->create_element ('b');
  my $nl3 = $node2->attributes;

  isnt $nl3, $nl;

  $node->set_attribute_ns ('aa', 'bb', 'CC');

  is scalar @$nl, 1;
  is $nl->length, 1;
  
  done $c;
} n => 4, name => 'attributes liveness and sameness';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  my $node2 = $doc->create_text_node ('a');

  my $nl = $node->attributes;

  dies_here_ok {
    $nl->[0] = $node2;
  };
  ok not ref $@;
  like $@, qr{^Modification of a read-only value attempted};

  is scalar @$nl, 0;
  ok not $node->has_attributes;
  ok not $node2->parent_node;

  done $c;
} n => 6, name => 'attributes read-only';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');

  my $nl = $node->attributes;
  my $nl_s = $nl . '';
  undef $nl;

  my $nl2 = $node->attributes;
  my $nl2_s = $nl2 . '';
  
  ok $nl2_s eq $nl_s;
  ok not $nl2_s ne $nl_s;
  ok not $nl2 eq $nl_s;
  ok $nl2 ne $nl_s;
  ok not $nl2 eq undef;
  ok $nl2 ne undef;
  ok $nl2 eq $node->attributes;
  ok not $nl2 ne $node->attributes;
  is $nl2 cmp $node->attributes, 0;
  isnt $nl2 cmp $node->attributes, undef;

  my $nl3 = $doc->attributes;
  ok $nl3 ne $nl2;
  ok not $nl3 eq $nl2;

  ok $nl2;

  done $c;
} n => 13, name => 'attributes comparison';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element ('a');
  my $nl = $node->attributes;

  is $nl->length, 0;
  is scalar @$nl, 0;

  is $nl->item (0), undef;
  is $nl->item (1), undef;
  is $nl->item (2), undef;
  is $nl->item (0+"inf"), undef;
  is $nl->item (0+"-inf"), undef;
  is $nl->item (0+"nan"), undef;
  is $nl->item (+0**1), undef;
  is $nl->item (-0**1), undef;
  is $nl->item (-1), undef;
  is $nl->item (-3), undef;

  is $nl->[0], undef;
  is $nl->[1], undef;
  is $nl->[2], undef;
  is scalar $nl->[0+"inf"], undef;
  is scalar $nl->[0+"-inf"], undef;
  is scalar $nl->[0+"nan"], undef;
  is $nl->[+0**1], undef;
  is $nl->[-0**1], undef;
  is scalar $nl->[-1], undef;
  is scalar $nl->[-3], undef;

  done $c;
} n => 22, name => 'attributes items, empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element ('a');
  my $nl = $node->attributes;
  $node->set_attribute (fuga => 3);

  is $nl->length, 1;
  is scalar @$nl, 1;

  isa_ok $nl->item (0), 'Web::DOM::Attr';
  my $el = $nl->item (0);
  is $el->name, 'fuga';
  is $el->value, '3';

  is $nl->item (1), undef;
  is $nl->item (2), undef;
  is $nl->item (0+"inf"), $el;
  is $nl->item (0+"-inf"), $el;
  is $nl->item (0+"nan"), $el;
  is $nl->item (+0**1), $el;
  is $nl->item (-0**1), $el;
  is $nl->item (0.52), $el;
  is $nl->item (-0.52), $el;
  is $nl->item (1.42), undef;
  is $nl->item (-1.323), undef;
  is $nl->item (-1), undef;
  is $nl->item (-3), undef;

  is $nl->[0], $el;
  is $nl->[1], undef;
  is $nl->[2], undef;
  is scalar $nl->[0+"inf"], $el;
  is scalar $nl->[0+"-inf"], $el;
  is scalar $nl->[0+"nan"], $el;
  is $nl->[+0**1], $el;
  is $nl->[-0**1], $el;
  is $nl->[0.542], $el;
  is $nl->[1.444], undef;
  is scalar $nl->[-1], $el;
  is scalar $nl->[-3], undef;
  is scalar $nl->[-2**31], undef;
  ok exists $nl->[0];
  ok exists $nl->[0.55];
  ok exists $nl->[-1];
  ok not exists $nl->[-2];
  ok not exists $nl->[1];
  ok not exists $nl->[2**31];

  done $c;
} n => 37, name => 'attributes items, empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  my $nl = $node->attributes;

  my $array1 = $nl->to_a;
  is ref $array1, 'ARRAY';
  is_deeply $array1, [];
  push @$array1, 1;
  is_deeply $array1, [1];

  $array1 = $nl->as_list;
  is ref $array1, 'ARRAY';
  is_deeply $array1, [];
  push @$array1, 1;
  is_deeply $array1, [1];

  isnt $nl->to_a, $nl->to_a;
  isnt $nl->as_list, $nl->as_list;
  isnt $nl->to_a, $nl->as_list;

  my @array2 = $nl->to_list;
  is 0+@array2, 0;
  push @array2, 1;
  is 0+@array2, 1;
  
  is 0+@$nl, 0;

  done $c;
} n => 12, name => 'attributes perl binding empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  my $nl = $node->attributes;
  $node->set_attribute (zzz => 'aa');
  $node->set_attribute (ggg => 'fwa');

  my $array1 = $nl->to_a;
  is ref $array1, 'ARRAY';
  my $el1 = $array1->[0];
  my $el2 = $array1->[1];
  is_deeply $array1, [$el1, $el2];
  push @$array1, 2;
  is_deeply $array1, [$el1, $el2, 2];

  $array1 = $nl->as_list;
  is ref $array1, 'ARRAY';
  is_deeply $array1, [$el1, $el2];
  push @$array1, 2;
  is_deeply $array1, [$el1, $el2, 2];

  isnt $nl->to_a, $nl->to_a;
  isnt $nl->as_list, $nl->as_list;
  isnt $nl->to_a, $nl->as_list;

  my @array2 = $nl->to_list;
  is 0+@array2, 2;
  push @array2, 3;
  is 0+@array2, 3;
  is $array2[0], $el1;
  is $array2[1], $el2;
  
  is 0+@$nl, 2;

  done $c;
} n => 14, name => 'attributes perl binding not empty';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
