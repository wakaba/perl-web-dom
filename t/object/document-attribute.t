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
  my $doc = Web::DOM::Document->new;

  my $attr = $doc->create_attribute ('abc');
  isa_ok $attr, 'Web::DOM::Attr';
  is $attr->node_type, 2;
  is $attr->prefix, undef;
  is $attr->namespace_uri, undef;
  is $attr->manakai_local_name, q<abc>;
  is $attr->name, q<abc>;
  is $attr->owner_document, $doc;
  is $attr->attributes, undef;
  is $attr->owner_element, undef;
  is $attr->value, '';
  ok $attr->specified;

  done $c;
} n => 11, name => 'create_attribute / XML, Name';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  $doc->manakai_is_html (1);

  my $attr = $doc->create_attribute ('abc');
  isa_ok $attr, 'Web::DOM::Attr';
  is $attr->node_type, 2;
  is $attr->prefix, undef;
  is $attr->namespace_uri, undef;
  is $attr->manakai_local_name, q<abc>;
  is $attr->name, q<abc>;
  is $attr->owner_document, $doc;
  is $attr->attributes, undef;
  is $attr->owner_element, undef;
  is $attr->value, '';
  ok $attr->specified;

  done $c;
} n => 11, name => 'create_attribute / HTML, Name';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;

  my $attr = $doc->create_attribute ("abc\x{5000}\x{1E000}");
  isa_ok $attr, 'Web::DOM::Attr';
  is $attr->node_type, 2;
  is $attr->prefix, undef;
  is $attr->namespace_uri, undef;
  is $attr->manakai_local_name, qq<abc\x{5000}\x{1E000}>;
  is $attr->name, qq<abc\x{5000}\x{1E000}>;
  is $attr->owner_document, $doc;
  is $attr->attributes, undef;

  done $c;
} n => 8, name => 'create_attribute / XML, Name non-ASCII';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  $doc->manakai_is_html (1);

  my $attr = $doc->create_attribute ("abc\x{5000}\x{1E000}");
  isa_ok $attr, 'Web::DOM::Attr';
  is $attr->node_type, 2;
  is $attr->prefix, undef;
  is $attr->namespace_uri, undef;
  is $attr->manakai_local_name, qq<abc\x{5000}\x{1E000}>;
  is $attr->name, qq<abc\x{5000}\x{1E000}>;
  is $attr->owner_document, $doc;
  is $attr->attributes, undef;

  done $c;
} n => 8, name => 'create_attribute / HTML, Name non-ASCII';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;

  dies_here_ok {
    $doc->create_attribute ('1abc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The local name is not an XML Name';

  done $c;
} n => 4, name => 'create_attribute / XML, not Name';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  $doc->manakai_is_html (1);

  dies_here_ok {
    $doc->create_attribute ('1abc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The local name is not an XML Name';

  done $c;
} n => 4, name => 'create_attribute / HTML, not Name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute ('v:circle');
  is $attr->prefix, undef;
  is $attr->namespace_uri, undef;
  is $attr->manakai_local_name, 'v:circle';
  done $c;
} n => 3, name => 'create_attribute local name with :';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute (':circle');
  is $attr->prefix, undef;
  is $attr->namespace_uri, undef;
  is $attr->manakai_local_name, ':circle';
  done $c;
} n => 3, name => 'create_attribute local name starting with :';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute ("\x{6000}");
  is $attr->prefix, undef;
  is $attr->namespace_uri, undef;
  is $attr->manakai_local_name, "\x{6000}";
  done $c;
  undef $c;
} n => 3, name => 'create_attribute with non-ASCII local name';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The local name is not an XML Name';
  done $c;
} n => 4, name => 'create_attribute undef';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $attr = $doc->create_attribute_ns (undef, 'hoge');
  isa_ok $attr, 'Web::DOM::Attr';
  is $attr->prefix, undef;
  is $attr->namespace_uri, undef;
  is $attr->manakai_local_name, 'hoge';
  is $attr->owner_document, $doc;
  is $attr->attributes, undef;
  is $attr->owner_element, undef;
  is $attr->value, '';
  ok $attr->specified;

  done $c;
} n => 9, name => 'create_attribute_ns, null ns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $attr = $doc->create_attribute_ns (undef, 'HOGE');
  isa_ok $attr, 'Web::DOM::Attr';
  is $attr->prefix, undef;
  is $attr->namespace_uri, undef;
  is $attr->manakai_local_name, 'HOGE';
  is $attr->owner_document, $doc;
  is $attr->attributes, undef;
  done $c;
} n => 6, name => 'create_attribute_ns, null ns, uppercase';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  
  my $attr = $doc->create_attribute_ns (q<http://www.w3.org/1999/xhtml>, 'Hoge');
  isa_ok $attr, 'Web::DOM::Attr';
  is $attr->prefix, undef;
  is $attr->namespace_uri, q<http://www.w3.org/1999/xhtml>;
  is $attr->manakai_local_name, 'Hoge';
  is $attr->owner_document, $doc;
  is $attr->attributes, undef;
  done $c;
} n => 6, name => 'create_attribute_ns, HTML ns, mixed case';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_ns (q<ho ge>, 'fuga');
  is $attr->prefix, undef;
  is $attr->namespace_uri, q<ho ge>;
  is $attr->manakai_local_name, 'fuga';
  is $attr->owner_element, undef;
  is $attr->value, '';
  ok $attr->specified;

  done $c;
} n => 6, name => 'create_attribute_ns default namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_ns (q<ho ge>, 'abc:fuga');
  is $attr->prefix, 'abc';
  is $attr->namespace_uri, q<ho ge>;
  is $attr->manakai_local_name, 'fuga';
  done $c;
} n => 3, name => 'create_attribute_ns prefixed namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_ns ('', 'fuga');
  is $attr->prefix, undef;
  is $attr->namespace_uri, undef;
  is $attr->manakai_local_name, 'fuga';
  done $c;
} n => 3, name => 'create_attribute_ns empty namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_ns (undef, 'a');
  is $attr->prefix, undef;
  is $attr->namespace_uri, undef;
  is $attr->manakai_local_name, 'a';
  done $c;
}n => 3, name => 'create_attribute_ns name.length = 1';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_ns (undef, '120');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_attribute_ns bad name';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_attribute_ns (undef, ':hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_attribute_ns bad qname';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_attribute_ns (undef, 'hoge:');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_attribute_ns bad qname';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_attribute_ns (undef, ':');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_attribute_ns bad qname';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_attribute_ns (q<fuga>, 'hoge:120');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_attribute_ns bad qname';

test {
  my $c = shift;
  my $doc = Web::DOM::Document->new;
  dies_here_ok {
    $doc->create_attribute_ns (undef, 'hoge:fuga:abbc');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'The qualified name is not an XML QName';
  done $c;
} n => 4, name => 'create_attribute_ns bad qname';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_ns (undef, q<h:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';
  done $c;
} n => 4, name => 'create_attribute_ns null namespaced prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_ns (undef, q<xml:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';
  done $c;
} n => 4, name => 'create_attribute_ns null namespaced prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_ns (undef, q<xmlns:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';
  done $c;
} n => 4, name => 'create_attribute_ns null namespaced prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_ns (q<http://hoge/fuga>, q<xml:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Prefix |xml| cannot be bound to anything other than XML namespace';
  done $c;
} n => 4, name => 'create_attribute_ns xml namespace prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_ns (q<http://www.w3.org/XML/1998/namespace>, q<xml:Father>);
  is $attr->prefix, 'xml';
  is $attr->namespace_uri, q<http://www.w3.org/XML/1998/namespace>;
  is $attr->manakai_local_name, q<Father>;
  done $c;
} n => 3, name => 'create_attribute_ns xml namespace prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_ns (q<http://www.w3.org/XML/1998/namespace>, q<nonxml:Father>);
  is $attr->prefix, 'nonxml';
  is $attr->namespace_uri, q<http://www.w3.org/XML/1998/namespace>;
  is $attr->manakai_local_name, q<Father>;
  done $c;
} n => 3, name => 'create_attribute_ns xml namespace URL';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_ns (q<http://www.w3.org/XML/1998/namespace>, q<Father>);
  is $attr->prefix, undef;
  is $attr->namespace_uri, q<http://www.w3.org/XML/1998/namespace>;
  is $attr->manakai_local_name, q<Father>;
  done $c;
} n => 3, name => 'create_attribute_ns xml namespace URL';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_ns (q<http://hoge/fuga>, q<xmlns:Fuga>);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  done $c;
} n => 4, name => 'create_attribute_ns xmlns namespace prefix';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_ns (undef, 'xmlns');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  done $c;
} n => 4, name => 'create_attribute_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_ns ('http://hoge/', 'xmlns');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  done $c;
} n => 4, name => 'create_attribute_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_ns (undef, 'xmlns:hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'Namespace prefix cannot be bound to the null namespace';
  done $c;
} n => 4, name => 'create_attribute_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_ns ('http://hpoge', 'xmlns:hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message,
      'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  done $c;
} n => 4, name => 'create_attribute_ns xmlns';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_ns ('http://www.w3.org/2000/xmlns/', 'hloge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';
  done $c;
} n => 4, name => 'create_attribute_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_ns ('http://www.w3.org/2000/xmlns/', 'fuga:hloge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NamespaceError';
  is $@->message, 'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';
  done $c;
} n => 4, name => 'create_attribute_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns');
  is $attr->prefix, undef;
  is $attr->namespace_uri, 'http://www.w3.org/2000/xmlns/';
  is $attr->manakai_local_name, 'xmlns';
  done $c;
} n => 3, name => 'create_attribute_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:xmlns');
  is $attr->prefix, 'xmlns';
  is $attr->namespace_uri, 'http://www.w3.org/2000/xmlns/';
  is $attr->manakai_local_name, 'xmlns';
  done $c;
} n => 3, name => 'create_attribute_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $attr = $doc->create_attribute_ns ('http://www.w3.org/2000/xmlns/', 'xmlns:fuga');
  is $attr->prefix, 'xmlns';
  is $attr->namespace_uri, 'http://www.w3.org/2000/xmlns/';
  is $attr->manakai_local_name, 'fuga';
  done $c;
} n => 3, name => 'create_attribute_ns XMLNS namespace';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  dies_here_ok {
    $doc->create_attribute_ns;
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'InvalidCharacterError';
  is $@->message, 'The qualified name is not an XML Name';
  done $c;
} n => 4, name => 'create_attribute_ns undef';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
