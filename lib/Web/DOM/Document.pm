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

sub manakai_is_html ($;$) {
  my $self = $_[0];
  if (@_ > 1) {
    if ($_[1]) {
      $$self->[2]->{is_html} = 1;
    } else {
      delete $$self->[2]->{is_html};
      delete $$self->[2]->{compat_mode};
    }
  }
  return $$self->[2]->{is_html};
} # manakai_is_html

sub content_type ($) {
  return ${$_[0]}->[2]->{content_type} || 'application/xml';
} # content_type

sub character_set ($) {
  return ${$_[0]}->[2]->{encoding} || 'utf-8';
} # character_set

sub url ($) {
  return ${$_[0]}->[2]->{url} || 'about:blank';
} # url

*document_uri = \&url;

sub compat_mode ($) {
  my $self = $_[0];
  if ($$self->[2]->{is_html}) {
    if (defined $$self->[2]->{compat_mode} and
        $$self->[2]->{compat_mode} eq 'quirks') {
      return 'BackCompat';
    }
  }
  return 'CSS1Compat';
} # compat_mode

sub manakai_compat_mode ($;$) {
  my $self = $_[0];
  if ($$self->[2]->{is_html}) {
    if (@_ > 1 and defined $_[1] and
        {'no quirks' => 1, 'limited quirks' => 1, 'quirks' => 1}->{$_[1]}) {
      $$self->[2]->{compat_mode} = $_[1];
    }
    return $$self->[2]->{compat_mode} || 'no quirks';
  } else {
    return 'no quirks';
  }
} # manakai_compat_mode

sub implementation ($) {
  return ${$_[0]}->[0]->impl;
} # implementation

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
