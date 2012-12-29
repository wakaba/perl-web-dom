package Web::DOM::ElementTypeDefinition;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
push our @ISA, qw(Web::DOM::Node);

sub node_name ($) {
  return ${${$_[0]}->[2]->{node_name}};
} # node_name

sub owner_document_type_definition ($) {
  if (my $id = ${$_[0]}->[2]->{owner_document_type_definition}) {
    return ${$_[0]}->[0]->node ($id);
  } else {
    return undef;
  }
} # owner_document_type_definition

sub attribute_definitions ($) {
  return ${$_[0]}->[0]->collection ('attribute_definitions', $_[0], sub {
    return @{${$_[0]}->[2]->{attribute_definitions} or []};
  });
} # attribute_definitions

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
