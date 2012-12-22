package Web::DOM::Text;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::CharacterData;
push our @ISA, qw(Web::DOM::CharacterData);
use Web::DOM::Node;

sub node_name ($) {
  return '#text';
} # node_name

# XXX isElementContentWhitespace

# XXX splitText

sub whole_text ($) {
  my $self = shift;
  my $parent = $self->parent_node or return $self->data;
  my $found;
  my @text;
  for my $node ($parent->child_nodes->to_list) {
    if ($node->node_type == TEXT_NODE) {
      push @text, $node;
      $found = 1 if $node eq $self;
    } else {
      if ($found and @text) {
        return join '', map { $_->data } @text;
      }
      @text = ();
    }
  }
  if ($found and @text) {
    return join '', map { $_->data } @text;
  }
  die "The node not found...";
} # whole_text

# XXX replaceWholeText

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
