package Web::DOM::DocumentType;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
use Web::DOM::ChildNode;
push our @ISA, qw(Web::DOM::Node Web::DOM::ChildNode);

*node_name = \&name;

sub name ($) {
  return ${${$_[0]}->[2]->{name}};
} # name

sub public_id ($) {
  if (@_ > 1) {
    ${${$_[0]}->[2]->{public_id}} = ''.$_[1];
  }
  return ${${$_[0]}->[2]->{public_id}};
} # public_id

sub system_id ($) {
  if (@_ > 1) {
    ${${$_[0]}->[2]->{system_id}} = ''.$_[1];
  }
  return ${${$_[0]}->[2]->{system_id}};
} # system_id

# XXX declaration_base_uri, manakai_declaration_base_uri

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
