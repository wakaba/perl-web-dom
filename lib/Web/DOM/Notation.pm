package Web::DOM::Notation;
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

# XXX manakai_declaration_base_uri

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
