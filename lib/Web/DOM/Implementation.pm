package Web::DOM::Implementation;
use strict;
use warnings;
our $VERSION = '1.0';
use Carp;
our @CARP_NOT = qw(Web::DOM::Document Web::DOM::TypeError);
use Web::DOM::Node;
use Web::DOM::Internal;
use Web::DOM::TypeError;
use Web::DOM::Exception;
use Char::Class::XML qw(
  InXMLNameChar InXMLNameStartChar
  InXMLNCNameChar InXMLNCNameStartChar
);

use overload
    '""' => sub {
      return ref ($_[0]) . '=DOM(' . ${$_[0]}->[0] . ')';
    },
    bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    fallback => 1;

sub new ($) {
  require Web::DOM::Document;
  my $doc = Web::DOM::Document->new;
  return $doc->implementation;
} # new

sub create_document ($;$$$) {
  my ($self, $ns, $qn, $doctype) = @_;

  # WebIDL
  if (defined $doctype and
      not UNIVERSAL::isa ($doctype, 'Web::DOM::DocumentType')) {
    _throw Web::DOM::TypeError 'Third argument is not a DocumentType';
  }

  # 1.
  my $data = {node_type => DOCUMENT_NODE, is_XMLDocument => 1};
  my $objs = Web::DOM::Internal::Objects->new;
  my $id = $objs->add_data ($data);
  $objs->{rc}->[$id]++;
  my $doc = $objs->node ($id);

  # 2.
  my $el;

  # 3.
  if (defined $qn and length $qn) {
    $el = $doc->create_element_ns ($ns, $qn); # or throw
  }

  # 4.
  $doc->append_child ($doctype) if defined $doctype;

  # 5.
  $doc->append_child ($el) if defined $el;

  # 6.
  return $doc;
} # create_document

sub create_html_document ($;$) {
  # 1.
  require Web::DOM::Document;
  my $doc = Web::DOM::Document->new;

  # 2., 3.
  $doc->manakai_is_html (1);

  # 4.
  my $dt = $doc->implementation->create_document_type ('html', '', '');
  $doc->append_child ($dt);

  # 5.
  my $html = $doc->create_element ('html');
  $doc->append_child ($html);

  # 6.
  my $head = $doc->create_element ('head');
  $html->append_child ($head);

  # 7.
  if (defined $_[1]) {
    # 1.
    my $title = $doc->create_element ('title');
    $head->append_child ($title);

    # 2.
    my $text = $doc->create_text_node ($_[1]);
    $title->append_child ($text);
  }

  # 8.
  my $body = $doc->create_element ('body');
  $html->append_child ($body);
  
  # 9.
  return $doc;
} # create_html_document

sub create_document_type ($$$$) {
  my $self = $_[0];

  # 1.
  my $qname = $_[1];
  unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The qualified name is not an XML Name';
  }

  # 2.
  unless ($qname =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*(?::\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*)?\z/) {
    _throw Web::DOM::Exception 'NamespaceError',
        'The qualified name is not an XML QName';
  }

  # 3.
  my $data = {node_type => DOCUMENT_TYPE_NODE,
              name => Web::DOM::Internal->text ($qname),
              public_id => Web::DOM::Internal->text (''.$_[2]),
              system_id => Web::DOM::Internal->text (''.$_[3])};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_document_type

sub has_feature ($$;$) {
  my $feature = ''.$_[1];

  # 1.
  $feature =~ tr/A-Z/a-z/; ## ASCII case-insensitive.
  if ($feature =~ m{\Ahttp://www\.w3\.org/tr/svg} or
      $feature =~ m{\Aorg\.w3c\.dom\.svg} or
      $feature =~ m{\Aorg\.w3c\.svg}) {
    # 1.
    my $version = defined $_[2] ? ''.$_[2] : '';
    if ($version eq '') {
      # 1.
      # XXX
      return 0;
    }
    
    # 2.
    # XXX
    return 0;
  }

  # 2.
  return 1;
} # has_feature

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
