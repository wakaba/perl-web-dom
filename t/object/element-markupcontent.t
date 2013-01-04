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
  my $el = $doc->create_element ('hoge');

  is $el->outer_html,
      q{<hoge xmlns="http://www.w3.org/1999/xhtml"></hoge>};

  $doc->manakai_is_html (1);

  is $el->outer_html, q{<hoge></hoge>};

  done $c;
} n => 2, name => 'outer_xml empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $el->inner_html ('<!-- foo --><p>abc<bar title="a" xml:lang="en"/><br/></p>');

  is $el->outer_html,
      q{<hoge xmlns="http://www.w3.org/1999/xhtml"><!-- foo --><p>abc<bar title="a" xml:lang="en"></bar><br></br></p></hoge>};

  $doc->manakai_is_html (1);

  is $el->outer_html,
      q{<hoge><!-- foo --><p>abc<bar title="a" xml:lang="en"></bar><br></p></hoge>};

  done $c;
} n => 2, name => 'outer_xml not empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('aa');

  $el->outer_html ('hoge <p> ');
  is $el->outer_html, q{<aa xmlns="http://www.w3.org/1999/xhtml"></aa>};

  done $c;
} n => 1, name => 'outer_xml setter no parent xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('aa');
  $el->inner_html ('hoge');

  $el->outer_html ('hoge <p> ');
  is $el->outer_html, q{<aa>hoge</aa>};

  done $c;
} n => 1, name => 'outer_xml setter no parent html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('aa');
  my $el2 = $doc->create_element ('aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el2);

  $el2->outer_html ('hoge <p/> ');
  is $el1->inner_html, q{hoge <p xmlns="http://www.w3.org/1999/xhtml"></p> };

  is $el2->parent_node, undef;
  is $el2->inner_html, 'hoge';

  done $c;
} n => 3, name => 'outer_xml setter parent element xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_element ('aa');
  my $el2 = $doc->create_element ('aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el2);

  $el2->outer_html ('hoge <p/> ');
  is $el1->inner_html, q{hoge <p> </p>};

  is $el2->parent_node, undef;
  is $el2->inner_html, 'hoge';

  done $c;
} n => 3, name => 'outer_xml setter parent element html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_element ('aa');
  my $el2 = $doc->create_element ('aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el2);

  $el2->outer_html ('hoge <p></p> </aa>');
  is $el1->inner_html, q{hoge <p></p> };

  is $el2->parent_node, undef;
  is $el2->inner_html, 'hoge';

  done $c;
} n => 3, name => 'outer_xml setter parent element html 2';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('aa');
  my $el2 = $doc->create_element ('aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el2);

  dies_here_ok {
    $el2->outer_html ('hoge <p> ');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The given string is ill-formed as XML';
  is $el1->inner_html, q{<aa xmlns="http://www.w3.org/1999/xhtml">hoge</aa>};

  is $el2->parent_node, $el1;

  done $c;
} n => 6, name => 'outer_xml setter parent element xml parse error';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('aa');
  my $el2 = $doc->create_element ('aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el2);

  dies_here_ok {
    $el2->outer_html ('hoge <p/> </aa>');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'SyntaxError';
  is $@->message, 'The given string is ill-formed as XML';
  is $el1->inner_html, q{<aa xmlns="http://www.w3.org/1999/xhtml">hoge</aa>};

  is $el2->parent_node, $el1;

  done $c;
} n => 6, name => 'outer_xml setter parent element xml parse error 2';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_element ('aa');
  my $el2 = $doc->create_element ('aa');
  my $el3 = $doc->create_element ('aa');
  my $el4 = $doc->create_element ('aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el3);
  $el1->append_child ($el2);
  $el1->append_child ($el4);

  $el2->outer_html ('hoge <p></p> ');
  is $el1->inner_html, q{<aa></aa>hoge <p></p> <aa></aa>};

  done $c;
} n => 1, name => 'outer_xml setter parent element html siblings';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('aa');
  my $el2 = $doc->create_element ('aa');
  my $el3 = $doc->create_element ('aa');
  my $el4 = $doc->create_element ('aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el3);
  $el1->append_child ($el2);
  $el1->append_child ($el4);

  $el2->outer_html ('hoge <p></p> ');
  is $el1->inner_html, q{<aa xmlns="http://www.w3.org/1999/xhtml"></aa>hoge <p xmlns="http://www.w3.org/1999/xhtml"></p> <aa xmlns="http://www.w3.org/1999/xhtml"></aa>};

  is $el3->parent_node, $el1;
  is $el4->parent_node, $el1;
  is $el2->parent_node, undef;

  done $c;
} n => 4, name => 'outer_xml setter parent element xml siblings';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_element ('aa');
  $el1->set_attribute_ns ('http://www.w3.org/2000/xmlns/', ['xmlns', 'abc'], 'http://ns1/');
  my $el2 = $doc->create_element ('aa');
  $el2->set_attribute_ns ('http://www.w3.org/2000/xmlns/', ['xmlns', 'abc'], 'http://ns2/');
  my $el3 = $doc->create_element ('aa');
  my $el4 = $doc->create_element ('aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el3);
  $el1->append_child ($el2);
  $el1->append_child ($el4);

  $el2->outer_html ('hoge <abc:p></abc:p> ');
  is $el1->inner_html, q{<aa></aa>hoge <abc:p></abc:p> <aa></aa>};
  is $el1->child_nodes->[2]->namespace_uri, 'http://www.w3.org/1999/xhtml';
  is $el1->child_nodes->[2]->local_name, 'abc:p';

  done $c;
} n => 3, name => 'outer_xml setter namespace prefix html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_element ('aa');
  $el1->set_attribute_ns ('http://www.w3.org/2000/xmlns/', ['xmlns', 'abc'], 'http://ns1/');
  my $el2 = $doc->create_element ('aa');
  $el2->set_attribute_ns ('http://www.w3.org/2000/xmlns/', ['xmlns', 'abc'], 'http://ns2/');
  my $el3 = $doc->create_element ('aa');
  my $el4 = $doc->create_element ('aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el3);
  $el1->append_child ($el2);
  $el1->append_child ($el4);

  $el2->outer_html ('hoge <abc:p></abc:p> ');
  is $el1->inner_html, q{<aa xmlns="http://www.w3.org/1999/xhtml"></aa>hoge <abc:p xmlns:abc="http://ns1/"></abc:p> <aa xmlns="http://www.w3.org/1999/xhtml"></aa>};
  is $el1->child_nodes->[2]->namespace_uri, 'http://ns1/';
  is $el1->child_nodes->[2]->local_name, 'p';

  done $c;
} n => 3, name => 'outer_xml setter namespace prefix xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el1 = $doc->create_document_fragment;
  my $el2 = $doc->create_element ('aa');
  my $el3 = $doc->create_element ('aa');
  my $el4 = $doc->create_element ('aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el3);
  $el1->append_child ($el2);
  $el1->append_child ($el4);

  $el2->outer_html ('hoge <p></p> <tr>x');
  is $el1->inner_html, q{<aa></aa>hoge <p></p> x<aa></aa>};

  done $c;
} n => 1, name => 'outer_xml setter parent df html siblings';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el1 = $doc->create_document_fragment;
  my $el2 = $doc->create_element ('aa');
  my $el3 = $doc->create_element ('aa');
  my $el4 = $doc->create_element ('aa');
  $el2->inner_html ('hoge');
  $el1->append_child ($el3);
  $el1->append_child ($el2);
  $el1->append_child ($el4);

  $el2->outer_html ('hoge <p></p> <tr/>x');
  is $el1->inner_html, q{<aa xmlns="http://www.w3.org/1999/xhtml"></aa>hoge <p xmlns="http://www.w3.org/1999/xhtml"></p> <tr xmlns="http://www.w3.org/1999/xhtml"></tr>x<aa xmlns="http://www.w3.org/1999/xhtml"></aa>};

  done $c;
} n => 1, name => 'outer_xml setter parent df xml siblings';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('hoge');
  $el->inner_html ('<q>aaa</q>');
  $doc->append_child ($el);
  
  dies_here_ok {
    $el->outer_html ('<p>hoge</p>');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NoModificationAllowedError';
  is $@->message, 'Cannot set outer_html of the document element';

  is $el->inner_html, q{<q xmlns="http://www.w3.org/1999/xhtml">aaa</q>};
  is $el->parent_node, $doc;

  done $c;
} n => 6, name => 'outer_xml stter parent document xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('hoge');
  $el->inner_html ('<q>aaa</q>');
  $doc->append_child ($el);
  
  dies_here_ok {
    $el->outer_html ('<p>hoge</p>');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NoModificationAllowedError';
  is $@->message, 'Cannot set outer_html of the document element';

  is $el->inner_html, q{<q>aaa</q>};
  is $el->parent_node, $doc;

  done $c;
} n => 6, name => 'outer_xml stter parent document html';

run_tests;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
