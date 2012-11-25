package Web::DOM::Error;
use strict;
use warnings;
use Carp;
use overload
    '""' => \&_stringify, bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    fallback => 1;
our $VERSION = '1.0';

## Error
##   <http://suika.fam.cx/~wakaba/wiki/sw/n/manakai%27s%20DOM%20Perl%20Binding$2233#anchor-54>
##   (Modeled on: JavaScript Error object
##      <http://people.mozilla.org/~jorendorff/es6-draft.html#sec-15.11>
##      <http://suika.fam.cx/~wakaba/wiki/sw/n/Error$19086>)

sub name ($) { 'Error' }
sub file_name ($) { $_[0]->{file_name} }
sub line_number ($) { $_[0]->{line_number} }

sub message ($) {
  ## We expect the message cannot be the empty string.  If it turns
  ## out that the message can be the empty string, maybe we should
  ## change the code here.
  return defined $_[0]->{message} ? $_[0]->{message} : $_[0]->name;
} # message

sub _stringify ($) {
  return sprintf "%s at %s line %s.\n",
      $_[0]->message, $_[0]->file_name, $_[0]->line_number;
} # _stringify

## XXX Should this class also be used to implement the DOM |DOMError|
## interface, or separate class should be used?

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
