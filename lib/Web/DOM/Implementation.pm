package Web::DOM::Implementation;
use strict;
use warnings;
our $VERSION = '1.0';
use Carp;
use Web::DOM::Node;
use Web::DOM::Internal;

use overload
    '""' => sub {
      return ref ($_[0]) . '=DOM(' . ${$_[0]}->[0] . ')';
    },
    bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    fallback => 1;

sub new ($) {
  require Web::DOM::Document;
  my $doc = Web::DOM::Document->new;
  return $doc->implementation;
} # new

sub create_document ($;$$$) {
  my ($self, $ns, $qn, $doctype) = @_;

  # 1.
  my $data = {node_type => DOCUMENT_NODE, is_XMLDocument => 1};
  my $objs = Web::DOM::Internal::Objects->new;
  my $id = $objs->add_data ($data);
  $objs->{rc}->[$id]++;
  my $doc = $objs->node ($id);

  # 2.
  my $el;

  # 3.
  if (defined $qn and length $qn) {
    $el = $doc->create_element_ns ($ns, $qn); # or throw
  }

  # 4.
  $doc->append_child ($doctype) if defined $doctype;

  # 5.
  $doc->append_child ($el) if defined $el;

  # 6.
  return $doc;
} # create_document

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
