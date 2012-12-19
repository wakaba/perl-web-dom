package Web::DOM::Document;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '1.0';
use Web::DOM::Node;
use Web::DOM::RootNode;
push our @ISA, qw(Web::DOM::Node Web::DOM::RootNode);
use Web::DOM::Internal;
use Web::DOM::Exception;
use Char::Class::XML qw(
  InXMLNameChar InXMLNameStartChar
  InXMLNCNameChar InXMLNCNameStartChar
);

sub new ($) {
  my $data = {node_type => DOCUMENT_NODE};
  my $objs = Web::DOM::Internal::Objects->new;
  my $id = $objs->add_data ($data);
  $objs->{rc}->[$id]++;
  return $objs->node ($id);
} # new

sub node_name ($) {
  return '#document';
} # node_name

sub owner_document ($) {
  return undef;
} # owner_document

sub manakai_is_html ($;$) {
  my $self = $_[0];
  if (@_ > 1) {
    if ($_[1]) {
      $$self->[2]->{is_html} = 1;
      $$self->[2]->{content_type} = 'text/html';
    } else {
      delete $$self->[2]->{is_html};
      delete $$self->[2]->{compat_mode};
      delete $$self->[2]->{content_type};
    }
    for my $cols (@{$$self->[0]->{cols} or []}) {
      next unless $cols;
      for my $key (keys %$cols) {
        next unless $cols->{$key};
        delete ${$cols->{$key}}->[2];
      }
    }
  }
  return $$self->[2]->{is_html};
} # manakai_is_html

sub content_type ($) {
  return ${$_[0]}->[2]->{content_type} || 'application/xml';
} # content_type

sub character_set ($) {
  return ${$_[0]}->[2]->{encoding} || 'utf-8';
} # character_set

sub url ($) {
  return ${$_[0]}->[2]->{url} || 'about:blank';
} # url

*document_uri = \&url;

sub compat_mode ($) {
  my $self = $_[0];
  if ($$self->[2]->{is_html}) {
    if (defined $$self->[2]->{compat_mode} and
        $$self->[2]->{compat_mode} eq 'quirks') {
      return 'BackCompat';
    }
  }
  return 'CSS1Compat';
} # compat_mode

sub manakai_compat_mode ($;$) {
  my $self = $_[0];
  if ($$self->[2]->{is_html}) {
    if (@_ > 1 and defined $_[1] and
        {'no quirks' => 1, 'limited quirks' => 1, 'quirks' => 1}->{$_[1]}) {
      $$self->[2]->{compat_mode} = $_[1];
    }
    return $$self->[2]->{compat_mode} || 'no quirks';
  } else {
    return 'no quirks';
  }
} # manakai_compat_mode

sub implementation ($) {
  return ${$_[0]}->[0]->impl;
} # implementation

sub create_element ($$) {
  my $self = $_[0];
  my $ln = ''.$_[1];

  # XXX strictErrorChecking

  # 1.
  unless ($ln =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The local name is not an XML Name';
  }

  # 2.
  if ($$self->[2]->{is_html}) {
    $ln =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  # 3.
  my $data = {node_type => ELEMENT_NODE,
              namespace_uri => Web::DOM::Internal->text (HTML_NS),
              local_name => Web::DOM::Internal->text ($ln)};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_element

sub create_element_ns {
  my $self = $_[0];
  my $qname = ''.$_[2];

  # XXX DOMPERL's handling of $qname
  # XXX strictErrorChecking

  # 1.
  my $nsurl = defined $_[1] ? length $_[1] ? ''.$_[1] : undef : undef;

  # 2.
  unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The qualified name is not an XML Name';
  }

  # 3.
  unless ($qname =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*(?::\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*)?\z/) {
    _throw Web::DOM::Exception 'NamespaceError',
        'The qualified name is not an XML QName';
  }

  # 4.
  my ($prefix, $ln) = split /:/, $qname, 2;
  ($prefix, $ln) = (undef, $prefix) unless defined $ln;

  # 5.
  if (defined $prefix and not defined $nsurl) {
    _throw Web::DOM::Exception 'NamespaceError',
        'Namespace prefix cannot be bound to the null namespace';
  }

  # 6.
  if (defined $prefix and $prefix eq 'xml' and
      (not defined $nsurl or $nsurl ne XML_NS)) {
    _throw Web::DOM::Exception 'NamespaceError',
        'Prefix |xml| cannot be bound to anything other than XML namespace';
  }

  # 7.
  if (($qname eq 'xmlns' or (defined $prefix and $prefix eq 'xmlns')) and
      (not defined $nsurl or $nsurl ne XMLNS_NS)) {
    _throw Web::DOM::Exception 'NamespaceError',
        'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  }

  # 8.
  if (defined $nsurl and $nsurl eq XMLNS_NS and
      not ($qname eq 'xmlns' or (defined $prefix and $prefix eq 'xmlns'))) {
    _throw Web::DOM::Exception 'NamespaceError',
        'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';
  }

  # 9.
  my $data = {node_type => ELEMENT_NODE,
              prefix => Web::DOM::Internal->text ($prefix),
              namespace_uri => Web::DOM::Internal->text ($nsurl),
              local_name => Web::DOM::Internal->text ($ln)};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_element_ns

sub create_attribute ($$) {
  my $self = $_[0];
  my $ln = ''.$_[1];

  # XXX strictErrorChecking

  # 1.
  unless ($ln =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The local name is not an XML Name';
  }

  # 2.
  my $data = {node_type => ATTRIBUTE_NODE,
              local_name => Web::DOM::Internal->text ($ln),
              value => ''};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_attribute

sub create_attribute_ns {
  my $self = $_[0];
  my $qname = ''.$_[2];

  # XXX DOMPERL's handling of $qname
  # XXX strictErrorChecking

  # 1.
  my $nsurl = defined $_[1] ? length $_[1] ? ''.$_[1] : undef : undef;

  # 2.
  unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The qualified name is not an XML Name';
  }

  # 3.
  unless ($qname =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*(?::\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*)?\z/) {
    _throw Web::DOM::Exception 'NamespaceError',
        'The qualified name is not an XML QName';
  }

  # 4.
  my ($prefix, $ln) = split /:/, $qname, 2;
  ($prefix, $ln) = (undef, $prefix) unless defined $ln;

  # 5.
  if (defined $prefix and not defined $nsurl) {
    _throw Web::DOM::Exception 'NamespaceError',
        'Namespace prefix cannot be bound to the null namespace';
  }

  # 6.
  if (defined $prefix and $prefix eq 'xml' and
      (not defined $nsurl or $nsurl ne XML_NS)) {
    _throw Web::DOM::Exception 'NamespaceError',
        'Prefix |xml| cannot be bound to anything other than XML namespace';
  }

  # 7.
  if (($qname eq 'xmlns' or (defined $prefix and $prefix eq 'xmlns')) and
      (not defined $nsurl or $nsurl ne XMLNS_NS)) {
    _throw Web::DOM::Exception 'NamespaceError',
        'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  }

  # 8.
  if (defined $nsurl and $nsurl eq XMLNS_NS and
      not ($qname eq 'xmlns' or (defined $prefix and $prefix eq 'xmlns'))) {
    _throw Web::DOM::Exception 'NamespaceError',
        'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';
  }

  # 9.
  my $data = {node_type => ATTRIBUTE_NODE,
              prefix => Web::DOM::Internal->text ($prefix),
              namespace_uri => Web::DOM::Internal->text ($nsurl),
              local_name => Web::DOM::Internal->text ($ln),
              value => ''};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_attribute_ns

sub create_document_fragment ($) {
  my $id = ${$_[0]}->[0]->add_data ({node_type => DOCUMENT_FRAGMENT_NODE});
  return ${$_[0]}->[0]->node ($id);
} # create_document_fragment

sub create_text_node ($) {
  my $id = ${$_[0]}->[0]->add_data
      ({node_type => TEXT_NODE, data => \(''.$_[1])});
  return ${$_[0]}->[0]->node ($id);
} # create_text_node

sub create_cdata_section ($) {
  _throw Web::DOM::Exception 'NotSupportedError',
      'CDATASection is obsolete';
} # create_cdata_section

sub create_comment ($) {
  my $id = ${$_[0]}->[0]->add_data
      ({node_type => COMMENT_NODE, data => \(''.$_[1])});
  return ${$_[0]}->[0]->node ($id);
} # create_comment

sub create_entity_reference ($) {
  _throw Web::DOM::Exception 'NotSupportedError',
      'EntityReference is obsolete';
} # create_entity_reference

sub create_processing_instruction ($$$) {
  my $self = $_[0];
  my $target = ''.$_[1];
  my $data = ''.$_[2];

  # 1.
  unless ($target =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The target is not an XML Name';
  }

  # 2.
  if ($data =~ /\?>/) {
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The data cannot contain ?>';
  }
  
  # 3.
  my $id = $$self->[0]->add_data
      ({node_type => PROCESSING_INSTRUCTION_NODE,
        target => Web::DOM::Internal->text ($target), data => \$data});
  return $$self->[0]->node ($id);
} # create_processing_instruction

# XXX importNode

# XXX adoptNode

# XXX createEvent

# XXX createRange

# XXX createNodeIterator

# XXX createTreeWalker

# XXX get*
# XXX doctype
# XXX documentElement

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
