package Web::DOM::Entity;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
push our @ISA, qw(Web::DOM::Node);
use Web::DOM::Internal;

*node_name = \&name;

sub name ($) {
  return ${${$_[0]}->[2]->{name}};
} # name

sub public_id ($) {
  if (@_ > 1) {
    ${$_[0]}->[2]->{public_id} = Web::DOM::Internal->text
        (defined $_[1] ? ''.$_[1] : '');
  }
  return ${${$_[0]}->[2]->{public_id}};
} # public_id

sub system_id ($) {
  if (@_ > 1) {
    ${$_[0]}->[2]->{system_id} = Web::DOM::Internal->text
        (defined $_[1] ? ''.$_[1] : '');
  }
  return ${${$_[0]}->[2]->{system_id}};
} # system_id

# XXX manakai_declaration_base_uri, declaration_base_uri

# XXX manakai_entity_base_uri

# XXX manakai_entity_uri

sub input_encoding ($) {
  if (@_ > 1) {
    ${${$_[0]}->[2]->{input_encoding}} = ''.$_[1];
  }
  return ${${$_[0]}->[2]->{input_encoding}};
} # input_encoding

sub xml_version ($) {
  if (@_ > 1) {
    ${${$_[0]}->[2]->{xml_version}} = ''.$_[1];
  }
  return ${${$_[0]}->[2]->{xml_version}};
} # xml_version

sub xml_encoding ($) {
  if (@_ > 1) {
    ${${$_[0]}->[2]->{xml_encoding}} = ''.$_[1];
  }
  return ${${$_[0]}->[2]->{xml_encoding}};
} # xml_encoding

# XXX has_replacement_tree

sub notation_name ($) {
  if (@_ > 1) {
    ${${$_[0]}->[2]->{notation_name}} = ''.$_[1];
  }
  return ${${$_[0]}->[2]->{notation_name}};
} # notation_name

sub is_externally_declared ($) {
  if (@_ > 1) {
    ${${$_[0]}->[2]->{is_externally_declared}} = ''.$_[1];
  }
  return ${${$_[0]}->[2]->{is_externally_declared}};
} # is_externally_declared

sub manakai_charset ($;$) {
  if (@_ > 1) {
    if (defined $_[1]) {
      ${$_[0]}->[2]->{manakai_charset} = ''.$_[1];
    } else {
      delete ${$_[0]}->[2]->{manakai_charset};
    }
  }
  return ${$_[0]}->[2]->{manakai_charset};
} # manakai_charset

sub manakai_has_dom {
  if (@_ > 1) {
    if ($_[1]) {
      ${$_[0]}->[2]->{manakai_has_bom} = 1;
    } else {
      delete ${$_[0]}->[2]->{manakai_has_bom};
    }
  }
  return ${$_[0]}->[2]->{manakai_has_bom};
} # manakai_has_dom

sub owner_document_type_definition ($) {
  if (my $id = ${$_[0]}->[2]->{owner_document_type_definition}) {
    return ${$_[0]}->[0]->node ($id);
  } else {
    return undef;
  }
} # owner_document_type_definition

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
