package Web::DOM::Document;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
push our @ISA, qw(Web::DOM::Node);
use Web::DOM::Internal;

sub new ($) {
  my $data = {node_type => DOCUMENT_NODE};
  my $objs = Web::DOM::Internal::Objects->new;
  my $id = $objs->add_data ($data);
  $objs->{rc}->[$id]++;
  return $objs->node ($id);
} # new

sub create_element ($$) {
  my $self = shift;
  # XXX
  my $data = {local_name => $_[0], node_type => ELEMENT_NODE};
  my $id = $$self->[0]->add_data ($data);
  return $$self->[0]->node ($id);
} # create_element

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
