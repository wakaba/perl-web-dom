package Web::DOM::Attr;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
push our @ISA, qw(Web::DOM::Node);

*node_name = \&name;
*manakai_name = \&name;

sub name ($) {
  if (${$_[0]}->[2]->{prefix}) {
    return ${${$_[0]}->[2]->{prefix}} . ':' . ${${$_[0]}->[2]->{local_name}};
  } else {
    return ${${$_[0]}->[2]->{local_name}};
  }
} # name

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

# XXX isId schemaTypeInfo

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
