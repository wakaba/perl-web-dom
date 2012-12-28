package Web::DOM::Attr;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
push our @ISA, qw(Web::DOM::Node);
use Exporter::Lite;

*node_name = \&name;
*manakai_name = \&name;

sub name ($) {
  if (${$_[0]}->[2]->{prefix}) {
    return ${${$_[0]}->[2]->{prefix}} . ':' . ${${$_[0]}->[2]->{local_name}};
  } else {
    return ${${$_[0]}->[2]->{local_name}};
  }
} # name

sub is_id ($) {
  return (not ${$_[0]}->[2]->{namespace_uri} and
          ${${$_[0]}->[2]->{local_name}} eq 'id');
} # is_id

sub value ($;$) {
  if (@_ > 1) {
    # XXX mutation?
    ${$_[0]}->[2]->{value} = $_[1];
  }
  return ${$_[0]}->[2]->{value};
} # value

*node_value = \&value;
*text_content = \&value;

sub specified ($) { 1 }

sub owner_element ($) {
  if (my $id = ${$_[0]}->[2]->{owner_element}) {
    return ${$_[0]}->[0]->node ($id);
  } else {
    return undef;
  }
} # owner_element

## |DeclaredValueType|
sub NO_TYPE_ATTR () { 0 }
sub CDATA_ATTR () { 1 }
sub ID_ATTR () { 2 }
sub IDREF_ATTR () { 3 }
sub IDREFS_ATTR () { 4 }
sub ENTITY_ATTR () { 5 }
sub ENTITIES_ATTR () { 6 }
sub NMTOKEN_ATTR () { 7 }
sub NMTOKENS_ATTR () { 8 }
sub NOTATION_ATTR () { 9 }
sub ENUMERATION_ATTR () { 10 }
sub UNKNOWN_ATTR () { 11 }

our @EXPORT = qw(
  NO_TYPE_ATTR CDATA_ATTR ID_ATTR IDREF_ATTR IDREFS_ATTR ENTITY_ATTR
  ENTITIES_ATTR NMTOKEN_ATTR NMTOKENS_ATTR NOTATION_ATTR ENUMERATION_ATTR
  UNKNOWN_ATTR
);

sub manakai_attribute_type ($;$) {
  if (@_ > 1) {
    ${$_[0]}->[2]->{attribute_type} = $_[1] % 2**16;
  }
  return ${$_[0]}->[2]->{attribute_type} || 0;
} # manakai_attribute_type

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
