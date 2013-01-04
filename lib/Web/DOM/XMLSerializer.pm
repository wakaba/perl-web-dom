package Web::DOM::XMLSerializer;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::TypeError;
use Web::DOM::Exception;
our @CARP_NOT = qw(Web::DOM::TypeError Web::DOM::Exception);
use Web::DOM::Node;

sub new ($) {
  return bless {}, $_[0];
} # new

sub serialize_to_string ($$) {
  # WebIDL
  unless (UNIVERSAL::isa ($_[1], 'Web::DOM::Node')) {
    _throw Web::DOM::TypeError 'The argument is not a Node';
  }

  my $nt = $_[1]->node_type;
  if ($nt == ATTRIBUTE_NODE or
      $nt == ELEMENT_TYPE_DEFINITION_NODE or
      $nt == ATTRIBUTE_DEFINITION_NODE or
      $nt == ENTITY_NODE or
      $nt == NOTATION_NODE) {
    _throw Web::DOM::Exception 'NotSupportedError',
        'The node cannot be serialized';
  }

  if (($_[1]->owner_document || $_[1])->manakai_is_html) {
    require Web::HTML::Serializer;
    return ${Web::HTML::Serializer->new->get_inner_html ([$_[1]])};
  } else {
    require Web::XML::Serializer;
    return ${Web::XML::Serializer->new->get_inner_html ([$_[1]])};
  }
} # serialize_to_string

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
