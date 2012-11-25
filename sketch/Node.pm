package Node;
use strict;
use warnings;
use Exporter::Lite;

our @CARP_NOT = qw(Error);

BEGIN {
our @EXPORT = qw(ELEMENT_NODE DOCUMENT_NODE DOCUMENT_TYPE_NODE
                 DOCUMENT_FRAGMENT_NODE);
}

sub ELEMENT_NODE () { 1 }
sub DOCUMENT_NODE () { 9 }
sub DOCUMENT_TYPE_NODE () { 10 }
sub DOCUMENT_FRAGMENT_NODE () { 11 }

sub local_name ($) {
  my $self = shift;
  my $data = $$self->[0]->data ($$self->[1]);
  return $data->{local_name};
} # local_name

sub owner_document ($) {
  my $self = shift;
  my $data = $$self->[0]->data ($$self->[1]);
  return $$self->[0]->node ($data->{owner_document});
} # owner_document

sub parent_node ($) {
  my $self = shift;
  my $data = $$self->[0]->data ($$self->[1]);
  return undef unless defined $data->{parent_node};
  return $$self->[0]->node ($data->{parent_node});
} # parent_node

sub append_child ($$) {
  return $_[0]->insert_before ($_[1], undef);
} # append_child

sub insert_before ($$$) {
  my ($parent, $node, $child) = @_;
  my $parent_data = $$parent->[0]->data ($$parent->[1]);
  my $node_data = $$node->[0]->data ($$node->[1]);

  # pre-insert

  # 1.
  if ($parent_data->{node_type} == ELEMENT_NODE or
      $parent_data->{node_type} == DOCUMENT_FRAGMENT_NODE or
      $parent_data->{node_type} == DOCUMENT_NODE) {
    #
  } else {
    throw HierarchyRequestError message => 'Bad type of parent node';
  }

  # 2.
  {
    my $id = $$parent->[1];
    while (defined $id) {
      if ($id == $$node->[1]) {
        throw HierarchyRequestError message => 'Node is an inclusive ancestor';
      }
      $id = $$parent->[0]->{data}->[$id]->{parent_node};
    }
  }
  
  # 3.
  if (defined $child) {
    # XXX different doc
    my $parent = $$child->[0]->data ($$child->[1])->{parent_node};
    if (defined $parent and $parent != $$parent->[1]) {
      throw NotFoundError message => 'Not a child';
    }
  }

  # XXX

  push @{$parent_data->{child_nodes} ||= []}, $$node->[1];
  $node_data->{parent_node} = $$parent->[1];
  $$parent->[0]->connect ($$node->[1] => $$parent->[1]);
  return $node;
} # insert_before

sub first_child ($) {
  my $self = shift;
  my $data = $$self->[0]->data ($$self->[1]);
  my $id = $data->{child_nodes}->[0];
  return undef unless $id;
  return $$self->[0]->node ($id);
} # first_child

sub remove_child ($$) {
  my ($parent, $child) = @_;
  my $parent_data = $$parent->[0]->data ($$parent->[1]);
  my $child_data = $$child->[0]->data ($$child->[1]);
  my $id = $$child->[1];
  @{$parent_data->{child_nodes}} = grep { $_ ne $id } @{$parent_data->{child_nodes}};
  delete $child_data->{parent_node};
  $$child->[0]->disconnect ($$child->[1]);
  return $child;
} # remove_child

sub get_elements_by_tag_name ($$) {
  my ($self, $ln) = @_;
  return $$self->[0]->search ($$self->[1], $ln);
} # get_elements_by_tag_name

sub DESTROY ($) {
  my $self = shift;
  $$self->[0]->gc ($$self->[1]);
} # DESTROY

package Document;
push our @ISA, qw(Node);
BEGIN { Node->import };

sub new ($) {
  my $data = NodeData->new (node_type => DOCUMENT_NODE);
  my $set = NodeSet->new;
  my $id = $set->add ($data);
  return $set->node ($id);
} # new

sub create_element ($$) {
  my $self = shift;
  my $data = NodeData->new (local_name => $_[0], owner_document => $$self->[1],
                            node_type => ELEMENT_NODE);
  my $id = $$self->[0]->add ($data);
  return $$self->[0]->node ($id);
} # create_element

package Element;
push our @ISA, qw(Node);

package Error;
use overload '""' => \&stringify, bool => sub { 1 }, fallback => 1;
use Carp;

sub throw ($;%) {
  my $class = shift;
  my $self = bless {@_}, $class;
  eval { Carp::croak };
  if ($@ =~ /at (.+) line ([0-9]+)\.?$/) {
    $self->{file_name} = $1;
    $self->{line_number} = $2;
  }
  # XXX stack
  die $self;
} # throw

sub name ($) { 'DOMException' }
sub file_name ($) { $_[0]->{file_name} }
sub line_number ($) { $_[0]->{line_number} }

sub message ($) {
  return defined $_[0]->{message} ? $_[0]->{message} : $_[0]->name;
} # message

sub stringify ($) {
  my $self = shift;
  return sprintf "%s at %s line %s.\n",
      $self->message, $self->file_name, $self->line_number;
} # stringify

package DOMException;
push our @ISA, qw(Error);
use Exporter::Lite;

our @EXPORT = qw(HIERARCHY_REQUEST_ERR NOT_FOUND_ERR);

sub HIERARCHY_REQUEST_ERR () { 3 }
sub NOT_FOUND_ERR () { 8 }

sub code ($) { 0 }

package HierarchyRequestError;
push our @ISA, qw(DOMException);

sub name ($) { 'HierarchyRequestError' }
sub code ($) { DOMException::HIERARCHY_REQUEST_ERR }

package NotFoundError;
push our @ISA, qw(DOMException);

sub name ($) { 'NotFoundError' }
sub code ($) { DOMException::NOT_FOUND_ERR }

package HTMLCollection;

sub new ($$$) {
  my ($class, $node, $local_name) = @_;
  return $$node->[0]->search ($$node->[1], $local_name);
} # new

sub _search_all ($) {
  my $self = shift;
  my $set = $$self->[0];
  my @id = @{$set->data ($$self->[1])->{child_nodes} or []};
  my $expected_ln = $$self->[2];
  my @found;
  while (@id) {
    my $id = shift @id;
    my $ln = $set->{data}->[$id]->{local_name};
    next unless defined $ln;
    if ($ln eq $expected_ln) {
      push @found, $id;
    }
    unshift @id, @{$set->{data}->[$id]->{child_nodes} or []};
  }
  return \@found;
} # _search_all

sub item ($$) {
  my ($self, $index) = @_;
  my $found = $self->_search_all->[$index];
  return undef unless $found;
  return $$self->[0]->node ($found);
} # item

sub length ($) {
  my $self = shift;
  return 0+@{$self->_search_all};
} # length

package NodeSet;
use Scalar::Util qw(weaken);

sub new ($) {
  return bless {data => [], next_id => 0, nodes => [],
                tree_id => [], next_tree_id => 0}, $_[0];
} # new

sub add ($$) {
  my $self = shift;
  my $id = $self->{next_id}++;
  $self->{data}->[$id] = $_[0];
  $self->{tree_id}->[$id] = $self->{next_tree_id}++;
  return $id;
} # add

sub data ($$) {
  return $_[0]->{data}->[$_[1]];
} # data

sub node ($$) {
  my $self = shift;
  return $self->{nodes}->[$_[0]] if $self->{nodes}->[$_[0]];
  my $node = bless \[$self, $_[0]], $_[0] == 0 ? 'Document' : 'Element';
  weaken ($self->{nodes}->[$_[0]] = $node);
  return $node;
} # node

sub search ($$$) {
  my ($self, $id, $local_name) = @_;
  return $self->{search}->{$id, $local_name} if $self->{search}->{$id, $local_name};
  my $search = bless \[$self, $id, $local_name], 'HTMLCollection';
  weaken ($self->{search}->{$id, $local_name} = $search);
  return $search;
} # search

sub connect ($$$) {
  my ($self, $id => $parent_id) = @_;
  my @id = ($id);
  my $tree_id = $self->{tree_id}->[$parent_id];
  while (@id) {
    my $id = shift @id;
    $self->{tree_id}->[$id] = $tree_id;
    push @id, @{$self->{data}->[$id]->{child_nodes} or []};
  }
} # connect

sub disconnect ($$) {
  my ($self, $id) = @_;
  my @id = ($id);
  my $tree_id = $self->{next_tree_id}++;
  while (@id) {
    my $id = shift @id;
    $self->{tree_id}->[$id] = $tree_id;
    push @id, @{$self->{data}->[$id]->{child_nodes} or []};
  }
} # disconnect

sub gc ($$) {
  my ($self, $id) = @_;
  delete $self->{nodes}->[$id];
  my $tree_id = $self->{tree_id}->[$id];
  my @id = grep { $self->{tree_id}->[$_] == $tree_id } 0..$#{$self->{tree_id}};
  for (@id) {
    return if $self->{nodes}->[$_];
  }
  warn "GC $tree_id\n";
  for (@id) {
    delete $self->{data}->[$_];
    delete $self->{tree_id}->[$_];
  }
} # gc

package NodeData;

sub new ($;%) {
  my $class = shift;
  return bless {@_}, $class;
} # new

sub DESTROY ($) {
  warn "Destroy.\n";
  {
    local $@;
    eval { die };
    if ($@ =~ /during global destruction/) {
      warn "Detected (possibly) memory leak";
    }
  }
} # DESTROY

1;
