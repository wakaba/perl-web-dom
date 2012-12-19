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
  isa_ok $doc, 'Web::DOM::Document';
  ok not $doc->isa ('Web::DOM::XMLDocument');

  is $doc->node_type, $doc->DOCUMENT_NODE;
  is $doc->namespace_uri, undef;
  is $doc->prefix, undef;
  is $doc->manakai_local_name, undef;
  is $doc->local_name, undef;

  is $doc->url, 'about:blank';
  is $doc->document_uri, $doc->url;
  is $doc->content_type, 'application/xml';
  is $doc->character_set, 'utf-8';
  is !!$doc->manakai_is_html, !!0;
  is $doc->compat_mode, 'CSS1Compat';
  is $doc->manakai_compat_mode, 'no quirks';
  is $doc->owner_document, undef;

  is $doc->node_value, undef;
  $doc->node_value ('hoge');
  is $doc->node_value, undef;

  done $c;
} name => 'constructor', n => 17;

test {
  my $c = shift;

  my $doc = new Web::DOM::Document;

  my $impl = $doc->implementation;
  isa_ok $impl, 'Web::DOM::Implementation';

  is $doc->implementation, $impl;

  done $c;
} name => 'implementation', n => 2;

test {
  my $c = shift;
  
  my $doc = new Web::DOM::Document;

  my $doc2 = $doc->implementation->create_document;
  is $doc2->can ('manakai_is_html') ? 1 : 0, 1, "can manakai_is_html";
  is $doc2->can ('compat_mode') ? 1 : 0, 1, "can compat_mode";
  is $doc2->can ('manakai_compat_mode') ? 1 : 0, 1, "can manakai_compat_mode";
  is $doc2->manakai_is_html ? 1 : 0, 0, "manakai_is_html [0]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [0]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [0]';

  $doc2->manakai_compat_mode ('quirks');
  is $doc2->manakai_is_html ? 1 : 0, 0, "manakai_is_html [1]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [1]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [1]';

  $doc2->manakai_compat_mode ('limited quirks');
  is $doc2->manakai_is_html ? 1 : 0, 0, "manakai_is_html [2]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [2]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [2]';

  $doc2->manakai_compat_mode ('no quirks');
  is $doc2->manakai_is_html ? 1 : 0, 0, "manakai_is_html [3]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [3]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [3]';

  $doc2->manakai_compat_mode ('bogus');
  is $doc2->manakai_is_html ? 1 : 0, 0, "manakai_is_html [4]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [4]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [4]';

  $doc2->manakai_is_html (1);
  is $doc2->manakai_is_html ? 1 : 0, 1, "manakai_is_html [5]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [5]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [5]';

  $doc2->manakai_compat_mode ('quirks');
  is $doc2->manakai_is_html ? 1 : 0, 1, "manakai_is_html [6]";
  is $doc2->compat_mode, 'BackCompat', 'compat_mode [6]';
  is $doc2->manakai_compat_mode, 'quirks', 'manakai_compat_mode [6]';

  $doc2->manakai_compat_mode ('limited quirks');
  is $doc2->manakai_is_html ? 1 : 0, 1, "manakai_is_html [7]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [7]';
  is $doc2->manakai_compat_mode, 'limited quirks', 'manakai_compat_mode [7]';

  $doc2->manakai_compat_mode ('no quirks');
  is $doc2->manakai_is_html ? 1 : 0, 1, "manakai_is_html [8]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [8]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [8]';

  $doc2->manakai_compat_mode ('bogus');
  is $doc2->manakai_is_html ? 1 : 0, 1, "manakai_is_html [9]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [9]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [9]';

  $doc2->manakai_compat_mode ('quirks');
  $doc2->manakai_is_html (0);
  is $doc2->manakai_is_html ? 1 : 0, 0, "manakai_is_html [10]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [10]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [10]';

  $doc2->manakai_is_html (1);
  is $doc2->manakai_is_html ? 1 : 0, 1, "manakai_is_html [11]";
  is $doc2->compat_mode, 'CSS1Compat', 'compat_mode [11]';
  is $doc2->manakai_compat_mode, 'no quirks', 'manakai_compat_mode [11]';

  done $c;
} name => 'html mode', n => 39;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  is $doc->content_type, 'application/xml';
  $doc->manakai_is_html (1);
  is $doc->content_type, 'text/html';
  $doc->manakai_is_html (0);
  is $doc->content_type, 'application/xml';
  $doc->manakai_is_html (1);
  is $doc->content_type, 'text/html';
  done $c;
} n => 4, name => 'content_type vs manakai_is_html';

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

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
