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

  my $df = $doc->create_document_fragment;
  isa_ok $df, 'Web::DOM::DocumentFragment';
  is $df->node_type, $df->DOCUMENT_FRAGMENT_NODE;
  is $df->first_child, undef;
  is $df->owner_document, $doc;

  my $df2 = $doc->create_document_fragment;
  isnt $df2, $df;
  done $c;
} n => 5, name => 'create_document_fragment';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $text = $doc->create_text_node ('hoge');
  isa_ok $text, 'Web::DOM::Text';
  is $text->node_type, $text->TEXT_NODE;
  is $text->data, 'hoge';
  is $text->owner_document, $doc;
  done $c;
} n => 4, name => 'create_text_node';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $text = $doc->create_text_node;
  isa_ok $text, 'Web::DOM::Text';
  is $text->node_type, $text->TEXT_NODE;
  is $text->data, '';
  is $text->owner_document, $doc;
  done $c;
} n => 4, name => 'create_text_node undef';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $comment = $doc->create_comment ('hoge');
  isa_ok $comment, 'Web::DOM::Comment';
  is $comment->node_type, $comment->COMMENT_NODE;
  is $comment->data, 'hoge';
  is $comment->owner_document, $doc;
  done $c;
} n => 4, name => 'create_comment';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $comment = $doc->create_comment;
  isa_ok $comment, 'Web::DOM::Comment';
  is $comment->node_type, $comment->COMMENT_NODE;
  is $comment->data, '';
  is $comment->owner_document, $doc;
  done $c;
} n => 4, name => 'create_comment undef';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('hoge', 'fuga');
  isa_ok $pi, 'Web::DOM::ProcessingInstruction';
  is $pi->node_type, $pi->PROCESSING_INSTRUCTION_NODE;
  is $pi->target, 'hoge';
  is $pi->data, 'fuga';
  done $c;
} n => 4, name => 'create_processing_instruction';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('xml', 'fuga');
  isa_ok $pi, 'Web::DOM::ProcessingInstruction';
  is $pi->node_type, $pi->PROCESSING_INSTRUCTION_NODE;
  is $pi->target, 'xml';
  is $pi->data, 'fuga';
  done $c;
} n => 4, name => 'create_processing_instruction xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('aaa', '');
  isa_ok $pi, 'Web::DOM::ProcessingInstruction';
  is $pi->node_type, $pi->PROCESSING_INSTRUCTION_NODE;
  is $pi->target, 'aaa';
  is $pi->data, '';
  done $c;
} n => 4, name => 'create_processing_instruction empty value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('aaa');
  isa_ok $pi, 'Web::DOM::ProcessingInstruction';
  is $pi->node_type, $pi->PROCESSING_INSTRUCTION_NODE;
  is $pi->target, 'aaa';
  is $pi->data, '';
  done $c;
} n => 4, name => 'create_processing_instruction undef value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $pi = $doc->create_processing_instruction ('xml:hoge', 'fuga');
  isa_ok $pi, 'Web::DOM::ProcessingInstruction';
  is $pi->node_type, $pi->PROCESSING_INSTRUCTION_NODE;
  is $pi->target, 'xml:hoge';
  is $pi->data, 'fuga';
  done $c;
} n => 4, name => 'create_processing_instruction not ncname';

for my $name (
  undef, '', '1353', "\x00aa", "\x{FFFE}",
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    dies_here_ok {
      $doc->create_processing_instruction ($name, 'fuga');
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'InvalidCharacterError';
    is $@->message, 'The target is not an XML Name';
    done $c;
  } n => 4, name => ['create_processing_instruction not xml Name', $name];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_processing_instruction ('hoge120', 'a?>b');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The data cannot contain ?>';
  done $c;
} n => 4, name => 'create_processing_instruction bad data';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_processing_instruction;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The target is not an XML Name';
  done $c;
} n => 4, name => 'create_processing_instruction undef';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  dies_here_ok {
    $doc->create_cdata_section ("a");
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'CDATASection is obsolete';
  
  done $c;
} n => 4, name => 'create_cdata_section';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  dies_here_ok {
    $doc->create_entity_reference ("a");
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotSupportedError';
  is $@->message, 'EntityReference is obsolete';
  
  done $c;
} n => 4, name => 'create_entity_reference';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
