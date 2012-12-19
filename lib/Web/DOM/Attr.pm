package Web::DOM::Attr;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
push our @ISA, qw(Web::DOM::Node);

*node_name = \&name;

# XXX
sub name ($) {
  if (${$_[0]}->[2]->{prefix}) {
    return ${${$_[0]}->[2]->{prefix}} . ':' . ${${$_[0]}->[2]->{local_name}};
  } else {
    return ${${$_[0]}->[2]->{local_name}};
  }
} # name

# XXX
sub value ($;$) {
  if (@_ > 1) {
    ${$_[0]}->[2]->{value} = $_[1];
  }
  return ${$_[0]}->[2]->{value};
} # value

*node_value = \&value;
*text_content = \&value;

# XXX compat with manakai
sub specified ($) {
  return 1;
} # specified

# XXX
sub owner_element ($) {

} # owner_element

# XXX isId schemaTypeInfo

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
