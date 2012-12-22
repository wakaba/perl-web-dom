use strict;
use warnings;
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
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  my $el3 = $doc->create_element ('c');
  
  $doc->append_child ($el1);
  $el1->append_child ($el2);
  $el2->append_child ($el3);

  is $el1->parent_node, $doc;
  is $el2->parent_node, $el1;
  is $el3->parent_node, $el2;

  is $doc->first_child, $el1;
  is $el1->first_child, $el2;

  done $c;
} n => 5;

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  my $el3 = $doc->create_element ('c');

  $el1->append_child ($el2);
  $el2->append_child ($el3);

  $el1->remove_child ($el2);
  undef $doc;
  undef $el1;

  is $el2->parent_node, undef;
  is $el3->parent_node, $el2;
  
  my $doc2 = $el3->owner_document;
  isa_ok $doc2, 'Web::DOM::Document';
  is $el2->owner_document, $doc2;

  is $doc2->first_child, undef;

  done $c;
} n => 5;

test {
  my $c = shift;
  
  my $doc = Web::DOM::Document->new;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  $doc->append_child ($el1);
  $el1->append_child ($el2);

  $doc->remove_child ($el1);
  undef $el1;
  
  is $doc->first_child, undef;
  ok $el2->parent_node;
  
  done $c;
} n => 2;

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  my $el3 = $doc->create_element ('c');

  $doc->append_child ($el1);
  $el1->append_child ($el2);
  $el2->append_child ($el3);

  $el1->remove_child ($el2);
  undef $doc;
  undef $el1;
  
  my $doc2 = $el3->owner_document;
  isa_ok $doc2, 'Web::DOM::Document';
  is $doc2, $el2->owner_document;

  done $c;
} n => 2;

test {
  my $c = shift;
  
  my $doc = new Web::DOM::Document;
  like $doc, qr{^Web::DOM::Document=};

  my $el = $doc->create_element ('foo');
  like $el, qr{^Web::DOM::Element=};

  my $doc_s = $doc . '';
  undef $doc;

  is $el->owner_document . '', $doc_s;

  my $el2 = $el->owner_document->create_element ('foo');
  isnt $el2 . '', $el . '';

  is $el . '', $el . '';

  is $el->owner_document . '', $el2->owner_document . '';

  done $c;
} name => 'stringification', n => 6;

test {
  my $c = shift;
  
  my $doc = new Web::DOM::Document;

  my $el1 = $doc->create_element ('foo');
  my $el2 = $doc->create_element ('foo');

  ok $el1;

  ok $el1 eq $el1;
  ok not $el1 ne $el1;
  ok not $el2 eq $el1;
  ok $el2 ne $el1;
  ok $el1 ne undef;
  ok not $el1 eq undef;
  is $el1 cmp $el1, 0;
  isnt $el1 cmp $el2, 0;

  isnt $el1 . '', $el1;

  # XXX test unitinialized warning by eq/ne/cmp-ing with undef
  
  done $c;
} name => 'eq', n => 10;

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;
  
  my $el1 = $doc->create_element ('e');
  my $el1_1 = $doc->create_element ('e');
  $el1->append_child ($el1_1);
  my $el1_2 = $doc->create_element ('e');
  $el1->append_child ($el1_2);
  undef $el1;

  my $el2 = $doc->create_element ('e');
  my $el2_1 = $doc->create_element ('e');
  $el2->append_child ($el2_1);
  undef $el2;

  my $el3 = $doc->create_element ('e');
  my $el3_1 = $doc->create_element ('e');
  $el3->append_child ($el3_1);
  undef $el3;

  my %found;
  my @node = grep { not $found{$_->parent_node}++ }
      $el1_1, $el1_2, $el2_1, $el3_1;

  is scalar @node, 3;
  is $node[0], $el1_1;
  is $node[1], $el2_1;
  is $node[2], $el3_1;

  done $c;
} name => 'stringified value invariance', n => 4;

{
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

test {
  my $c = shift;

  my $called;

  my $doc = new Web::DOM::Document;
  $doc->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');
  undef $doc;

  ok $called;

  done $c;
} name => 'destroy', n => 1;

test {
  my $c = shift;

  my $called;

  my $doc = new Web::DOM::Document;
  $doc->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');

  my $el1 = $doc->create_element ('aa');
  undef $doc;

  ok !$called;

  undef $el1;

  ok $called;

  done $c;
} name => 'destroy', n => 2;

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('a');
  my $el3 = $doc->create_element ('a');

  $doc->append_child ($el1);
  $el1->append_child ($el2);
  $el2->append_child ($el3);

  my $called;
  $el1->set_user_data (destroy => bless sub {
                         $called = 1;
                       }, 'test::DestroyCallback');

  undef $el1;
  ok !$called;

  undef $el2;
  ok !$called;
  
  $doc->remove_child ($doc->first_child);
  ok !$called;

  undef $el3;
  ok $called;
  
  done $c;
} name => 'destroy', n => 4;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element_ns ('http://hoge', 'foo');
  is $el->prefix, undef;

  $el->prefix ('abc');
  is $el->prefix, 'abc';

  $el->prefix ('');
  is $el->prefix, undef;

  $el->prefix ("aaa_BAAv\x{4000}");
  is $el->prefix, "aaa_BAAv\x{4000}";

  $el->prefix (undef);
  is $el->prefix, undef;

  done $c;
} n => 5, name => 'prefix namespaced element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_text_node ('a');
  dies_here_ok {
    $node->prefix ('abc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix can only be specified for namespaced node';
  is $node->prefix, undef;

  dies_here_ok {
    $node->prefix ('');
  };
  dies_here_ok {
    $node->prefix (undef);
  };

  done $c;
} n => 7, name => 'prefix not element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns (undef, 'a');
  dies_here_ok {
    $node->prefix ('abc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix can only be specified for namespaced node';
  is $node->prefix, undef;

  dies_here_ok {
    $node->prefix ('');
  };
  dies_here_ok {
    $node->prefix (undef);
  };

  done $c;
} n => 7, name => 'prefix not namespaced element';

for my $name (
  '1353', "\x00aa", "\x{FFFE}",
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;

    my $node = $doc->create_element_ns ('aaa', 'b:a');
    dies_here_ok {
      $node->prefix ($name);
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'InvalidCharacterError';
    is $@->message, 'The prefix is not an XML Name';
    is $node->prefix, 'b';
    done $c;
  } n => 5, name => ['prefix not name', $name];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('aaa', 'b:a');
  dies_here_ok {
    $node->prefix (':a2140');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The prefix is not an XML NCName';
  is $node->prefix, 'b';
  done $c;
} n => 5, name => 'prefix not ncname';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('h', 'hoge');
  is $node->prefix, undef;
  
  $node->prefix ('abc');
  is $node->prefix, 'abc';

  $node->prefix ('abc');
  is $node->prefix, 'abc';

  done $c;
} n => 3, name => 'prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $node = $doc->create_element_ns ('0', 'hoge');
  is $node->prefix, undef;
  
  $node->prefix ('abc');
  is $node->prefix, 'abc';

  $node->prefix ('abc');
  is $node->prefix, 'abc';

  done $c;
} n => 3, name => 'prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  is $doc->parent_node, undef;
  is $doc->parent_element, undef;

  done $c;
} n => 2, name => 'parent_node, parent_element no parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  is $el->parent_node, undef;
  is $el->parent_element, undef;

  done $c;
} n => 2, name => 'parent_node, parent_element no parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $doc->append_child ($el);

  is $el->parent_node, $doc;
  is $el->parent_element, undef;

  done $c;
} n => 2, name => 'parent_node, parent_element parent is doc';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  
  $el1->append_child ($el2);

  is $el2->parent_node, $el1;
  is $el2->parent_element, $el1;

  done $c;
} n => 2, name => 'parent_node, parent_element has element parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  ok not $el->has_child_nodes;
  
  done $c;
} n => 1, name => 'has_child_nodes empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  $el->append_child ($el2);
  ok $el->has_child_nodes;
  
  done $c;
} n => 1, name => 'has_child_nodes not empty';

{
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc,
    $doc->create_element ('a'),
    $doc->create_text_node ('b'),
    $doc->create_comment ('c'),
    $doc->create_processing_instruction ('d', 'e'),
    $doc->implementation->create_document_type ('f', '', ''),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;

      my $nl = $node->child_nodes;
      isa_ok $nl, 'Web::DOM::NodeList';
      is scalar @$nl, 0;
      
      done $c;
    } n => 2, name => ['child_nodes empty', $node->node_type];
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el = $doc->create_element ('a');
  is $el->first_child, undef;
  is $el->last_child, undef;

  done $c;
} n => 2, name => 'first_child/last_child no child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el = $doc->create_element ('a');
  my $el2 = $doc->create_text_node ('b');
  $el->append_child ($el2);

  is $el->first_child, $el2;
  is $el->last_child, $el2;

  done $c;
} n => 2, name => 'first_child/last_child only child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el = $doc->create_element ('a');
  my $el2 = $doc->create_text_node ('b');
  my $el3 = $doc->create_text_node ('b');
  $el->append_child ($el2);
  $el->append_child ($el3);

  is $el->first_child, $el2;
  is $el->last_child, $el3;

  done $c;
} n => 2, name => 'first_child/last_child two children';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el = $doc->create_element ('a');
  my $el2 = $doc->create_text_node ('b');
  my $el3 = $doc->create_text_node ('b');
  my $el4 = $doc->create_text_node ('b');
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el->append_child ($el4);

  is $el->first_child, $el2;
  is $el->last_child, $el4;

  done $c;
} n => 2, name => 'first_child/last_child three children';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  is $el->previous_sibling, undef;
  is $el->next_sibling, undef;
  
  done $c;
} n => 2, name => 'previous_sibling/next_sibling no parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  $el->append_child ($el2);

  is $el2->previous_sibling, undef;
  is $el2->next_sibling, undef;
  
  done $c;
} n => 2, name => 'previous_sibling/next_sibling only child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  my $el3 = $doc->create_element ('b');
  $el->append_child ($el2);
  $el->append_child ($el3);

  is $el2->previous_sibling, undef;
  is $el2->next_sibling, $el3;

  is $el3->previous_sibling, $el2;
  is $el3->next_sibling, undef;
  
  done $c;
} n => 4, name => 'previous_sibling/next_sibling one of two children';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  my $el3 = $doc->create_element ('b');
  my $el4 = $doc->create_element ('b');
  $el->append_child ($el2);
  $el->append_child ($el3);
  $el->append_child ($el4);

  is $el2->previous_sibling, undef;
  is $el2->next_sibling, $el3;

  is $el3->previous_sibling, $el2;
  is $el3->next_sibling, $el4;

  is $el4->previous_sibling, $el3;
  is $el4->next_sibling, undef;
  
  done $c;
} n => 6, name => 'previous_sibling/next_sibling one of three children';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->normalize;

  is $el->child_nodes->length, 0;
  done $c;
} n => 1, name => 'normalize empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('');
  $el->append_child ($text1);

  $el->normalize;

  is $el->child_nodes->length, 0;
  is $text1->parent_node, undef;

  is $text1->data, '';

  done $c;
} n => 3, name => 'normalize an empty text node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('bb');
  $el->append_child ($text1);

  $el->normalize;

  is $el->child_nodes->length, 1;
  is $el->first_child, $text1;
  is $text1->parent_node, $el;

  is $text1->data, 'bb';

  done $c;
} n => 4, name => 'normalize a text node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('bb');
  my $text2 = $doc->create_text_node ('cc');
  $el->append_child ($text1);
  $el->append_child ($text2);

  $el->normalize;

  is $el->child_nodes->length, 1;
  is $el->first_child, $text1;
  is $text1->parent_node, $el;
  is $text2->parent_node, undef;

  is $text1->data, 'bbcc';
  is $text2->data, 'cc';

  done $c;
} n => 6, name => 'normalize two text nodes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('bb');
  my $text2 = $doc->create_text_node ('cc1');
  my $text3 = $doc->create_text_node ('cc2');
  my $el1 = $doc->create_element ('foo');
  my $text4 = $doc->create_text_node ('cc3');
  my $text5 = $doc->create_text_node ('cc4');
  $el->append_child ($text1);
  $el->append_child ($text2);
  $el->append_child ($text3);
  $el->append_child ($el1);
  $el->append_child ($text4);
  $el->append_child ($text5);

  $el->normalize;

  is $el->child_nodes->length, 3;
  is $el->child_nodes->[0], $text1;
  is $el->child_nodes->[1], $el1;
  is $el->child_nodes->[2], $text4;
  is $text1->parent_node, $el;
  is $text2->parent_node, undef;
  is $text3->parent_node, undef;
  is $el1->parent_node, $el;
  is $text4->parent_node, $el;
  is $text5->parent_node, undef;

  is $text1->data, 'bbcc1cc2';
  is $text2->data, 'cc1';
  is $text3->data, 'cc2';
  is $text4->data, 'cc3cc4';
  is $text5->data, 'cc4';

  done $c;
} n => 15, name => 'normalize many nodes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('bb');
  my $text2 = $doc->create_text_node ('cc1');
  my $text3 = $doc->create_text_node ('cc2');
  my $el1 = $doc->create_element ('foo');
  my $text4 = $doc->create_text_node ('cc3');
  my $text5 = $doc->create_text_node ('cc4');
  my $text6 = $doc->create_text_node ('');
  $el->append_child ($text1);
  $el->append_child ($text2);
  $el->append_child ($text3);
  $el->append_child ($el1);
  $el1->append_child ($text4);
  $el1->append_child ($text5);
  $el->append_child ($text6);

  $el->normalize;

  is $el->child_nodes->length, 2;
  is $el->child_nodes->[0], $text1;
  is $el->child_nodes->[1], $el1;
  is $el1->child_nodes->length, 1;
  is $el1->child_nodes->[0], $text4;
  is $text1->parent_node, $el;
  is $text2->parent_node, undef;
  is $text3->parent_node, undef;
  is $el1->parent_node, $el;
  is $text4->parent_node, $el1;
  is $text5->parent_node, undef;
  is $text6->parent_node, undef;

  is $text1->data, 'bbcc1cc2';
  is $text2->data, 'cc1';
  is $text3->data, 'cc2';
  is $text4->data, 'cc3cc4';
  is $text5->data, 'cc4';
  is $text6->data, '';

  is $$el->[0]->{tree_id}->[$$el->[1]],
      $$text1->[0]->{tree_id}->[$$text1->[1]];
  is $$el->[0]->{tree_id}->[$$el->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];
  is $$el->[0]->{tree_id}->[$$el->[1]],
      $$text4->[0]->{tree_id}->[$$text4->[1]];
  isnt $$el->[0]->{tree_id}->[$$el->[1]],
      $$text2->[0]->{tree_id}->[$$text2->[1]];
  isnt $$el->[0]->{tree_id}->[$$el->[1]],
      $$text3->[0]->{tree_id}->[$$text3->[1]];
  isnt $$text2->[0]->{tree_id}->[$$text2->[1]],
      $$text3->[0]->{tree_id}->[$$text3->[1]];
  isnt $$el->[0]->{tree_id}->[$$el->[1]],
      $$text5->[0]->{tree_id}->[$$text5->[1]];
  isnt $$el->[0]->{tree_id}->[$$el->[1]],
      $$text6->[0]->{tree_id}->[$$text6->[1]];

  done $c;
} n => 26, name => 'normalize many nodes';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('bb');
  my $text2 = $doc->create_text_node ('cc');
  $el->append_child ($text1);
  $el->append_child ($text2);
  my $called;
  $text2->set_user_data (destroy => bless sub {
                           $called = 1;
                         }, 'test::DestroyCallback');
  undef $text2;

  $el->normalize;

  ok $called;
  done $c;
} n => 1, name => 'normalize two text nodes, destroy';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('');
  $el->append_child ($text1);
  my $called;
  $text1->set_user_data (destroy => bless sub {
                           $called = 1;
                         }, 'test::DestroyCallback');
  undef $text1;

  $el->normalize;

  ok $called;
  done $c;
} n => 1, name => 'normalize two text nodes, destroy';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('');
  my $text2 = $doc->create_text_node ('abc');
  $el->append_child ($text1);
  $el->append_child ($text2);

  $el->normalize;

  is $el->child_nodes->length, 1;
  is $el->first_child, $text2;
  is $text2->data, 'abc';

  is $text2->parent_node, $el;
  is $text1->parent_node, undef;

  done $c;
} n => 5, name => 'normalize empty - nonempty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $text1 = $doc->create_text_node ('');
  my $text2 = $doc->create_text_node ('');
  my $text3 = $doc->create_text_node ('');
  my $text4 = $doc->create_text_node ('abc');
  my $text5 = $doc->create_text_node ('');
  $el->append_child ($text1);
  $el->append_child ($text2);
  $el->append_child ($text3);
  $el->append_child ($text4);
  $el->append_child ($text5);

  $el->normalize;

  is $el->child_nodes->length, 1;
  is $el->first_child, $text4;
  is $text4->data, 'abc';
  is $text1->data, '';
  is $text2->data, '';
  is $text3->data, '';
  is $text5->data, '';

  is $text4->parent_node, $el;
  is $text1->parent_node, undef;
  is $text2->parent_node, undef;
  is $text3->parent_node, undef;
  is $text5->parent_node, undef;

  done $c;
} n => 12, name => 'normalize empty - nonempty';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
