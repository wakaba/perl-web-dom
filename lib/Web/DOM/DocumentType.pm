package Web::DOM::DocumentType;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
push our @ISA, qw(Web::DOM::Node);

*node_name = \&name;

sub name ($) {
  return ${${$_[0]}->[2]->{name}};
} # name

sub public_id ($) {
  return ${${$_[0]}->[2]->{public_id}};
} # public_id

sub system_id ($) {
  return ${${$_[0]}->[2]->{system_id}};
} # system_id

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
