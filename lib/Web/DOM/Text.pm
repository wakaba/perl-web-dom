package Web::DOM::Text;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::CharacterData;
push our @ISA, qw(Web::DOM::CharacterData);

sub node_name ($) {
  return '#text';
} # node_name

# XXX text methods

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
