package Web::DOM::RootNode;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
use Web::DOM::Internal;

sub get_elements_by_tag_name ($$) {
  my $self = $_[0];
  my $ln = ''.$_[1];
  return $$self->[0]->collection ('by_tag_name'. $; . $ln, $self, sub {
    my $node = $_[0];
    my $ln2 = $ln;
    my $is_html = $$self->[0]->{data}->[0]->{is_html};
    $ln2 =~ tr/A-Z/a-z/ if $is_html; ## ASCII lowercase.
    my $data = $$node->[0]->{data};
    my @node_id = @{$data->[$$node->[1]]->{child_nodes} or []};
    my @id;
    while (@node_id) {
      my $id = shift @node_id;
      next unless $data->[$id]->{node_type} == ELEMENT_NODE;
      unshift @node_id, @{$data->[$id]->{child_nodes} or []};
      next unless $ln eq '*' or
          (${$data->[$id]->{local_name}} eq $ln2 and
           ${$data->[$id]->{namespace_uri} || \''} eq HTML_NS) or
          (${$data->[$id]->{local_name}} eq $ln and
           (not $is_html or ${$data->[$id]->{namespace_uri} || \''} ne HTML_NS));
      push @id, $id;
    }
    return @id;
  });
} # get_elements_by_tag_name

sub get_elements_by_tag_name_ns ($$$) {
  my $self = $_[0];
  my $ns = defined $_[1] ? ''.$_[1] : '';
  my $ln = ''.$_[2];

  # 1. 
  undef $ns if $ns eq '';

  my $key = join $;, map {
    defined $_ ? do {
      s/($;|\x00)/\x00$1/g;
      $_;
    } : '';
  } $ns, $ln;
  return $$self->[0]->collection ('by_tag_name_ns'. $; . $key, $self, sub {
    my $node = $_[0];
    my $data = $$node->[0]->{data};
    my @node_id = @{$data->[$$node->[1]]->{child_nodes} or []};
    my @id;
    while (@node_id) {
      my $id = shift @node_id;
      next unless $data->[$id]->{node_type} == ELEMENT_NODE;
      unshift @node_id, @{$data->[$id]->{child_nodes} or []};
      next unless ($ln eq '*' or ${$data->[$id]->{local_name}} eq $ln) and
          ((not defined $ns and not defined $data->[$id]->{namespace_uri}) or
           (defined $ns and $ns eq '*') or
           (defined $ns and ${$data->[$id]->{namespace_uri} || \''} eq $ns));
      push @id, $id;
    }
    return @id;
  });
} # get_elements_by_tag_name_ns

# XXX get_elements_by_class_name

sub text_content ($;$) {
  if (@_ > 1) {
    my $self = $_[0];

    # 1.-2.
    my $node;
    $node = $_[0]->owner_document->create_text_node ($_[1]) if length $_[1];
    my $int = $$self->[0];

    # 3. Replace all
    my @replaced;
    {
      # Replace 1.
      # adopt

      # Replace 2. Remove
      for my $node_id (@{$$self->[2]->{child_nodes} or []}) {
        # XXX range
        # XXX mutation
        #$int->children_changed ($$self->[1], ???_NODE); # redundant
        delete $int->{data}->[$node_id]->{parent_node};
        $int->disconnect ($node_id);
        # don't include $node_id to new child_nodes
      }
      @replaced = map { $int->node ($_) } @{$$self->[2]->{child_nodes} or []};

      # Replace 3. Insert (simplified)
      if (defined $node) {
        # XXX range
        $$node->[2]->{parent_node} = $$self->[1];
        @{$$self->[2]->{child_nodes} ||= []} = $$node->[1];
        $int->connect ($$node->[1] => $$self->[1]);
        #$int->children_changed ($$self->[1], TEXT_NODE); # redundant
      } else {
        @{$$self->[2]->{child_nodes} ||= []} = ();
        #$int->children_changed ($$self->[1], TEXT_NODE); # redundant
      }
    }

    # 4.-5.
    # XXXmutation

    # 6.
    $int->children_changed ($$self->[1], ELEMENT_NODE);
    # XXX node is removed

    return unless defined wantarray;
  } # setter

  my @text;
  my @node = $_[0]->child_nodes->to_list;
  while (@node) {
    my $node = shift @node;
    my $nt = $node->node_type;
    if ($nt == TEXT_NODE) {
      push @text, $node;
    } elsif ($nt == ELEMENT_NODE) {
      unshift @node, $node->child_nodes->to_list;
    }
  }
  return join '', map { $_->data } @text;
} # text_content

sub children ($) {
  my $self = shift;
  return $$self->[0]->collection ('children', $self, sub {
    my $node = $_[0];
    return grep {
      $$node->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE;
    } @{$$node->[0]->{data}->[$$node->[1]]->{child_nodes} or []};
  });
} # children

sub first_element_child ($) {
  my $self = shift;
  for (@{$$self->[2]->{child_nodes}}) {
    if ($$self->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE) {
      return $$self->[0]->node ($_);
    }
  }
  return undef;
} # first_element_child

sub last_element_child ($) {
  my $self = shift;
  for (reverse @{$$self->[2]->{child_nodes}}) {
    if ($$self->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE) {
      return $$self->[0]->node ($_);
    }
  }
  return undef;
} # last_element_child

sub child_element_count ($) {
  my $self = shift;
  my @el = grep {
    $$self->[0]->{data}->[$_]->{node_type} == ELEMENT_NODE;
  } @{$$self->[2]->{child_nodes}};
  return scalar @el;
} # child_element_count

# XXX prepend append

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
