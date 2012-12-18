use strict;
use warnings;
no warnings 'utf8';
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
    $doc->implementation->create_document_type ('a', '', ''),
    $doc->create_text_node ('b'),
    $doc->create_comment ('b'),
    $doc->create_processing_instruction ('cc', ''),
    $doc->create_document_fragment,
  ) {
    test {
      my $c = shift;
      my $attrs = $node->attributes;
      is $attrs, undef;
      ok not $node->has_attributes;
      done $c;
    } n => 2, name => ['attributes', $node->node_type];
  }
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  my $attrs = $el->attributes;
  isa_ok $attrs, 'Web::DOM::NamedNodeMap';
  is scalar @$attrs, 0;
  ok not $el->has_attributes;
  done $c;
} n => 3, name => 'attributes no attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute ('hoge' => '');
  my $attrs = $el->attributes;
  isa_ok $attrs, 'Web::DOM::NamedNodeMap';
  is scalar @$attrs, 1;
  ok $el->has_attributes;
  done $c;
} n => 3, name => 'attributes with simple attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aa', 'hoge' => '');
  my $attrs = $el->attributes;
  isa_ok $attrs, 'Web::DOM::NamedNodeMap';
  is scalar @$attrs, 1;
  ok $el->has_attributes;
  done $c;
} n => 3, name => 'attributes with node attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute ('hoge' => '');
  $el->set_attribute_ns ('fuga', 'aaa' => 'bb');
  my $attrs = $el->attributes;
  isa_ok $attrs, 'Web::DOM::NamedNodeMap';
  is scalar @$attrs, 2;
  ok $el->has_attributes;
  done $c;
} n => 3, name => 'attributes with attrs';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute (hoge => 'fuga');

  my $attrs = $el->attributes;
  isa_ok $attrs, 'Web::DOM::NamedNodeMap';
  is $attrs->length, 1;
  is scalar @$attrs, 1;
  my $node1 = $attrs->[0];
  isa_ok $node1, 'Web::DOM::Attr';
  is $node1->namespace_uri, undef;
  is $node1->prefix, undef;
  is $node1->local_name, 'hoge';
  is $node1->value, 'fuga';
  is $attrs->[1], undef;
  is $attrs->item (0), $node1;

  $node1->value ('aaa');
  is $el->get_attribute ('hoge'), 'aaa';

  done $c;
} n => 11, name => 'attributes NamedNodeMap simple attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aa', hoge => 'fuga');

  my $attrs = $el->attributes;
  isa_ok $attrs, 'Web::DOM::NamedNodeMap';
  is $attrs->length, 1;
  is scalar @$attrs, 1;
  my $node1 = $attrs->[0];
  isa_ok $node1, 'Web::DOM::Attr';
  is $node1->namespace_uri, 'aa';
  is $node1->prefix, undef;
  is $node1->local_name, 'hoge';
  is $node1->value, 'fuga';
  is $attrs->[1], undef;
  is $attrs->item (0), $node1;

  $node1->value ('aaa');
  is $el->get_attribute ('hoge'), 'aaa';

  done $c;
} n => 11, name => 'attributes NamedNodeMap node attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  is $el->get_attribute ('hoge'), undef;
  is $el->get_attribute ('fuga'), undef;
  is $el->get_attribute ('12'), undef;
  is $el->get_attribute ('xml:lang'), undef;
  is $el->get_attribute ('abc:lang'), undef;

  is $el->get_attribute_ns (undef, 'hoge'), undef;
  is $el->get_attribute_ns ('', 'hoge'), undef;
  is $el->get_attribute_ns ('http://hoge/', 'hoge'), undef;
  is $el->get_attribute_ns ('http://hoge/', 'fuga:hoge'), undef;
  is $el->get_attribute_ns ('http://hoge/', '210'), undef;

  done $c;
} n => 10, name => 'get attribute not found';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  $el->set_attribute (hoge => 'ab de');
  is $el->get_attribute ('hoge'), 'ab de';
  is $el->get_attribute_ns (undef, 'hoge'), 'ab de';
  is $el->get_attribute_ns ('', 'hoge'), 'ab de';

  done $c;
} n => 3, name => 'set_attribute new attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  $el->set_attribute_ns (undef, hoge => 'ab de');
  is $el->get_attribute ('hoge'), 'ab de';
  is $el->get_attribute_ns (undef, 'hoge'), 'ab de';
  is $el->get_attribute_ns ('', 'hoge'), 'ab de';

  done $c;
} n => 3, name => 'set_attribute_ns new attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://hoge/', 'foo' => 'aa');
  is $el->get_attribute ('foo'), 'aa';
  is $el->get_attribute_ns ('http://hoge/', 'foo'), 'aa';
  is $el->get_attribute_ns ('http://fuga/', 'foo'), undef;
  is $el->get_attribute_ns (undef, 'foo'), undef;
  is $el->get_attribute_ns ('', 'foo'), undef;

  done $c;
} n => 5, name => 'set_attribute_ns new namespaced attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://hoge/', 'hoge:foo' => 'aa');
  is $el->get_attribute ('foo'), undef;
  is $el->get_attribute ('hoge:foo'), 'aa';
  is $el->get_attribute_ns ('http://hoge/', 'foo'), 'aa';
  is $el->get_attribute_ns ('http://hoge/', 'hoge:foo'), undef;
  is $el->get_attribute_ns ('http://fuga/', 'foo'), undef;
  is $el->get_attribute_ns (undef, 'hoge:foo'), undef;
  is $el->get_attribute_ns (undef, 'foo'), undef;
  is $el->get_attribute_ns ('', 'foo'), undef;

  done $c;
} n => 8, name => 'set_attribute_ns new namespaced prefixed attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  $el->set_attribute (hoge => 'fuga');

  $el->set_attribute (hoge => 'aa bb');
  is $el->get_attribute ('hoge'), 'aa bb';

  $el->set_attribute_ns (undef, 'hoge' => 'bb ee ');
  is $el->get_attribute ('hoge'), 'bb ee ';

  done $c;
} n => 2, name => 'set change simple value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aa', hoge => 'fuga');

  $el->set_attribute (hoge => 'aa bb');
  is $el->get_attribute_ns ('aa', 'hoge'), 'aa bb';

  $el->set_attribute_ns ('aa', 'hoge' => 'bb ee ');
  is $el->get_attribute_ns ('aa', 'hoge'), 'bb ee ';

  done $c;
} n => 2, name => 'set change node value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aa', 'b:hoge' => 'fuga');

  $el->set_attribute ('b:hoge' => 'aa bb');
  is $el->get_attribute_ns ('aa', 'hoge'), 'aa bb';

  $el->set_attribute_ns ('aa', 'c:hoge' => 'bb ee ');
  is $el->get_attribute_ns ('aa', 'hoge'), 'bb ee ';

  done $c;
} n => 2, name => 'set change node value, changing prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('a');

  $el->set_attribute_ns (undef, hoge => 'fuga');
  $el->set_attribute_ns ('http://a/', hoge => 'a b');

  is $el->get_attribute ('hoge'), 'fuga';
  is $el->get_attribute_ns (undef, 'hoge'), 'fuga';
  is $el->get_attribute_ns ('http://a/', 'hoge'), 'a b';

  $el->set_attribute ('hoge' => 'AA');
  is $el->get_attribute_ns (undef, 'hoge'), 'AA';
  is $el->get_attribute_ns ('http://a/', 'hoge'), 'a b';
  
  done $c;
} n => 5, name => 'get/set attributes with same name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('f');
  $el->set_attribute ('bb' => 'cc');
  $el->set_attribute ('xx' => 'cc');
  $el->set_attribute_ns ('undef', 'gg' => 'cc');

  $el->set_attribute ('aa' => '');
  $el->set_attribute ('bb' => '');
  $el->set_attribute_ns (undef, 'xx' => '');
  $el->set_attribute_ns (undef, 'yy' => '');
  $el->set_attribute_ns ('undef', 'gg' => '');
  $el->set_attribute_ns ('undef', 'hh' => '');

  is $el->get_attribute ('aa'), '';
  is $el->get_attribute ('bb'), '';
  is $el->get_attribute ('xx'), '';
  is $el->get_attribute ('yy'), '';
  is $el->get_attribute_ns ('undef', 'gg'), '';
  is $el->get_attribute_ns ('undef', 'hh'), '';

  done $c;
} n => 6, name => 'set empty values';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('f');
  $el->set_attribute ('bb' => 'cc');
  $el->set_attribute ('xx' => 'cc');
  $el->set_attribute_ns ('undef', 'gg' => 'cc');

  $el->set_attribute ('aa' => undef);
  $el->set_attribute ('bb' => undef);
  $el->set_attribute_ns (undef, 'xx' => undef);
  $el->set_attribute_ns (undef, 'yy' => undef);
  $el->set_attribute_ns ('undef', 'gg' => undef);
  $el->set_attribute_ns ('undef', 'hh' => undef);

  is $el->get_attribute ('aa'), '';
  is $el->get_attribute ('bb'), '';
  is $el->get_attribute ('xx'), '';
  is $el->get_attribute ('yy'), '';
  is $el->get_attribute_ns ('undef', 'gg'), '';
  is $el->get_attribute_ns ('undef', 'hh'), '';

  done $c;
} n => 6, name => 'set undef values';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);

  my $el = $doc->create_element ('hoge');
  $el->set_attribute (aai => '134 "');

  is $el->get_attribute ('aai'), '134 "';
  is $el->get_attribute ('AAI'), '134 "';
  is $el->get_attribute ('aAi'), '134 "';
  is $el->get_attribute ("aA\x{0130}"), undef;
  is $el->get_attribute ("aA\x{0131}"), undef;

  is $el->get_attribute_ns (undef, 'aai'), '134 "';
  is $el->get_attribute_ns (undef, 'AAI'), undef;
  is $el->get_attribute_ns (undef, 'aAi'), undef;

  ok $el->has_attribute ('aai');
  ok $el->has_attribute ('AAI');
  ok $el->has_attribute ('aAi');
  ok not $el->has_attribute ("aA\x{0130}");
  ok not $el->has_attribute ("aA\x{0131}");

  ok $el->has_attribute_ns (undef, 'aai');
  ok not $el->has_attribute_ns (undef, 'AAI');
  ok not $el->has_attribute_ns (undef, 'aAi');

  done $c;
} n => 16, name => 'get/has html case-insensitivity';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);

  my $el = $doc->create_element ('hoge');
  $el->set_attribute_ns ("bb", "d:aai" => '134 "');

  is $el->get_attribute ('d:aai'), '134 "';
  is $el->get_attribute ('d:AAI'), '134 "';
  is $el->get_attribute ('d:aAi'), '134 "';
  is $el->get_attribute ("d:aA\x{0130}"), undef;
  is $el->get_attribute ("d:aA\x{0131}"), undef;

  is $el->get_attribute_ns ("bb", 'aai'), '134 "';
  is $el->get_attribute_ns ("bb", 'AAI'), undef;
  is $el->get_attribute_ns ("bb", 'aAi'), undef;

  ok $el->has_attribute ('d:aai');
  ok $el->has_attribute ('d:AAI');
  ok $el->has_attribute ('d:aAi');
  ok not $el->has_attribute ("d:aA\x{0130}");
  ok not $el->has_attribute ("d:aA\x{0131}");

  ok $el->has_attribute_ns ("bb", 'aai');
  ok not $el->has_attribute_ns ("bb", 'AAI');
  ok not $el->has_attribute_ns ("bb", 'aAi');

  done $c;
} n => 16, name => 'get/has html case-insensitivity, local name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);

  my $el = $doc->create_element ('hoge');
  $el->set_attribute_ns ("bb", "aai:bb" => '134 "');

  is $el->get_attribute ('aai:bb'), '134 "';
  is $el->get_attribute ('AAI:bb'), '134 "';
  is $el->get_attribute ('aAi:bb'), '134 "';
  is $el->get_attribute ("aA\x{0130}:bb"), undef;
  is $el->get_attribute ("aA\x{0131}:bb"), undef;

  ok $el->get_attribute ('aai:bb');
  ok $el->get_attribute ('AAI:bb');
  ok $el->get_attribute ('aAi:bb');
  ok not $el->get_attribute ("aA\x{0130}:bb");
  ok not $el->get_attribute ("aA\x{0131}:bb");

  done $c;
} n => 10, name => 'get/has html case-insensitivity, prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $el = $doc->create_element ('hoge');
  $el->set_attribute (aai => '134 "');

  is $el->get_attribute ('aai'), '134 "';
  is $el->get_attribute ('AAI'), undef;
  is $el->get_attribute ('aAi'), undef;
  is $el->get_attribute ("aA\x{0130}"), undef;
  is $el->get_attribute ("aA\x{0131}"), undef;

  is $el->get_attribute_ns (undef, 'aai'), '134 "';
  is $el->get_attribute_ns (undef, 'AAI'), undef;
  is $el->get_attribute_ns (undef, 'aAi'), undef;

  ok $el->get_attribute ('aai');
  ok not $el->get_attribute ('AAI');
  ok not $el->get_attribute ('aAi');
  ok not $el->get_attribute ("aA\x{0130}");
  ok not $el->get_attribute ("aA\x{0131}");

  ok $el->get_attribute_ns (undef, 'aai');
  ok not $el->get_attribute_ns (undef, 'AAI');
  ok not $el->get_attribute_ns (undef, 'aAi');

  done $c;
} n => 16, name => 'get/has xml case-insensitivity';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);

  my $el = $doc->create_element_ns (undef, 'hoge');
  $el->set_attribute (aai => '134 "');

  is $el->get_attribute ('aai'), '134 "';
  is $el->get_attribute ('AAI'), undef;
  is $el->get_attribute ('aAi'), undef;
  is $el->get_attribute ("aA\x{0130}"), undef;
  is $el->get_attribute ("aA\x{0131}"), undef;

  is $el->get_attribute_ns (undef, 'aai'), '134 "';
  is $el->get_attribute_ns (undef, 'AAI'), undef;
  is $el->get_attribute_ns (undef, 'aAi'), undef;

  ok $el->get_attribute ('aai');
  ok not $el->get_attribute ('AAI');
  ok not $el->get_attribute ('aAi');
  ok not $el->get_attribute ("aA\x{0130}");
  ok not $el->get_attribute ("aA\x{0131}");

  ok $el->get_attribute_ns (undef, 'aai');
  ok not $el->get_attribute_ns (undef, 'AAI');
  ok not $el->get_attribute_ns (undef, 'aAi');

  done $c;
} n => 16, name => 'get/has html case-insensitivity, non-HTML element';

for my $name (
  undef, '', '124', "\x{00}", "\x70\x{D8F0}",
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');

    dies_here_ok {
      $el->set_attribute ($name => 'abc');
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'InvalidCharacterError';
    is $@->message, 'The name is not an XML Name';
    
    is $el->get_attribute ($name), undef;

    done $c;
  } n => 5, name => ['set_attribute not XML name', $name];

  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');

    dies_here_ok {
      $el->set_attribute_ns (undef, $name => 'abc');
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'InvalidCharacterError';
    is $@->message, 'The qualified name is not an XML Name';
    
    is $el->get_attribute ($name), undef;

    done $c;
  } n => 5, name => ['set_attribute_ns not XML name', $name];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute ('hoge:fuga' => 'abc');
  is $el->get_attribute ('hoge:fuga'), 'abc';
  is $el->get_attribute_ns (undef, 'hoge:fuga'), 'abc';

  done $c;
} n => 2, name => 'set_attribute not XML NCName';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute ("AB\x{0130}\x{0131}" => "ABC");
  is $el->get_attribute ("ab\x{0130}\x{0131}"), undef;
  is $el->get_attribute ("AB\x{0130}\x{0131}"), "ABC";

  done $c;
} n => 2, name => 'set_attribute case-sensitivity xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');

  $el->set_attribute ("AB\x{0130}\x{0131}" => "ABC");
  is $el->get_attribute ("ab\x{0130}\x{0131}"), "ABC";
  is $el->get_attribute ("AB\x{0130}\x{0131}"), "ABC";

  $doc->manakai_is_html (0);
  is $el->get_attribute ("ab\x{0130}\x{0131}"), "ABC";
  is $el->get_attribute ("AB\x{0130}\x{0131}"), undef;

  done $c;
} n => 4, name => 'set_attribute case-sensitivity html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ("foo", "ab\x{0130}\x{0131}:c" => "dd");

  $el->set_attribute ("AB\x{0130}\x{0131}:c" => "ABC");
  is $el->get_attribute ("ab\x{0130}\x{0131}:c"), "ABC";
  is $el->get_attribute ("AB\x{0130}\x{0131}:c"), "ABC";

  $doc->manakai_is_html (0);
  is $el->get_attribute ("ab\x{0130}\x{0131}:c"), "ABC";
  is $el->get_attribute ("AB\x{0130}\x{0131}:c"), undef;

  is $el->get_attribute_ns ("foo", "c"), "ABC";

  done $c;
} n => 5, name => 'set_attribute case-sensitivity html, prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ("foo", "c:ab\x{0130}\x{0131}" => "dd");

  $el->set_attribute ("c:AB\x{0130}\x{0131}" => "ABC");
  is $el->get_attribute ("c:ab\x{0130}\x{0131}"), "ABC";
  is $el->get_attribute ("c:AB\x{0130}\x{0131}"), "ABC";

  $doc->manakai_is_html (0);
  is $el->get_attribute ("c:ab\x{0130}\x{0131}"), "ABC";
  is $el->get_attribute ("c:AB\x{0130}\x{0131}"), undef;

  is $el->get_attribute_ns ("foo", "ab\x{0130}\x{0131}"), "ABC";
  is $el->get_attribute_ns ("foo", "AB\x{0130}\x{0131}"), undef;

  done $c;
} n => 6, name => 'set_attribute case-sensitivity html, local name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element_ns ('hoge', 'a');

  $el->set_attribute ("AB\x{0130}\x{0131}" => "ABC");
  is $el->get_attribute ("ab\x{0130}\x{0131}"), undef;
  is $el->get_attribute ("AB\x{0130}\x{0131}"), "ABC";

  done $c;
} n => 2, name => 'set_attribute case-sensitivity html non-html element';

for my $qname (
  ':hoge', 'fuga:', 'abc:124', ':',
) {
  test {
    my $c = shift;
    my $doc = new Web::DOM::Document;
    my $el = $doc->create_element ('a');

    dies_here_ok {
      $el->set_attribute_ns ('hpofgexs', $qname => 'hh');
    };
    isa_ok $@, 'Web::DOM::Exception';
    is $@->name, 'NamespaceError';
    is $@->message, 'The qualified name is not an XML QName';
    
    is $el->get_attribute_ns (undef, $qname), undef;
    done $c;
  } n => 5, name => ['get_attribute_ns non-qname', $qname];
}

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('x');

  dies_here_ok {
    $el->set_attribute_ns (undef, 'hoge:fuga' => 'a');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';

  is $el->get_attribute ('hoge:fuga'), undef;

  done $c;
} n => 5, name => 'get_attribute_ns prefixed null namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  dies_here_ok {
    $el->set_attribute_ns (undef, 'xml:lang' => 'en');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';

  is $el->get_attribute_ns (undef, 'lang'), undef;
  is $el->get_attribute_ns (undef, 'xml:lang'), undef;
  is $el->get_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'lang'), undef;

  done $c;
} n => 7, name => 'set_attribute_ns xml: prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  dies_here_ok {
    $el->set_attribute_ns ('hoge', 'xml:lang' => 'en');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Prefix |xml| cannot be bound to anything other than XML namespace';

  is $el->get_attribute_ns (undef, 'lang'), undef;
  is $el->get_attribute_ns (undef, 'xml:lang'), undef;
  is $el->get_attribute_ns ('hoge', 'lang'), undef;
  is $el->get_attribute_ns ('hoge', 'xml:lang'), undef;
  is $el->get_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'lang'), undef;

  done $c;
} n => 9, name => 'set_attribute_ns xml: prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'lang', 'ss');
  
  is $el->get_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'lang'), 'ss';

  done $c;
} n => 1, name => 'set_attribute_ns xml: namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'xml:lang', 'ss');
  
  is $el->get_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'lang'), 'ss';

  done $c;
} n => 1, name => 'set_attribute_ns xml: prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  dies_here_ok {
    $el->set_attribute_ns ('hoge', 'xmlns:lang' => 'en');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';

  is $el->get_attribute_ns (undef, 'lang'), undef;
  is $el->get_attribute_ns (undef, 'xmlns:lang'), undef;
  is $el->get_attribute_ns ('hoge', 'lang'), undef;
  is $el->get_attribute_ns ('hoge', 'xmlns:lang'), undef;
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'lang'), undef;

  done $c;
} n => 9, name => 'set_attribute_ns xml: prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  dies_here_ok {
    $el->set_attribute_ns ('hoge', 'xmlns' => 'en');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';

  is $el->get_attribute_ns (undef, 'xmlns'), undef;
  is $el->get_attribute_ns (undef, 'xmlns:xmlns'), undef;
  is $el->get_attribute_ns ('hoge', 'xmlns'), undef;
  is $el->get_attribute_ns ('hoge', 'xmlns:xmlns'), undef;
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns'), undef;

  done $c;
} n => 9, name => 'set_attribute_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  dies_here_ok {
    $el->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'XMLns' => 'en');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';

  is $el->get_attribute_ns (undef, 'XMLns'), undef;
  is $el->get_attribute_ns (undef, 'xmlns:XMLns'), undef;
  is $el->get_attribute_ns ('hoge', 'XMLns'), undef;
  is $el->get_attribute_ns ('hoge', 'xmlns:XMLns'), undef;
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'XMLns'), undef;

  done $c;
} n => 9, name => 'set_attribute_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  dies_here_ok {
    $el->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'XMLns:hoge' => 'en');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';

  is $el->get_attribute_ns (undef, 'hoge'), undef;
  is $el->get_attribute_ns (undef, 'XMLns:hoge'), undef;
  is $el->get_attribute_ns ('hoge', 'hoge'), undef;
  is $el->get_attribute_ns ('hoge', 'XMLns:hoge'), undef;
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'hoge'), undef;

  done $c;
} n => 9, name => 'set_attribute_ns xmlns:';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns', 'foo');
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns'), 'foo';

  done $c;
} n => 1, name => 'set_attribute_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:hoge', 'foo');
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'hoge'), 'foo';

  done $c;
} n => 1, name => 'set_attribute_ns xmlns:';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:xmlns', 'foo');
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns'), 'foo';

  done $c;
} n => 1, name => 'set_attribute_ns xmlns:xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:ab', 'foo');
  is $el->get_attribute_ns ('http://www.w3.org/2000/xmlns/', 'ab'), 'foo';

  done $c;
} n => 1, name => 'set_attribute_ns xmlns:';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  
  ok not $el->has_attribute ('ab');
  ok not $el->has_attribute ('ab:foo');
  ok not $el->has_attribute ('53333');
  ok not $el->has_attribute ('');
  ok not $el->has_attribute (undef);

  ok not $el->has_attribute_ns (undef, 'ab');
  ok not $el->has_attribute_ns (undef, 'ab:foo');
  ok not $el->has_attribute_ns (undef, '53333');
  ok not $el->has_attribute_ns (undef, '');
  ok not $el->has_attribute_ns (undef, undef);
  ok not $el->has_attribute_ns ('', '');
  ok not $el->has_attribute_ns ('aab', '');
  ok not $el->has_attribute_ns ('aab', 'fe');
  ok not $el->has_attribute_ns ('aab', 'aa:fe');

  done $c;
} n => 14, name => 'has no attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute (hoge => 'fua');
  
  ok $el->has_attribute ('hoge');
  ok not $el->has_attribute ('Hoge');
  ok $el->has_attribute_ns (undef, 'hoge');
  ok $el->has_attribute_ns ('', 'hoge');
  ok not $el->has_attribute_ns ('aaa', 'hoge');
  ok not $el->has_attribute_ns ('aaa', 'aaa:hoge');
  ok not $el->has_attribute_ns (undef, 'aaa:hoge');

  done $c;
} n => 7, name => 'has simple attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aa', hoge => 'fua');
  
  ok $el->has_attribute ('hoge');
  ok not $el->has_attribute ('Hoge');
  ok not $el->has_attribute_ns (undef, 'hoge');
  ok not $el->has_attribute_ns ('', 'hoge');
  ok $el->has_attribute_ns ('aa', 'hoge');
  ok not $el->has_attribute_ns ('aa', 'aaa:hoge');
  ok not $el->has_attribute_ns (undef, 'aaa:hoge');

  done $c;
} n => 7, name => 'has node attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('aa', "bb:hoge" => 'fua');
  
  ok not $el->has_attribute ('hoge');
  ok not $el->has_attribute ('Hoge');
  ok $el->has_attribute ('bb:hoge');
  ok not $el->has_attribute_ns (undef, 'hoge');
  ok not $el->has_attribute_ns ('', 'hoge');
  ok $el->has_attribute_ns ('aa', 'hoge');
  ok not $el->has_attribute_ns ('aa', 'aaa:hoge');
  ok not $el->has_attribute_ns (undef, 'aaa:hoge');
  ok not $el->has_attribute_ns ('bb', 'hoge');
  ok not $el->has_attribute_ns ('aa', 'bb:hoge');

  done $c;
} n => 10, name => 'has prefixed node attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->set_attribute (hoge => '');
  ok $el->has_attribute ('hoge');
  ok $el->has_attribute_ns ('', 'hoge');

  $el->set_attribute (fuga => '0');
  ok $el->has_attribute ('fuga');
  ok $el->has_attribute_ns ('', 'fuga');

  done $c;
} n => 4, name => 'has false value';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('hoge', 'foo:bar' => 'aa');

  ok $el->has_attribute ('foo:bar');
  ok not $el->has_attribute ('bar');
  ok not $el->has_attribute_ns (undef, 'foo:bar');
  ok not $el->has_attribute_ns (undef, 'bar');
  ok not $el->has_attribute_ns ('', 'bar');
  ok $el->has_attribute_ns ('hoge', 'bar');

  done $c;
} n => 6, name => 'has qname';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');

  $el->remove_attribute ('hoge');
  $el->remove_attribute ('120');
  $el->remove_attribute_ns (undef, 'hoge');
  $el->remove_attribute_ns ('', 'hoge');
  $el->remove_attribute_ns ('', 'hoge:fuga');
  $el->remove_attribute_ns ('', 'hoge:120');
  $el->remove_attribute_ns ('http://hoge', 'hoge:a120');
  $el->remove_attribute_ns ('http://hoge', 'hoge:120');

  is $el->get_attribute ('hoge'), undef;

  done $c;
} n => 1, name => 'remove no attribute';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute ('hoge' => 'fuga');

  $el->remove_attribute ('hoge');

  is $el->get_attribute ('hoge'), undef;

  done $c;
} n => 1, name => 'remove_attribute null namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute ('hoge' => 'fuga');

  $el->remove_attribute_ns (undef, 'hoge');

  is $el->get_attribute ('hoge'), undef;

  done $c;
} n => 1, name => 'remove_attribute_ns null namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute ('hoge' => 'fuga');

  $el->remove_attribute_ns ('', 'hoge');

  is $el->get_attribute ('hoge'), undef;

  done $c;
} n => 1, name => 'remove_attribute_ns null namespace empty';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'fuga' => '');
  
  $el->remove_attribute ('fuga');

  is $el->get_attribute ('fuga'), undef;
  is $el->get_attribute_ns ('htoge', 'fuga'), undef;

  done $c;
} n => 2, name => 'remove_attribute namespaced unprefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'fuga' => '');
  
  $el->remove_attribute_ns (undef, 'fuga');

  is $el->get_attribute ('fuga'), '';
  is $el->get_attribute_ns ('htoge', 'fuga'), '';

  done $c;
} n => 2, name => 'remove_attribute_ns namespaced unprefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'fuga' => '');
  
  $el->remove_attribute_ns ('', 'fuga');

  is $el->get_attribute ('fuga'), '';
  is $el->get_attribute_ns ('htoge', 'fuga'), '';

  done $c;
} n => 2, name => 'remove_attribute_ns namespaced unprefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'fuga' => '');
  
  $el->remove_attribute_ns ('htoge', 'fuga');

  is $el->get_attribute ('fuga'), undef;
  is $el->get_attribute_ns ('htoge', 'fuga'), undef;

  done $c;
} n => 2, name => 'remove_attribute_ns namespaced unprefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'aa:fuga' => '');
  
  $el->remove_attribute ('fuga');

  is $el->get_attribute ('fuga'), undef;
  is $el->get_attribute_ns ('htoge', 'fuga'), '';

  done $c;
} n => 2, name => 'remove_attribute namespaced prefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'aa:fuga' => '');
  
  $el->remove_attribute ('aa:fuga');

  is $el->get_attribute ('fuga'), undef;
  is $el->get_attribute ('aa:fuga'), undef;
  is $el->get_attribute_ns ('htoge', 'fuga'), undef;
  is $el->get_attribute_ns ('htoge', 'aa:fuga'), undef;

  done $c;
} n => 4, name => 'remove_attribute namespaced prefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('htoge', 'aa:fuga' => '');
  
  $el->remove_attribute_ns ('htoge', 'fuga');

  is $el->get_attribute ('fuga'), undef;
  is $el->get_attribute_ns ('htoge', 'fuga'), undef;

  done $c;
} n => 2, name => 'remove_attribute_ns namespaced prefixed attr';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('abc', 'hoge' => 'fuga1');
  $el->set_attribute_ns (undef, 'hoge' => 'fuga2');

  $el->remove_attribute ('hoge');

  is $el->get_attribute_ns (undef, 'hoge'), 'fuga2';
  is $el->get_attribute_ns ('abc', 'hoge'), undef;

  done $c;
} n => 2, name => 'remove_attribute multiple attrs with same name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns (undef, 'hoge' => '1');

  $el->remove_attribute ('HOGE');
  is $el->get_attribute_ns (undef, 'hoge'), '1';

  $el->remove_attribute ('HoGe');
  is $el->get_attribute_ns (undef, 'hoge'), '1';

  $el->remove_attribute ('hoge');
  is $el->get_attribute_ns (undef, 'hoge'), undef;

  done $c;
} n => 3, name => 'remove_attribute case-sensitivity xml';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns (undef, 'hoge' => '1');

  $el->remove_attribute ('HOGE');
  is $el->get_attribute_ns (undef, 'hoge'), undef;

  done $c;
} n => 1, name => 'remove_attribute case-sensitivity html';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns ('gg', 'fuga:hoge' => '1');

  $el->remove_attribute ('FuGA:HOGE');
  is $el->get_attribute_ns ('gg', 'hoge'), undef;

  done $c;
} n => 1, name => 'remove_attribute case-sensitivity html, namespaced';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  $doc->manakai_is_html (1);
  my $el = $doc->create_element ('a');
  $el->set_attribute_ns (undef, 'hOGe' => '1');

  $el->remove_attribute ('hoge');
  is $el->get_attribute_ns (undef, 'hOGe'), '1';

  done $c;
} n => 1, name => 'remove_attribute case-sensitivity html, uppercase';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
