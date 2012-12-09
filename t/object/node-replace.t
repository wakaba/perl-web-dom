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
  my $node = $doc->create_element ('a');

  dies_here_ok {
    $node->replace_child (undef);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The first argument is not a Node';

  is scalar @{$node->child_nodes}, 0;
  
  done $c;
} n => 4, name => 'replace_child typeerror';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('a');
  my $node2 = $doc->create_element ('b');

  dies_here_ok {
    $node->replace_child ($node2, undef);
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->message, 'The second argument is not a Node';

  is scalar @{$node->child_nodes}, 0;
  
  done $c;
} n => 4, name => 'replace_child typeerror';

{
  my $doc = new Web::DOM::Document;
  for my $parent (
    $doc->create_text_node ('a'),
    $doc->create_comment ('b'),
    $doc->create_processing_instruction ('c'),
    $doc->implementation->create_document_type ('a', '', ''),
  ) {
    test {
      my $c = shift;
      my $node = $doc->create_element ('a');
      my $child = $doc->create_element ('a');
      dies_here_ok {
        $parent->replace_child ($child, $node);
      };
      isa_ok $@, 'Web::DOM::Exception';
      is $@->message, 'The parent node cannot have a child';
      is scalar @{$parent->child_nodes}, 0;
      is $child->parent_node, undef;
      is $node->parent_node, undef;
      done $c;
    } n => 6, name => [$parent->node_type, 'wrong parent'];
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_text_node ('');
  my $node2 = $doc->create_element ('a');
  $doc->append_child ($node2);
  dies_here_ok {
    $doc->replace_child ($node1, $node2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot contain this kind of node';
  is scalar @{$doc->child_nodes}, 1;
  is $doc->first_child, $node2;
  is $node1->parent_node, undef;
  done $c;
  undef $c;
} n => 7, name => 'replace_child doc>text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $parent = $doc->create_element ('b');
  my $node1 = $doc->implementation->create_document_type ('f', '', '');
  my $node2 = $doc->create_element ('a');
  $parent->append_child ($node2);
  dies_here_ok {
    $parent->replace_child ($node1, $node2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document type cannot be contained by this kind of node';
  is scalar @{$parent->child_nodes}, 1;
  is $parent->first_child, $node2;
  is $node1->parent_node, undef;
  done $c;
  undef $c;
} n => 7, name => 'replace_child nondoc>dt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_processing_instruction ('a', 'b');
  $doc->append_child ($node);
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  $df->append_child ($el1);
  $df->append_child ($el2);
  dies_here_ok {
    $doc->replace_child ($df, $node);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot have two element children';
  is scalar @{$doc->child_nodes}, 1;
  is $node->parent_node, $doc;
  is scalar @{$df->child_nodes}, 2;
  is $el1->parent_node, $df;
  is $el2->parent_node, $df;
  done $c;
} n => 9, name => 'doc > df > two elements';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_comment ('a');
  $doc->append_child ($node);
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_text_node ('b');
  $df->append_child ($el1);
  $df->append_child ($el2);
  dies_here_ok {
    $doc->replace_child ($df, $node);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot contain this kind of node';
  is scalar @{$doc->child_nodes}, 1;
  is $node->parent_node, $doc;
  is scalar @{$df->child_nodes}, 2;
  is $el1->parent_node, $df;
  is $el2->parent_node, $df;
  done $c;
} n => 9, name => 'doc > df > text';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_comment ('c');
  $doc->append_child ($node);
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  $doc->append_child ($el1);
  $df->append_child ($el2);
  dies_here_ok {
    $doc->replace_child ($df, $node);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot have two element children';
  is scalar @{$doc->child_nodes}, 2;
  is scalar @{$df->child_nodes}, 1;
  is $node->parent_node, $doc;
  is $el1->parent_node, $doc;
  is $el2->parent_node, $df;
  done $c;
} n => 9, name => 'doc > el + doc > df > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('b');
  $doc->append_child ($el1);
  $df->append_child ($el2);
  $doc->replace_child ($df, $el1);
  is scalar @{$doc->child_nodes}, 1;
  is scalar @{$df->child_nodes}, 0;
  is $el1->parent_node, undef;
  is $el2->parent_node, $doc;
  done $c;
} n => 4, name => 'doc > el replaced by df > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_comment ('a');
  my $el2 = $doc->create_element ('b');
  my $dt = $doc->implementation->create_document_type ('a', '', '');
  $doc->append_child ($el1);
  $doc->append_child ($dt);
  $df->append_child ($el2);
  dies_here_ok {
    $doc->replace_child ($df, $el1);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Element cannot precede the document type';
  is scalar @{$doc->child_nodes}, 2;
  is scalar @{$df->child_nodes}, 1;
  is $el1->parent_node, $doc;
  is $dt->parent_node, $doc;
  is $el2->parent_node, $df;
  done $c;
} n => 9, name => 'doc > node~dt + doc > df > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_comment ('a');
  my $el2 = $doc->create_element ('b');
  my $dt = $doc->implementation->create_document_type ('a', '', '');
  $doc->append_child ($dt);
  $doc->append_child ($el1);
  $df->append_child ($el2);
  $doc->replace_child ($df, $el1);
  is scalar @{$doc->child_nodes}, 2;
  is scalar @{$df->child_nodes}, 0;
  is $el1->parent_node, undef;
  is $dt->parent_node, $doc;
  is $el2->parent_node, $doc;
  done $c;
} n => 5, name => 'doc > dt~node + doc > df > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_comment ('a');
  my $el2 = $doc->create_element ('b');
  my $dt = $doc->implementation->create_document_type ('a', '', '');
  $doc->append_child ($dt);
  $doc->append_child ($el1);
  $df->append_child ($el2);
  $doc->replace_child ($df, $dt);
  is scalar @{$doc->child_nodes}, 2;
  is scalar @{$df->child_nodes}, 0;
  is $el1->parent_node, $doc;
  is $dt->parent_node, undef;
  is $el2->parent_node, $doc;
  done $c;
} n => 5, name => 'doc > dt~node + doc > df > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->create_element ('b');
  my $dc2 = $doc->create_comment ('c');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->create_element ('a');
  dies_here_ok {
    $doc->replace_child ($node, $dc2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot have two element children';
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, $doc;
  is $dc2->parent_node, $doc;
  is $node->parent_node, undef;
  done $c;
} n => 8, name => 'doc > el + el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->create_element ('b');
  my $dc2 = $doc->create_comment ('c');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->create_element ('a');
  $doc->replace_child ($node, $dc1);
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, undef;
  is $dc2->parent_node, $doc;
  is $node->parent_node, $doc;
  done $c;
} n => 4, name => 'doc > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->create_comment ('b');
  my $dc2 = $doc->create_comment ('c');
  my $dc3 = $doc->implementation->create_document_type ('f', '', '');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  $doc->append_child ($dc3);
  my $node = $doc->create_element ('a');
  dies_here_ok {
    $doc->replace_child ($node, $dc2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Element cannot precede the document type';
  is scalar @{$doc->child_nodes}, 3;
  is $dc1->parent_node, $doc;
  is $dc2->parent_node, $doc;
  is $dc3->parent_node, $doc;
  is $node->parent_node, undef;
  done $c;
} n => 9, name => 'doc > el + dt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->implementation->create_document_type ('b', '', '');
  my $dc2 = $doc->create_comment ('c');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->create_element ('a');
  $doc->replace_child ($node, $dc2);
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, $doc;
  is $dc2->parent_node, undef;
  is $node->parent_node, $doc;
  done $c;
} n => 4, name => 'doc > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->create_comment ('c');
  my $dc2 = $doc->implementation->create_document_type ('b', '', '');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->create_element ('a');
  $doc->replace_child ($node, $dc2);
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, $doc;
  is $dc2->parent_node, undef;
  is $node->parent_node, $doc;
  done $c;
} n => 4, name => 'doc > el';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->implementation->create_document_type ('b', '', '');
  my $dc2 = $doc->create_comment ('c');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->implementation->create_document_type ('a', '', '');
  dies_here_ok {
    $doc->replace_child ($node, $dc2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Document node cannot have two doctype children';
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, $doc;
  is $dc2->parent_node, $doc;
  is $node->parent_node, undef;
  done $c;
} n => 8, name => 'doc > dt + dt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->implementation->create_document_type ('b', '', '');
  my $dc2 = $doc->create_comment ('c');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->implementation->create_document_type ('a', '', '');
  $doc->replace_child ($node, $dc1);
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, undef;
  is $dc2->parent_node, $doc;
  is $node->parent_node, $doc;
  done $c;
} n => 4, name => 'doc > dt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->create_element ('c');
  my $dc2 = $doc->create_comment ('');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->implementation->create_document_type ('a', '', '');
  dies_here_ok {
    $doc->replace_child ($node, $dc2);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'Element cannot precede the document type';
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, $doc;
  is $dc2->parent_node, $doc;
  is $node->parent_node, undef;
  done $c;
} n => 8, name => 'doc > dt + dt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $dc1 = $doc->create_comment ('c');
  my $dc2 = $doc->create_element ('f');
  $doc->append_child ($dc1);
  $doc->append_child ($dc2);
  my $node = $doc->implementation->create_document_type ('a', '', '');
  $doc->replace_child ($node, $dc1);
  is scalar @{$doc->child_nodes}, 2;
  is $dc1->parent_node, undef;
  is $dc2->parent_node, $doc;
  is $node->parent_node, $doc;
  done $c;
} n => 4, name => 'doc > dt';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('A');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('c');
  $node->append_child ($el1);
  
  $node->replace_child ($el2, $el1);

  is scalar @{$node->child_nodes}, 1;
  is $el1->parent_node, undef;
  is $el2->parent_node, $node;

  is $$node->[0]->{tree_id}->[$$node->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  isnt $$node->[0]->{tree_id}->[$$node->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 5, name => 'replace only child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('A');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('c');
  my $el3 = $doc->create_element ('c');
  $node->append_child ($el1);
  $node->append_child ($el2);
  
  $node->replace_child ($el3, $el1);

  is scalar @{$node->child_nodes}, 2;
  is $el1->parent_node, undef;
  is $el2->parent_node, $node;
  is $el3->parent_node, $node;
  is $node->first_child, $el3;
  is $node->last_child, $el2;

  is $$node->[0]->{tree_id}->[$$node->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  is $$node->[0]->{tree_id}->[$$node->[1]],
      $$el3->[0]->{tree_id}->[$$el3->[1]];
  isnt $$node->[0]->{tree_id}->[$$node->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 9, name => 'replace a child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node = $doc->create_element ('A');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('c');
  my $el3 = $doc->create_element ('c');
  $node->append_child ($el1);
  $node->append_child ($el2);
  
  $node->replace_child ($el3, $el2);

  is scalar @{$node->child_nodes}, 2;
  is $el1->parent_node, $node;
  is $el2->parent_node, undef;
  is $el3->parent_node, $node;
  is $node->first_child, $el1;
  is $node->last_child, $el3;

  is $$node->[0]->{tree_id}->[$$node->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];
  is $$node->[0]->{tree_id}->[$$node->[1]],
      $$el3->[0]->{tree_id}->[$$el3->[1]];
  isnt $$node->[0]->{tree_id}->[$$node->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];

  done $c;
} n => 9, name => 'replace a child';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $node2 = $doc->create_element ('b');
  my $el1 = $doc->create_element ('c');
  my $el2 = $doc->create_element ('d');
  $node1->append_child ($el1);
  $node2->append_child ($el2);

  $node1->replace_child ($el2, $el1);

  is scalar @{$node1->child_nodes}, 1;
  is scalar @{$node2->child_nodes}, 0;

  is $node1->first_child, $el2;
  is $el1->parent_node, undef;
  is $el2->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];
  isnt $$node2->[0]->{tree_id}->[$$node2->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];

  done $c;
} n => 8, name => 'replace - node moved';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $el1 = $doc->create_element ('f');
  my $el2 = $doc->create_element ('h');
  $node1->append_child ($el1);
  $node1->append_child ($el2);
  
  $node1->replace_child ($el2, $el1);

  is scalar @{$node1->child_nodes}, 1;
  is $node1->first_child, $el2;
  is $el1->parent_node, undef;
  is $el2->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 6, name => 'replace sibling';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $el1 = $doc->create_element ('f');
  my $el2 = $doc->create_element ('h');
  $node1->append_child ($el2);
  $node1->append_child ($el1);
  
  $node1->replace_child ($el2, $el1);

  is scalar @{$node1->child_nodes}, 1;
  is $node1->first_child, $el2;
  is $el1->parent_node, undef;
  is $el2->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 6, name => 'replace sibling';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $el1 = $doc->create_element ('f');
  my $el2 = $doc->create_element ('h');
  my $el3 = $doc->create_element ('h');
  my $el4 = $doc->create_element ('h');
  $node1->append_child ($el3);
  $node1->append_child ($el2);
  $node1->append_child ($el4);
  $node1->append_child ($el1);
  
  $node1->replace_child ($el2, $el1);

  is scalar @{$node1->child_nodes}, 3;
  is $node1->first_child, $el3;
  is $node1->last_child, $el2;
  is $el1->parent_node, undef;
  is $el2->parent_node, $node1;
  is $el3->parent_node, $node1;
  is $el4->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 9, name => 'replace sibling';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('f');
  my $el1 = $doc->create_element ('x');
  $node1->append_child ($el1);

  $node1->replace_child ($el1, $el1);

  is scalar @{$node1->child_nodes}, 1;
  is $node1->first_child, $el1;
  is $el1->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];
  
  done $c;
} n => 4, name => 'replace itself';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('f');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('g');
  $node1->append_child ($el1);
  $el1->append_child ($el2);

  $node1->replace_child ($el2, $el1);
  
  is scalar @{$node1->child_nodes}, 1;
  is $node1->first_child, $el2;
  is $el2->parent_node, $node1;
  is $el1->parent_node, undef;
  done $c;
} n => 4, name => 'replace parent';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('c');
  my $el3 = $doc->create_element ('d');
  $node1->append_child ($el1);
  $df->append_child ($el2);
  $df->append_child ($el3);
  
  $node1->replace_child ($df, $el1);

  is scalar @{$node1->child_nodes}, 2;
  is $node1->first_child, $el2;
  is $node1->last_child, $el3;
  is scalar @{$df->child_nodes}, 0;

  is $el1->parent_node, undef;
  is $el2->parent_node, $node1;
  is $el3->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el3->[0]->{tree_id}->[$$el3->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$df->[0]->{tree_id}->[$$df->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 11, name => 'replace by df';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('c');
  my $el3 = $doc->create_element ('d');
  my $el4 = $doc->create_element ('d');
  my $el5 = $doc->create_element ('d');
  $node1->append_child ($el4);
  $node1->append_child ($el1);
  $node1->append_child ($el5);
  $df->append_child ($el2);
  $df->append_child ($el3);
  
  $node1->replace_child ($df, $el1);

  is scalar @{$node1->child_nodes}, 4;
  is $node1->first_child, $el4;
  is $node1->last_child, $el5;
  is scalar @{$df->child_nodes}, 0;

  is $el1->parent_node, undef;
  is $el2->parent_node, $node1;
  is $el3->parent_node, $node1;
  is $el4->parent_node, $node1;
  is $el5->parent_node, $node1;

  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el2->[0]->{tree_id}->[$$el2->[1]];
  is $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el3->[0]->{tree_id}->[$$el3->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$df->[0]->{tree_id}->[$$df->[1]];
  isnt $$node1->[0]->{tree_id}->[$$node1->[1]],
      $$el1->[0]->{tree_id}->[$$el1->[1]];

  done $c;
} n => 13, name => 'replace by df';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $df = $doc->create_document_fragment;
  my $el1 = $doc->create_element ('a');
  my $el2 = $doc->create_element ('c');
  my $el3 = $doc->create_element ('d');
  $df->append_child ($el1);
  $df->append_child ($el2);
  $df->append_child ($el3);
  
  dies_here_ok {
    $df->replace_child ($df, $el1);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'HierarchyRequestError';
  is $@->message, 'The child is an inclusive ancestors of the parent';

  is scalar @{$df->child_nodes}, 3;
  is $el1->parent_node, $df;
  is $el2->parent_node, $df;
  is $el3->parent_node, $df;

  done $c;
} n => 8, name => 'replace df by df';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('b');
  $node1->append_child ($el1);

  my $node2 = $node1->replace_child ($el2, $el1);
  isa_ok $node2, 'Web::DOM::Node';
  is $node2, $el2;

  done $c;
} n => 2, name => 'replace return';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('b');
  $node1->append_child ($el1);
  $node1->append_child ($el2);

  my $node2 = $node1->replace_child ($el2, $el2);
  isa_ok $node2, 'Web::DOM::Node';
  is $node2, $el2;

  done $c;
} n => 2, name => 'replace return';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $node1 = $doc->create_element ('a');
  my $el1 = $doc->create_element ('b');
  my $el2 = $doc->create_element ('b');
  $node1->append_child ($el1);
  my $df = $doc->create_document_fragment;
  $df->append_child ($el2);

  my $node2 = $node1->replace_child ($df, $el1);
  isa_ok $node2, 'Web::DOM::Node';
  is $node2, $df;

  done $c;
} n => 2, name => 'replace return df';

run_tests;
