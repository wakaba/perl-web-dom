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
  my $doc = Web::DOM::Document->new;

  my $el = $doc->create_element ('abc');
  isa_ok $el, 'Web::DOM::Element';
  is $el->node_type, 1;
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $el->manakai_local_name, q<abc>;
  is $el->tag_name, q<abc>;
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;

  done $c;
} n => 8, name => 'create_element / XML, Name';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  $doc->manakai_is_html (1);

  my $el = $doc->create_element ('abc');
  isa_ok $el, 'Web::DOM::Element';
  is $el->node_type, 1;
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $el->manakai_local_name, q<abc>;
  is $el->tag_name, q<ABC>;
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;

  done $c;
} n => 8, name => 'create_element / HTML, Name';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;

  my $el = $doc->create_element ("abc\x{5000}\x{1E000}");
  isa_ok $el, 'Web::DOM::Element';
  is $el->node_type, 1;
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $el->manakai_local_name, qq<abc\x{5000}\x{1E000}>;
  is $el->tag_name, qq<abc\x{5000}\x{1E000}>;
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;

  done $c;
} n => 8, name => 'create_element / XML, Name non-ASCII';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  $doc->manakai_is_html (1);

  my $el = $doc->create_element ("abc\x{5000}\x{1E000}");
  isa_ok $el, 'Web::DOM::Element';
  is $el->node_type, 1;
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $el->manakai_local_name, qq<abc\x{5000}\x{1E000}>;
  is $el->tag_name, qq<ABC\x{5000}\x{1E000}>;
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;

  done $c;
} n => 8, name => 'create_element / HTML, Name non-ASCII';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;

  dies_here_ok {
    $doc->create_element ('1abc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The local name is not an XML Name';

  done $c;
} n => 4, name => 'create_element / XML, not Name';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  $doc->manakai_is_html (1);

  dies_here_ok {
    $doc->create_element ('1abc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The local name is not an XML Name';

  done $c;
} n => 4, name => 'create_element / HTML, not Name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ('v:circle');
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $el->manakai_local_name, 'v:circle';
  done $c;
} n => 3, name => 'create_element local name with :';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element (':circle');
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $el->manakai_local_name, ':circle';
  done $c;
} n => 3, name => 'create_element local name starting with :';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element ("\x{6000}");
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $el->manakai_local_name, "\x{6000}";
  done $c;
  undef $c;
} n => 3, name => 'create_element with non-ASCII local name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The local name is not an XML Name';
  done $c;
} n => 4, name => 'create_element undef';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el = $doc->create_element_ns (undef, 'hoge');
  isa_ok $el, 'Web::DOM::Element';
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, 'hoge';
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;
  done $c;
} n => 6, name => 'create_element_ns, null ns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el = $doc->create_element_ns (undef, 'HOGE');
  isa_ok $el, 'Web::DOM::Element';
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, 'HOGE';
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;
  done $c;
} n => 6, name => 'create_element_ns, null ns, uppercase';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $el = $doc->create_element_ns (q<http://www.w3.org/1999/xhtml>, 'Hoge');
  isa_ok $el, 'Web::DOM::Element';
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $el->manakai_local_name, 'Hoge';
  is $el->owner_document, $doc;
  is scalar @{$el->attributes}, 0;
  done $c;
} n => 6, name => 'create_element_ns, HTML ns, mixed case';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (q<ho ge>, 'fuga');
  is $el->prefix, undef;
  is $el->namespace_uri, q<ho ge>;
  is $el->manakai_local_name, 'fuga';
  done $c;
} n => 3, name => 'create_element_ns default namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (q<ho ge>, 'abc:fuga');
  is $el->prefix, 'abc';
  is $el->namespace_uri, q<ho ge>;
  is $el->manakai_local_name, 'fuga';
  done $c;
} n => 3, name => 'create_element_ns prefixed namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('', 'fuga');
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, 'fuga';
  done $c;
} n => 3, name => 'create_element_ns empty namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (undef, 'a');
  is $el->prefix, undef;
  is $el->namespace_uri, undef;
  is $el->manakai_local_name, 'a';
  done $c;
}n => 3, name => 'create_element_ns name.length = 1';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (undef, '120');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_element_ns bad name';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_element_ns (undef, ':hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_element_ns bad qname';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_element_ns (undef, 'hoge:');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_element_ns bad qname';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_element_ns (undef, ':');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_element_ns bad qname';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_element_ns (q<fuga>, 'hoge:120');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_element_ns bad qname';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_element_ns (undef, 'hoge:fuga:abbc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_element_ns bad qname';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (undef, q<h:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';
  done $c;
} n => 4, name => 'create_element_ns null namespaced prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (undef, q<xml:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';
  done $c;
} n => 4, name => 'create_element_ns null namespaced prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (undef, q<xmlns:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';
  done $c;
} n => 4, name => 'create_element_ns null namespaced prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (q<http://hoge/fuga>, q<xml:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Prefix |xml| cannot be bound to anything other than XML namespace';
  done $c;
} n => 4, name => 'create_element_ns xml namespace prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (q<http://www.w3.org/XML/1998/namespace>, q<xml:Father>);
  is $el->prefix, 'xml';
  is $el->namespace_uri, q<http://www.w3.org/XML/1998/namespace>;
  is $el->manakai_local_name, q<Father>;
  done $c;
} n => 3, name => 'create_element_ns xml namespace prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (q<http://www.w3.org/XML/1998/namespace>, q<nonxml:Father>);
  is $el->prefix, 'nonxml';
  is $el->namespace_uri, q<http://www.w3.org/XML/1998/namespace>;
  is $el->manakai_local_name, q<Father>;
  done $c;
} n => 3, name => 'create_element_ns xml namespace URL';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns (q<http://www.w3.org/XML/1998/namespace>, q<Father>);
  is $el->prefix, undef;
  is $el->namespace_uri, q<http://www.w3.org/XML/1998/namespace>;
  is $el->manakai_local_name, q<Father>;
  done $c;
} n => 3, name => 'create_element_ns xml namespace URL';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (q<http://hoge/fuga>, q<xmlns:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  done $c;
} n => 4, name => 'create_element_ns xmlns namespace prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (undef, 'xmlns');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  done $c;
} n => 4, name => 'create_element_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns ('http://hoge/', 'xmlns');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  done $c;
} n => 4, name => 'create_element_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns (undef, 'xmlns:hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';
  done $c;
} n => 4, name => 'create_element_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns ('http://hpoge', 'xmlns:hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  done $c;
} n => 4, name => 'create_element_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns ('http://www.w3.org/2000/xmlns/', 'hloge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';
  done $c;
} n => 4, name => 'create_element_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns ('http://www.w3.org/2000/xmlns/', 'fuga:hloge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';
  done $c;
} n => 4, name => 'create_element_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/xmlns/', 'xmlns');
  is $el->prefix, undef;
  is $el->namespace_uri, 'http://www.w3.org/2000/xmlns/';
  is $el->manakai_local_name, 'xmlns';
  done $c;
} n => 3, name => 'create_element_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $el = $doc->create_element_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:fuga');
  is $el->prefix, 'xmlns';
  is $el->namespace_uri, 'http://www.w3.org/2000/xmlns/';
  is $el->manakai_local_name, 'fuga';
  done $c;
} n => 3, name => 'create_element_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_element_ns;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_element_ns undef';

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

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_processing_instruction ('120', 'fuga');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The target is not an XML Name';
  done $c;
} n => 4, name => 'create_processing_instruction not xml Name';

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
