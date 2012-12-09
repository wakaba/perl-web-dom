package Web::DOM::Element;
use strict;
use warnings;
our $VERSION = '1.0';
use Web::DOM::Node;
use Web::DOM::RootNode;
use Web::DOM::ChildNode;
push our @ISA, qw(Web::DOM::Node Web::DOM::RootNode Web::DOM::ChildNode);

*node_name = \&tag_name;

sub tag_name ($) {
  my $data = ${$_[0]}->[2];
  my $qname;
  if (defined $data->{prefix}) {
    $qname = ${$data->{prefix}} . ':' . ${$data->{local_name}};
  } else {
    $qname = ${$data->{local_name}};
  }
  if (defined $data->{namespace_uri} and 
      ${$data->{namespace_uri}} eq 'http://www.w3.org/1999/xhtml' and
      ${$_[0]}->[0]->{data}->[0]->{is_html}) {
    $qname =~ tr/a-z/A-Z/; # ASCII uppercase
  }
  return $qname;
} # tag_name

sub attributes ($) {
  return []; # XXX
} # attributes

# XXX attr methods

# XXX children methods

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
