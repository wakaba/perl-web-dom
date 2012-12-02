package Web::DOM::TypeError;
use strict;
use warnings;
use Web::DOM::Error;
push our @ISA, qw(Web::DOM::Error);
our $VERSION = '1.0';
use Carp;

sub new ($$) {
  return bless {message => ''.$_[1]}, $_[0];
} # new

sub name ($) { 'TypeError' }

sub _throw ($$$) {
  my $self = bless {message => $_[1]}, $_[0];
  eval { Carp::croak };
  if ($@ =~ /at (.+) line ([0-9]+)\.?$/) {
    $self->{file_name} = $1;
    $self->{line_number} = $2;
  }
  # XXX stack
  die $self;
} # _throw

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
