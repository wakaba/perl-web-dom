package Web::DOM::StringArray;
use strict;
use warnings;
our $VERSION = '1.0';
use Carp;

## [0] - The data
## [1] - On change
## [2] - Token validator

sub TIEARRAY ($$$$) {
  return bless [$_[1], $_[2], $_[3]], $_[0];
} # TIEARRAY

sub EXTEND { }

sub FETCHSIZE ($) {
  return scalar @{$_[0]->[0]};
} # FETCHSIZE

sub STORESIZE ($$) {
  for (@{$_[0]->[0]} .. ($_[1] - 1)) {
    $_[0]->[0]->[$_] = $_[0]->[2]->('');
  }
  $#{$_[0]->[0]} = $_[1] - 1;
  $_[0]->[1]->($_[0]);
} # STORESIZE

sub STORE ($$$) {
  for (@{$_[0]->[0]}..($_[1] - 1)) {
    $_[0]->[0]->[$_] = $_[0]->[2]->('');
  }
  $_[0]->[0]->[$_[1]] = $_[0]->[2]->(''.$_[2]);
  $_[0]->[1]->($_[0]);
} # STORE

sub FETCH ($$) {
  return $_[0]->[0]->[$_[1]]; # or undef
} # FETCH

sub CLEAR ($) {
  @{$_[0]->[0]} = ();
  $_[0]->[1]->($_[0]);
} # CLEAR

sub POP ($) {
  my $value = pop @{$_[0]->[0]}; # or undef
  $_[0]->[1]->($_[0]);
  return $value;
} # POP

sub PUSH ($$) {
  my $self = shift;
  push @{$self->[0]}, map { $self->[2]->(''.$_) } @_;
  $self->[1]->($self);
} # PUSH

sub SHIFT ($) {
  my $value = shift @{$_[0]->[0]}; # or undef
  $_[0]->[1]->();
  return $value;
} # SHIFT

sub UNSHIFT ($$) {
  my $self = shift;
  unshift @{$self->[0]}, map { $self->[2]->(''.$_) } @_;
  $self->[1]->($self);
} # UNSHIFT

sub EXISTS ($$) {
  return exists $_[0]->[0]->[$_[1]];
} # EXISTS

sub DELETE ($$) {
  my $value = delete $_[0]->[0]->[$_[1]];
  $_[0]->[0]->[$_[1]] = $_[0]->[2]->('') if exists $_[0]->[0]->[$_[1] + 1];
  $_[0]->[1]->($_[0]);
  return $value;
} # DELETE

sub SPLICE {
  my $self = shift;
  my $size = $self->FETCHSIZE;
  my $offset = @_ ? shift : 0;
  $offset += $size if $offset < 0;
  my $length = @_ ? shift : $size - $offset;
  if ($size == 0 and $offset < 0) {
    croak "Modification of non-creatable array value attempted, subscript $offset";
  }
  if (@_) {
    my @return = splice @{$self->[0]}, $offset, $length,
        map { $self->[2]->(''.$_) } @_;
    $self->[1]->($self);
    return @return;
  } else {
    return splice @{$self->[0]}, $offset, $length;
  }
} # SPLICE

sub append ($;@) {
  my $self = shift;
  push @{$self->[0]}, map { $self->[2]->(''.$_) } @_;
  $self->[1]->($self);
} # append

sub replace_by_bare ($;@) {
  my $self = shift;
  @{$self->[0]} = @_; # map { $self->[2]->(''.$_) } @_;
  $self->[1]->($self);
} # replace_by_bare

1;

=head1 LICENSE

Copyright 2012-2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
