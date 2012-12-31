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
  my $doc = new Web::DOM::Document;
  for my $node (
    $doc,
    $doc->implementation->create_document_type ('aa', '', ''),
    $doc->create_document_fragment,
    $doc->create_element ('f'),
    $doc->create_attribute ('aa'),
    $doc->create_text_node ('b'),
    $doc->create_comment ('c'),
    $doc->create_processing_instruction ('ddd', 'ee'),
  ) {
    test {
      my $c = shift;
      
      ok $node->is_equal_node ($node);
      ok $node->is_same_node ($node);

      done $c;
    } n => 2, name => [$node->node_type, 'is_equal_node/is_same_node empty same'];

    test {
      my $c = shift;
      
      ok not $node->is_equal_node (undef);
      ok not $node->is_same_node (undef);

      done $c;
    } n => 2, name => [$node->node_type, 'is_equal_node/is_same_node null'];

    test {
      my $c = shift;
      
      dies_here_ok {
        $node->is_equal_node ("hoge");
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->name, 'TypeError';
      is $@->message, 'The argument is not a Node';

      done $c;
    } n => 4, name => [$node->node_type, 'is_equal_node not node'];

    test {
      my $c = shift;
      
      dies_here_ok {
        $node->is_same_node ("hoge");
      };
      isa_ok $@, 'Web::DOM::TypeError';
      is $@->name, 'TypeError';
      is $@->message, 'The argument is not a Node';

      done $c;
    } n => 4, name => [$node->node_type, 'is_same_node not node'];

    test {
      my $c = shift;
      my $node2 = $doc->create_element ('ff');
      
      ok not $node->is_equal_node ($node2);
      ok not $node->is_same_node ($node2);

      done $c;
    } n => 2, name => [$node->node_type, 'is_equal_node/is_same_node different'];
  }
}

sub equal_test (%) {
  my %args = @_;
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    
    my $el1 = do { local $_; $args{1}->($doc); $_ };
    my $el2 = do { local $_; $args{2}->($doc); $_ };

    ok not $el1 eq $el2;
    ok not $el1->is_same_node ($el2);
    if ($args{equal}) {
      ok $el1->is_equal_node ($el2);
    } else {
      ok not $el1->is_equal_node ($el2);
    }

    done $c;
  } n => 3, name => ['is_equal_node', $args{name}];
} # equal_test

equal_test
    name => 'undef',
    1 => sub {
      $_ = $_[0]->create_element ('a');
    },
    2 => sub {
      $_ = undef;
    },
    equal => 0;

{
  my $doc = new Web::DOM::Document;
  for my $node1 (
    $doc,
    $doc->implementation->create_document_type ('aa', '', ''),
    $doc->create_document_fragment,
    $doc->create_element ('f'),
    $doc->create_attribute ('aa'),
    $doc->create_text_node ('b'),
    $doc->create_comment ('c'),
    $doc->create_processing_instruction ('ddd', 'ee'),
  ) {
    for my $node2 (
      $doc,
      $doc->implementation->create_document_type ('aa', '', ''),
      $doc->create_document_fragment,
      $doc->create_element ('f'),
      $doc->create_attribute ('aa'),
      $doc->create_text_node ('b'),
      $doc->create_comment ('c'),
      $doc->create_processing_instruction ('ddd', 'ee'),
    ) {
      next if $node1->node_type == $node2->node_type;
      equal_test
          name => ['different node type', $node1->node_type, $node2->node_type],
          1 => sub {
            $_ = $node1;
          },
          2 => sub {
            $_ = $node2;
          },
          equal => 0;
    }
  }
}

equal_test
    name => 'equal empty html elements',
    1 => sub {
      $_ = $_[0]->create_element ('a');
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
    },
    equal => 1;

equal_test
    name => 'non equal empty html elements',
    1 => sub {
      $_ = $_[0]->create_element ('a');
    },
    2 => sub {
      $_ = $_[0]->create_element ('b');
    },
    equal => 0;

equal_test
    name => 'with child elements',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->append_child ($_[0]->create_element ('b'));
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->append_child ($_[0]->create_element ('b'));
    },
    equal => 1;

equal_test
    name => 'with child element / empty element',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->append_child ($_[0]->create_element ('b'));
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
    },
    equal => 0;

equal_test
    name => 'empty element / with child element',
    1 => sub {
      $_ = $_[0]->create_element ('a');
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->append_child ($_[0]->create_element ('b'));
    },
    equal => 0;

equal_test
    name => 'null namespace',
    1 => sub {
      $_ = $_[0]->create_element_ns (undef, 'a');
    },
    2 => sub {
      $_ = $_[0]->create_element_ns (undef, 'a');
    },
    equal => 1;

equal_test
    name => 'different namespace',
    1 => sub {
      $_ = $_[0]->create_element_ns (undef, 'a');
    },
    2 => sub {
      $_ = $_[0]->create_element_ns ('hoge', 'a');
    },
    equal => 0;

equal_test
    name => 'different namespace',
    1 => sub {
      $_ = $_[0]->create_element_ns ('hoge', 'a');
    },
    2 => sub {
      $_ = $_[0]->create_element_ns (undef, 'a');
    },
    equal => 0;

equal_test
    name => 'different namespace',
    1 => sub {
      $_ = $_[0]->create_element_ns ('fuga', 'a');
    },
    2 => sub {
      $_ = $_[0]->create_element_ns ('hoge', 'a');
    },
    equal => 0;

equal_test
    name => 'different namespace prefix',
    1 => sub {
      $_ = $_[0]->create_element_ns ('fuga', 'a');
    },
    2 => sub {
      $_ = $_[0]->create_element_ns ('fuga', 'abc:a');
    },
    equal => 0;

equal_test
    name => 'different namespace prefix',
    1 => sub {
      $_ = $_[0]->create_element_ns ('fuga', 'abc:a');
    },
    2 => sub {
      $_ = $_[0]->create_element_ns ('fuga', 'a');
    },
    equal => 0;

equal_test
    name => 'different namespace prefix',
    1 => sub {
      $_ = $_[0]->create_element_ns ('fuga', 'aaa:a');
    },
    2 => sub {
      $_ = $_[0]->create_element_ns ('fuga', 'abc:a');
    },
    equal => 0;

equal_test
    name => 'with namespace prefix',
    1 => sub {
      $_ = $_[0]->create_element_ns ('fuga', 'abc:a');
    },
    2 => sub {
      $_ = $_[0]->create_element_ns ('fuga', 'abc:a');
    },
    equal => 1;

equal_test
    name => 'with/without attr',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns (undef, 'hoge' => 33);
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
    },
    equal => 0;

equal_test
    name => 'with/without attr',
    1 => sub {
      $_ = $_[0]->create_element ('a');
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns (undef, 'hoge' => 33);
    },
    equal => 0;

equal_test
    name => 'with null attr',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns (undef, 'hoge' => 33);
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns (undef, 'hoge' => 33);
    },
    equal => 1;

equal_test
    name => 'with null attr, different values',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns (undef, 'hoge' => 33);
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns (undef, 'hoge' => 34);
    },
    equal => 0;

equal_test
    name => 'with namespaced attr',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns ('aa', 'hoge' => 33);
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns ('aa', 'hoge' => 33);
    },
    equal => 1;

equal_test
    name => 'with namespaced attr, different prefix',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns ('aa', 'foo:hoge' => 33);
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns ('aa', 'hoge' => 33);
    },
    equal => 1;

equal_test
    name => 'with namespaced attr, different prefixes',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns ('aa', 'foo:hoge' => 33);
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns ('aa', 'bar:hoge' => 33);
    },
    equal => 1;

equal_test
    name => 'with namespaced attr',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns ('aa', 'foo:hoge' => 33);
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns ('aa', 'foo:hoge' => 33);
    },
    equal => 1;

equal_test
    name => 'with namespaced attr, different namespace',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns (undef, 'hoge' => 33);
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns ('aa', 'hoge' => 33);
    },
    equal => 0;

equal_test
    name => 'with namespaced attr',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns ('aa', 'hoge' => 33);
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns ('aa', 'hoge2' => 33);
    },
    equal => 0;

equal_test
    name => 'with namespaced attr',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns ('aa', 'bbbb' => 31);
      $_->set_attribute_ns (undef, 'bbbb' => "aa");
      $_->set_attribute_ns ('aa', 'hoge' => 33);
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->set_attribute_ns (undef, 'bbbb' => "aa");
      $_->set_attribute_ns ('aa', 'hoge' => 33);
      $_->set_attribute_ns ('aa', 'bbbb' => 31);
    },
    equal => 1;

equal_test
    name => 'document type, equal',
    1 => sub {
      $_ = $_[0]->implementation->create_document_type ('aaa', '', '');
    },
    2 => sub {
      $_ = $_[0]->implementation->create_document_type ('aaa', '', '');
    },
    equal => 1;

equal_test
    name => 'document type, different doctype name',
    1 => sub {
      $_ = $_[0]->implementation->create_document_type ('aaa', '', '');
    },
    2 => sub {
      $_ = $_[0]->implementation->create_document_type ('aaab', '', '');
    },
    equal => 0;

equal_test
    name => 'document type, different public',
    1 => sub {
      $_ = $_[0]->implementation->create_document_type ('aaa', 'bb', '');
    },
    2 => sub {
      $_ = $_[0]->implementation->create_document_type ('aaa', '', '');
    },
    equal => 0;

equal_test
    name => 'document type, different public',
    1 => sub {
      $_ = $_[0]->implementation->create_document_type ('aaa', '', '');
    },
    2 => sub {
      $_ = $_[0]->implementation->create_document_type ('aaa', 'b', '');
    },
    equal => 0;

equal_test
    name => 'document type, different system',
    1 => sub {
      $_ = $_[0]->implementation->create_document_type ('aaa', '', '0');
    },
    2 => sub {
      $_ = $_[0]->implementation->create_document_type ('aaa', '', '');
    },
    equal => 0;

equal_test
    name => 'document type, different system',
    1 => sub {
      $_ = $_[0]->implementation->create_document_type ('aaa', '', '');
    },
    2 => sub {
      $_ = $_[0]->implementation->create_document_type ('aaa', '', '11');
    },
    equal => 0;

equal_test
    name => 'equal pi',
    1 => sub {
      $_ = $_[0]->create_processing_instruction ('aa', 'b');
    },
    2 => sub {
      $_ = $_[0]->create_processing_instruction ('aa', 'b');
    },
    equal => 1;

equal_test
    name => 'pi different target',
    1 => sub {
      $_ = $_[0]->create_processing_instruction ('aa:b', 'b');
    },
    2 => sub {
      $_ = $_[0]->create_processing_instruction ('aa', 'b');
    },
    equal => 0;

equal_test
    name => 'pi different data',
    1 => sub {
      $_ = $_[0]->create_processing_instruction ('aa', '');
    },
    2 => sub {
      $_ = $_[0]->create_processing_instruction ('aa', 'b');
    },
    equal => 0;

equal_test
    name => 'equal text',
    1 => sub {
      $_ = $_[0]->create_text_node ('aa');
    },
    2 => sub {
      $_ = $_[0]->create_text_node ('aa');
    },
    equal => 1;

equal_test
    name => 'equal text',
    1 => sub {
      $_ = $_[0]->create_text_node ('');
    },
    2 => sub {
      $_ = $_[0]->create_text_node ('');
    },
    equal => 1;

equal_test
    name => 'not equal text',
    1 => sub {
      $_ = $_[0]->create_text_node ('aab');
    },
    2 => sub {
      $_ = $_[0]->create_text_node ('aa');
    },
    equal => 0;

equal_test
    name => 'equal comment',
    1 => sub {
      $_ = $_[0]->create_comment ('aa');
    },
    2 => sub {
      $_ = $_[0]->create_comment ('aa');
    },
    equal => 1;

equal_test
    name => 'not equal comment',
    1 => sub {
      $_ = $_[0]->create_comment ('');
    },
    2 => sub {
      $_ = $_[0]->create_comment ('aa');
    },
    equal => 0;

equal_test
    name => 'document fragment empty',
    1 => sub {
      $_ = $_[0]->create_document_fragment;
    },
    2 => sub {
      $_ = $_[0]->create_document_fragment;
    },
    equal => 1;

equal_test
    name => 'document fragment not empty',
    1 => sub {
      $_ = $_[0]->create_document_fragment;
      $_->append_child ($_[0]->create_element ('aa'));
    },
    2 => sub {
      $_ = $_[0]->create_document_fragment;
      $_->append_child ($_[0]->create_element ('aa'));
    },
    equal => 1;

equal_test
    name => 'document fragment not empty, empty',
    1 => sub {
      $_ = $_[0]->create_document_fragment;
      $_->append_child ($_[0]->create_element ('aa'));
    },
    2 => sub {
      $_ = $_[0]->create_document_fragment;
    },
    equal => 0;

equal_test
    name => 'empty documents',
    1 => sub {
      $_ = $_[0];
    },
    2 => sub {
      $_ = new Web::DOM::Document;
    },
    equal => 1;

equal_test
    name => 'non empty documents',
    1 => sub {
      $_ = $_[0];
      $_->append_child ($_->create_comment ('aa'));
    },
    2 => sub {
      $_ = new Web::DOM::Document;
      $_->append_child ($_->create_comment ('aa'));
    },
    equal => 1;

equal_test
    name => 'non empty documents',
    1 => sub {
      $_ = $_[0];
      $_->append_child ($_->create_comment ('aa'));
    },
    2 => sub {
      $_ = new Web::DOM::Document;
      $_->append_child ($_->create_comment ('aa'));
      $_->append_child ($_->create_comment ('aa'));
    },
    equal => 0;

equal_test
    name => 'different descendant',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->append_child ($_[0]->create_element ('aa'));
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->append_child ($_[0]->create_element ('aa'))
          ->set_attribute (hoge => 'a b');
    },
    equal => 0;

equal_test
    name => 'equal descendant',
    1 => sub {
      $_ = $_[0]->create_element ('a');
      $_->append_child ($_[0]->create_element ('aa'))
          ->append_child ($_[0]->create_element ('foo'))
          ->set_attribute (hoge => 'a b');
    },
    2 => sub {
      $_ = $_[0]->create_element ('a');
      $_->append_child ($_[0]->create_element ('aa'))
          ->append_child ($_[0]->create_element ('foo'))
          ->set_attribute (hoge => 'a b');
    },
    equal => 1;

equal_test
    name => 'equal attrs',
    1 => sub {
      $_ = $_[0]->create_attribute ('hoge');
    },
    2 => sub {
      $_ = $_[0]->create_attribute ('hoge');
    },
    equal => 1;

equal_test
    name => 'equal attrs',
    1 => sub {
      $_ = $_[0]->create_attribute ('hoge');
      $_->value ('ab');
    },
    2 => sub {
      $_ = $_[0]->create_attribute ('hoge');
      $_->value ('ab');
    },
    equal => 1;

equal_test
    name => 'attr different values',
    1 => sub {
      $_ = $_[0]->create_attribute ('hoge');
      $_->value ('ab');
    },
    2 => sub {
      $_ = $_[0]->create_attribute ('hoge');
      $_->value ('abc');
    },
    equal => 0;

equal_test
    name => 'equal namespaced attrs',
    1 => sub {
      $_ = $_[0]->create_attribute_ns ('aa', 'hoge');
      $_->value ('ab');
    },
    2 => sub {
      $_ = $_[0]->create_attribute_ns ('aa', 'hoge');
      $_->value ('ab');
    },
    equal => 1;

equal_test
    name => 'equal namespaced attrs, different prefixes',
    1 => sub {
      $_ = $_[0]->create_attribute_ns ('aa', 'ab:hoge');
      $_->value ('ab');
    },
    2 => sub {
      $_ = $_[0]->create_attribute_ns ('aa', 'cd:hoge');
      $_->value ('ab');
    },
    equal => 1;

equal_test
    name => 'equal namespaced attrs, different prefixes',
    1 => sub {
      $_ = $_[0]->create_attribute_ns ('aa', 'hoge');
      $_->value ('ab');
    },
    2 => sub {
      $_ = $_[0]->create_attribute_ns ('aa', 'cd:hoge');
      $_->value ('ab');
    },
    equal => 1;

equal_test
    name => 'equal namespaced attrs, different prefixes',
    1 => sub {
      $_ = $_[0]->create_attribute_ns ('aa', 'ab:hoge');
      $_->value ('ab');
    },
    2 => sub {
      $_ = $_[0]->create_attribute_ns ('aa', 'hoge');
      $_->value ('ab');
    },
    equal => 1;

equal_test
    name => 'attrs, different namespaces',
    1 => sub {
      $_ = $_[0]->create_attribute_ns ('aa', 'ab:hoge');
      $_->value ('ab');
    },
    2 => sub {
      $_ = $_[0]->create_attribute_ns ('aac', 'cd:hoge');
      $_->value ('ab');
    },
    equal => 0;

equal_test
    name => 'attrs, different namespaces',
    1 => sub {
      $_ = $_[0]->create_attribute_ns (undef, 'hoge');
      $_->value ('ab');
    },
    2 => sub {
      $_ = $_[0]->create_attribute_ns ('aac', 'hoge');
      $_->value ('ab');
    },
    equal => 0;

equal_test
    name => 'attrs, different namespaces',
    1 => sub {
      $_ = $_[0]->create_attribute_ns ('gew', 'hoge');
      $_->value ('ab');
    },
    2 => sub {
      $_ = $_[0]->create_attribute_ns (undef, 'hoge');
      $_->value ('ab');
    },
    equal => 0;

equal_test
    name => 'attrs, different local names',
    1 => sub {
      $_ = $_[0]->create_attribute_ns ('aa', 'hoge1');
    },
    2 => sub {
      $_ = $_[0]->create_attribute_ns ('aa', 'hoge');
    },
    equal => 0;

equal_test
    name => 'doctype with and without notation',
    1 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
      $_->set_notation_node ($_[0]->create_notation ('foo'));
    },
    2 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
    },
    equal => 0;

equal_test
    name => 'doctype with notation',
    1 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
      $_->set_notation_node ($_[0]->create_notation ('foo'));
    },
    2 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
      $_->set_notation_node ($_[0]->create_notation ('foo'));
    },
    equal => 1;

equal_test
    name => 'doctype with notations',
    1 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
      $_->set_notation_node ($_[0]->create_notation ('bar'));
      $_->set_notation_node ($_[0]->create_notation ('foo'));
    },
    2 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
      $_->set_notation_node ($_[0]->create_notation ('foo'));
      $_->set_notation_node ($_[0]->create_notation ('bar'));
    },
    equal => 1;

equal_test
    name => 'doctype with notations, entities, element types',
    1 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
      $_->set_notation_node ($_[0]->create_notation ('bar'));
      $_->set_general_entity_node ($_[0]->create_general_entity ('foo'));
      $_->set_element_type_definition_node
          ($_[0]->create_element_type_definition ('bar'));
    },
    2 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
      $_->set_notation_node ($_[0]->create_notation ('bar'));
      $_->set_general_entity_node ($_[0]->create_general_entity ('foo'));
      $_->set_element_type_definition_node
          ($_[0]->create_element_type_definition ('bar'));
    },
    equal => 1;

equal_test
    name => 'doctype with notations, entities, element types',
    1 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
      $_->set_notation_node ($_[0]->create_notation ('bar'));
      $_->set_element_type_definition_node
          ($_[0]->create_element_type_definition ('bar'));
    },
    2 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
      $_->set_notation_node ($_[0]->create_notation ('bar'));
      $_->set_general_entity_node ($_[0]->create_general_entity ('foo'));
      $_->set_element_type_definition_node
          ($_[0]->create_element_type_definition ('bar'));
    },
    equal => 0;

equal_test
    name => 'doctype with different notations',
    1 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
      $_->set_notation_node ($_[0]->create_notation ('foo'));
    },
    2 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
      $_->set_notation_node ($_[0]->create_notation ('FOO'));
    },
    equal => 0;

equal_test
    name => 'doctype with notation and entity',
    1 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
      $_->set_notation_node ($_[0]->create_notation ('foo'));
    },
    2 => sub {
      $_ = $_[0]->create_document_type_definition ('hoge');
      $_->set_general_entity_node ($_[0]->create_general_entity ('foo'));
    },
    equal => 0;

equal_test
    name => 'entities',
    1 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
    },
    2 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
    },
    equal => 1;

equal_test
    name => 'entities',
    1 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
    },
    2 => sub {
      $_ = $_[0]->create_general_entity ('fuga');
    },
    equal => 0;

equal_test
    name => 'entities',
    1 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
    },
    2 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->public_id ('hoge');
    },
    equal => 0;

equal_test
    name => 'entities',
    1 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->public_id ('abc');
    },
    2 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->public_id ('abc');
    },
    equal => 1;

equal_test
    name => 'entities',
    1 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->system_id ('abc');
    },
    2 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->system_id ('abc');
    },
    equal => 1;

equal_test
    name => 'entities',
    1 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->notation_name ('abc');
    },
    2 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->public_id ('abc');
    },
    equal => 0;

equal_test
    name => 'entities',
    1 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->notation_name ('abc');
    },
    2 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->notation_name ('abc');
    },
    equal => 1;

equal_test
    name => 'entities',
    1 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->notation_name ('abc');
    },
    2 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->notation_name ('');
    },
    equal => 0;

equal_test
    name => 'entities',
    1 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->notation_name (undef);
    },
    2 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->notation_name ('');
    },
    equal => 0;

equal_test
    name => 'entities',
    1 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->node_value ('abc');
    },
    2 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->node_value ('');
    },
    equal => 0;

equal_test
    name => 'entities',
    1 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->node_value ('abc');
    },
    2 => sub {
      $_ = $_[0]->create_general_entity ('hoge');
      $_->node_value ('abc');
    },
    equal => 1;

equal_test
    name => 'notations',
    1 => sub {
      $_ = $_[0]->create_notation ('hoge');
    },
    2 => sub {
      $_ = $_[0]->create_notation ('hoge');
    },
    equal => 1;

equal_test
    name => 'notations',
    1 => sub {
      $_ = $_[0]->create_notation ('hoge');
    },
    2 => sub {
      $_ = $_[0]->create_notation ('hoge2');
    },
    equal => 0;

equal_test
    name => 'notations',
    1 => sub {
      $_ = $_[0]->create_notation ('hoge');
      $_->public_id ('hoge');
    },
    2 => sub {
      $_ = $_[0]->create_notation ('hoge');
      $_->public_id ('hoge');
    },
    equal => 1;

equal_test
    name => 'notations',
    1 => sub {
      $_ = $_[0]->create_notation ('hoge');
    },
    2 => sub {
      $_ = $_[0]->create_notation ('hoge');
      $_->public_id ('hoge');
    },
    equal => 0;

equal_test
    name => 'notations',
    1 => sub {
      $_ = $_[0]->create_notation ('hoge');
      $_->system_id ('hoge');
    },
    2 => sub {
      $_ = $_[0]->create_notation ('hoge');
      $_->system_id ('hoge');
    },
    equal => 1;

equal_test
    name => 'notations',
    1 => sub {
      $_ = $_[0]->create_notation ('hoge');
    },
    2 => sub {
      $_ = $_[0]->create_notation ('hoge');
      $_->system_id ('hoge');
    },
    equal => 0;

equal_test
    name => 'element types',
    1 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
    },
    2 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
    },
    equal => 1;

equal_test
    name => 'element types',
    1 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
    },
    2 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge2');
    },
    equal => 0;

equal_test
    name => 'element types',
    1 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      $_->set_attribute_definition_node
          ($_[0]->create_attribute_definition ('abc'));
    },
    2 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
    },
    equal => 0;

equal_test
    name => 'element types',
    1 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      $_->set_attribute_definition_node
          ($_[0]->create_attribute_definition ('abc'));
    },
    2 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      $_->set_attribute_definition_node
          ($_[0]->create_attribute_definition ('abc'));
    },
    equal => 1;

equal_test
    name => 'element types',
    1 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      $_->set_attribute_definition_node
          ($_[0]->create_attribute_definition ('abc'));
      $_->set_attribute_definition_node
          ($_[0]->create_attribute_definition ('def'));
    },
    2 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      $_->set_attribute_definition_node
          ($_[0]->create_attribute_definition ('def'));
      $_->set_attribute_definition_node
          ($_[0]->create_attribute_definition ('abc'));
    },
    equal => 1;

equal_test
    name => 'element types',
    1 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      $_->set_attribute_definition_node
          ($_[0]->create_attribute_definition ('abc'));
      $_->set_attribute_definition_node
          ($_[0]->create_attribute_definition ('def'));
    },
    2 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      $_->set_attribute_definition_node
          ($_[0]->create_attribute_definition ('def'));
    },
    equal => 0;

equal_test
    name => 'element types',
    1 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      $_->set_attribute_definition_node
          ($_[0]->create_attribute_definition ('abc'));
    },
    2 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      my $adef = $_[0]->create_attribute_definition ('abc');
      $_->set_attribute_definition_node ($adef);
      $adef->node_value ('hoge');
    },
    equal => 0;

equal_test
    name => 'element types',
    1 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      my $adef = $_[0]->create_attribute_definition ('abc');
      $_->set_attribute_definition_node ($adef);
      $adef->node_value ('hoge');
    },
    2 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      my $adef = $_[0]->create_attribute_definition ('abc');
      $_->set_attribute_definition_node ($adef);
      $adef->node_value ('hoge');
    },
    equal => 1;

equal_test
    name => 'element types',
    1 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      my $adef = $_[0]->create_attribute_definition ('abc');
      $_->set_attribute_definition_node ($adef);
      $adef->declared_type (5);
    },
    2 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      my $adef = $_[0]->create_attribute_definition ('abc');
      $_->set_attribute_definition_node ($adef);
      $adef->declared_type (5);
    },
    equal => 1;

equal_test
    name => 'element types',
    1 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      my $adef = $_[0]->create_attribute_definition ('abc');
      $_->set_attribute_definition_node ($adef);
      $adef->declared_type (3);
    },
    2 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      my $adef = $_[0]->create_attribute_definition ('abc');
      $_->set_attribute_definition_node ($adef);
      $adef->declared_type (5);
    },
    equal => 0;

equal_test
    name => 'element types',
    1 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      my $adef = $_[0]->create_attribute_definition ('abc');
      $_->set_attribute_definition_node ($adef);
      $adef->default_type (5);
    },
    2 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      my $adef = $_[0]->create_attribute_definition ('abc');
      $_->set_attribute_definition_node ($adef);
      $adef->default_type (5);
    },
    equal => 1;

equal_test
    name => 'element types',
    1 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      my $adef = $_[0]->create_attribute_definition ('abc');
      $_->set_attribute_definition_node ($adef);
      $adef->default_type (3);
    },
    2 => sub {
      $_ = $_[0]->create_element_type_definition ('hoge');
      my $adef = $_[0]->create_attribute_definition ('abc');
      $_->set_attribute_definition_node ($adef);
      $adef->default_type (5);
    },
    equal => 0;

equal_test
    name => 'attribute definitions',
    1 => sub {
      $_ = $_[0]->create_attribute_definition ('abc');
      push @{$_->allowed_tokens}, 'hoge', 'fuga';
    },
    2 => sub {
      $_ = $_[0]->create_attribute_definition ('abc');
      push @{$_->allowed_tokens}, 'fuga', 'hoge';
    },
    equal => 1;

equal_test
    name => 'attribute definitions',
    1 => sub {
      $_ = $_[0]->create_attribute_definition ('abc');
      push @{$_->allowed_tokens}, 'hoge', 'fuga';
    },
    2 => sub {
      $_ = $_[0]->create_attribute_definition ('abc');
      push @{$_->allowed_tokens}, 'fuga', 'hoge', 'hoge';
    },
    equal => 0;

equal_test
    name => 'attribute definitions',
    1 => sub {
      $_ = $_[0]->create_attribute_definition ('abc');
      push @{$_->allowed_tokens}, 'hoge', 'fuga', 'hoge';
    },
    2 => sub {
      $_ = $_[0]->create_attribute_definition ('abc');
      push @{$_->allowed_tokens}, 'fuga', 'hoge';
    },
    equal => 0;

equal_test
    name => 'attribute definitions',
    1 => sub {
      $_ = $_[0]->create_attribute_definition ('abc');
      push @{$_->allowed_tokens}, '120';
    },
    2 => sub {
      $_ = $_[0]->create_attribute_definition ('abc');
      push @{$_->allowed_tokens}, '120', '';
    },
    equal => 0;

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
