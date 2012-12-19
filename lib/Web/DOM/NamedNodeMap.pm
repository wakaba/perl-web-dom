package Web::DOM::NamedNodeMap;
use strict;
use warnings;
use Web::DOM::Collection;
push our @ISA, qw(Web::DOM::Collection);
our $VERSION = '1.0';

# XXX getNamedItem setNamedItem removeNamedItem getNamedItemNS
# setNamedItemNS removeNamedItemNS

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut