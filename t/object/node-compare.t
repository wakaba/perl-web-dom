use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;
use Web::DOM::Node;

test {
  my $c = shift;
  ok DOCUMENT_POSITION_DISCONNECTED;
  ok DOCUMENT_POSITION_PRECEDING;
  ok DOCUMENT_POSITION_FOLLOWING;
  ok DOCUMENT_POSITION_CONTAINS;
  ok DOCUMENT_POSITION_CONTAINED_BY;
  ok DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok +Web::DOM::Node->DOCUMENT_POSITION_DISCONNECTED;
  ok +Web::DOM::Node->DOCUMENT_POSITION_PRECEDING;
  ok +Web::DOM::Node->DOCUMENT_POSITION_FOLLOWING;
  ok +Web::DOM::Node->DOCUMENT_POSITION_CONTAINS;
  ok +Web::DOM::Node->DOCUMENT_POSITION_CONTAINED_BY;
  ok +Web::DOM::Node->DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  my $doc = Web::DOM::Document->new;
  ok $doc->DOCUMENT_POSITION_DISCONNECTED;
  ok $doc->DOCUMENT_POSITION_PRECEDING;
  ok $doc->DOCUMENT_POSITION_FOLLOWING;
  ok $doc->DOCUMENT_POSITION_CONTAINS;
  ok $doc->DOCUMENT_POSITION_CONTAINED_BY;
  ok $doc->DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  done $c;
} n => 18, name => 'constants';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');

  dies_here_ok {
    $node->compare_document_position (undef);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not a Node';
  
  done $c;
} n => 4, name => 'compare not node';

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;
  is $doc->compare_document_position ($doc), 0;

  my $node = $doc->create_element ('foo');
  is $node->compare_document_position ($node), 0;

  done $c;
} n => 2, name => 'compare same';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;

  my $result1 = $doc1->compare_document_position ($doc2);
  my $result2 = $doc2->compare_document_position ($doc1);

  ok $result1 & DOCUMENT_POSITION_DISCONNECTED;
  ok $result2 & DOCUMENT_POSITION_DISCONNECTED;
  ok $result1 & DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok $result2 & DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok $result1 & DOCUMENT_POSITION_PRECEDING
      || $result2 & DOCUMENT_POSITION_PRECEDING;
  ok $result1 & DOCUMENT_POSITION_FOLLOWING
      || $result2 & DOCUMENT_POSITION_FOLLOWING;
  ok $result1 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_PRECEDING) ||
     $result2 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_PRECEDING);
  ok $result1 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_FOLLOWING) ||
     $result2 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_FOLLOWING);
  isnt $result1, $result2;

  my $result3 = $doc1->compare_document_position ($doc2);
  my $result4 = $doc2->compare_document_position ($doc1);
  is $result1, $result3;
  is $result2, $result4;
  
  done $c;
} n => 11, name => 'compare different document';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $node1 = $doc1->create_element ('foo');
  my $node2 = $doc2->create_element ('bar');

  my $result1 = $node1->compare_document_position ($node2);
  my $result2 = $node2->compare_document_position ($node1);

  ok $result1 & DOCUMENT_POSITION_DISCONNECTED;
  ok $result2 & DOCUMENT_POSITION_DISCONNECTED;
  ok $result1 & DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok $result2 & DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok $result1 & DOCUMENT_POSITION_PRECEDING
      || $result2 & DOCUMENT_POSITION_PRECEDING;
  ok $result1 & DOCUMENT_POSITION_FOLLOWING
      || $result2 & DOCUMENT_POSITION_FOLLOWING;
  ok $result1 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_PRECEDING) ||
     $result2 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_PRECEDING);
  ok $result1 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_FOLLOWING) ||
     $result2 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_FOLLOWING);
  isnt $result1, $result2;

  my $result3 = $node1->compare_document_position ($node2);
  my $result4 = $node2->compare_document_position ($node1);
  is $result1, $result3;
  is $result2, $result4;
  
  done $c;
} n => 11, name => 'compare different document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('foo');
  my $node2 = $doc->create_element ('bar');

  my $result1 = $node1->compare_document_position ($node2);
  my $result2 = $node2->compare_document_position ($node1);

  ok $result1 & DOCUMENT_POSITION_DISCONNECTED;
  ok $result2 & DOCUMENT_POSITION_DISCONNECTED;
  ok $result1 & DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok $result2 & DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  ok $result1 & DOCUMENT_POSITION_PRECEDING
      || $result2 & DOCUMENT_POSITION_PRECEDING;
  ok $result1 & DOCUMENT_POSITION_FOLLOWING
      || $result2 & DOCUMENT_POSITION_FOLLOWING;
  ok $result1 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_PRECEDING) ||
     $result2 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_PRECEDING);
  ok $result1 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_FOLLOWING) ||
     $result2 ==
      (DOCUMENT_POSITION_DISCONNECTED |
       DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC |
       DOCUMENT_POSITION_FOLLOWING);
  isnt $result1, $result2;

  my $result3 = $node1->compare_document_position ($node2);
  my $result4 = $node2->compare_document_position ($node1);
  is $result1, $result3;
  is $result2, $result4;
  
  done $c;
} n => 11, name => 'compare different tree';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  $el1->append_child ($el2);

  my $result1 = $el1->compare_document_position ($el2);
  my $result2 = $el2->compare_document_position ($el1);
  
  is $result1, DOCUMENT_POSITION_CONTAINED_BY | DOCUMENT_POSITION_FOLLOWING;
  is $result2, DOCUMENT_POSITION_CONTAINS | DOCUMENT_POSITION_PRECEDING;

  done $c;
} n => 2, name => 'compare is parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  my $el3 = $doc->create_element ('b');
  $el1->append_child ($el2);
  $el2->append_child ($el3);

  my $result1 = $el1->compare_document_position ($el3);
  my $result2 = $el3->compare_document_position ($el1);
  
  is $result1, DOCUMENT_POSITION_CONTAINED_BY | DOCUMENT_POSITION_FOLLOWING;
  is $result2, DOCUMENT_POSITION_CONTAINS | DOCUMENT_POSITION_PRECEDING;

  done $c;
} n => 2, name => 'compare is ancestor';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $el3 = $doc->create_element ('a');
  my $el4 = $doc->create_element ('a');
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el1->append_child ($el4);

  is $el1->compare_document_position ($el2),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;
  is $el1->compare_document_position ($el3),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;
  is $el1->compare_document_position ($el4),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;
  is $el2->compare_document_position ($el3),
      DOCUMENT_POSITION_FOLLOWING;
  is $el2->compare_document_position ($el4),
      DOCUMENT_POSITION_FOLLOWING;
  is $el3->compare_document_position ($el2),
      DOCUMENT_POSITION_PRECEDING;
  is $el4->compare_document_position ($el2),
      DOCUMENT_POSITION_PRECEDING;
  is $el2->compare_document_position ($el1),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $el3->compare_document_position ($el1),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $el4->compare_document_position ($el1),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;

  done $c;
} n => 10, name => 'compare siblings';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $el3 = $doc->create_element ('a');
  my $el4 = $doc->create_element ('a');
  my $el5 = $doc->create_element ('a');
  $el1->append_child ($el2);
  $el1->append_child ($el3);
  $el2->append_child ($el4);
  $el3->append_child ($el5);

  is $el4->compare_document_position ($el5),
      DOCUMENT_POSITION_FOLLOWING;
  is $el5->compare_document_position ($el4),
      DOCUMENT_POSITION_PRECEDING;

  done $c;
} n => 2, name => 'compare sibling children';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  $el->set_attribute (hoge => 1);
  $el->set_attribute (fuga => 2);

  my $attr1 = $el->get_attribute_node ('hoge');
  my $attr2 = $el->get_attribute_node ('fuga');

  is $attr1->compare_document_position ($attr2),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  is $attr2->compare_document_position ($attr1),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
  is $attr1->compare_document_position ($el),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $el->compare_document_position ($attr1),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;

  done $c;
} n => 4, name => 'compare attrs of same element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  $el1->append_child ($el2);
  $el1->set_attribute (hoge => 1);
  $el2->set_attribute (fuga => 2);

  my $attr1 = $el1->get_attribute_node ('hoge');
  my $attr2 = $el2->get_attribute_node ('fuga');

  is $attr1->compare_document_position ($attr2),
      DOCUMENT_POSITION_FOLLOWING;
  is $attr2->compare_document_position ($attr1),
      DOCUMENT_POSITION_PRECEDING;
  is $attr2->compare_document_position ($el1),
      DOCUMENT_POSITION_PRECEDING | DOCUMENT_POSITION_CONTAINS;
  is $el1->compare_document_position ($attr2),
      DOCUMENT_POSITION_FOLLOWING | DOCUMENT_POSITION_CONTAINED_BY;
  is $attr1->compare_document_position ($el2),
      DOCUMENT_POSITION_FOLLOWING;
  is $el2->compare_document_position ($attr1),
      DOCUMENT_POSITION_PRECEDING;

  done $c;
} n => 6, name => 'compare attrs of parent element';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $el1 = $doc1->create_element ('a');
  my $el2 = $doc2->create_element ('a');

  ok not $el1->contains ($el2);
  ok not $el2->contains ($el1);

  done $c;
} n => 2, name => 'contains different document';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');

  ok not $el1->contains ($el2);
  ok not $el2->contains ($el1);

  done $c;
} n => 2, name => 'contains different tree';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');

  ok not $node->contains (undef);
  
  done $c;
} n => 1, name => 'contains undef';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  
  dies_here_ok {
    $node->contains ('hoge');
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'The argument is not a Node';
  
  done $c;
} n => 4, name => 'contains not node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  ok $el->contains ($el);

  done $c;
} n => 1, name => 'contains self';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  $el1->append_child ($el2);

  ok $el1->contains ($el2);
  ok not $el2->contains ($el1);

  done $c;
} n => 2, name => 'contains parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $el3 = $doc->create_element ('a');
  $el1->append_child ($el2);
  $el2->append_child ($el3);

  ok $el1->contains ($el3);
  ok not $el3->contains ($el1);

  done $c;
} n => 2, name => 'contains ancestor';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  $el2->set_attribute (hoge => 12);
  my $attr = $el2->get_attribute_node ('hoge');
  $el1->append_child ($el2);

  ok not $el1->contains ($attr);
  ok not $attr->contains ($el1);

  done $c;
} n => 2, name => 'contains attribute';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
