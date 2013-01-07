package Web::DOM::HTMLElement;
use strict;
use warnings;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::Element);
use Web::DOM::Element;

# XXX members

package Web::DOM::HTMLUnknownElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLHtmlElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLHeadElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLTitleElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX text

package Web::DOM::HTMLBaseElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX href target

package Web::DOM::HTMLLinkElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
# XXX LinkStyle

# XXX href ...

package Web::DOM::HTMLMetaElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX attrs

package Web::DOM::HTMLStyleElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);
# XXX LinkStyle

# XXX attrs

package Web::DOM::HTMLScriptElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX attrs

package Web::DOM::HTMLBodyElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX attrs

package Web::DOM::HTMLHeadingElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLParagraphElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLHRElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLPreElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLQuoteElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX cite

package Web::DOM::HTMLOListElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX attrs

package Web::DOM::HTMLUListElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLLIElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

# XXX attrs

package Web::DOM::HTMLDListElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

package Web::DOM::HTMLDivElement;
our $VERSION = '1.0';
push our @ISA, qw(Web::DOM::HTMLElement);

1;

=head1 LICENSE

Copyright 2013 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
