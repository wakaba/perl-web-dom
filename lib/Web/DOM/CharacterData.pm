package Web::DOM::CharacterData;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '1.0';
use Web::DOM::Node;
use Web::DOM::ChildNode;
push our @ISA, qw(Web::DOM::Node Web::DOM::ChildNode);

*node_value = \&data;
*text_content = \&data;

sub data ($;$) {
  if (@_ > 1) {
    ## "Replace data" steps (simplified)
    # XXX mutation record
    ${${$_[0]}->[2]->{data}} = defined $_[1] ? ''.$_[1] : ''; # WebIDL
    # XXX range
  }
  return ${${$_[0]}->[2]->{data}};
} # data

sub length ($) {
  my $length = CORE::length ${${$_[0]}->[2]->{data}};
  if (${${$_[0]}->[2]->{data}} =~ /[\x{10000}-\x{10FFFF}]/) {
    $length += ${${$_[0]}->[2]->{data}} =~ tr/\x{10000}-\x{10FFFF}/\x{10000}-\x{10FFFF}/;
  }
  return $length;
} # length

sub append_data ($$) {
  my $has_trail = ${${$_[0]}->[2]->{data}} =~ /[\x{D800}-\x{DBFF}]\z/;
  if ($has_trail) {
    my $old_length = CORE::length ${${$_[0]}->[2]->{data}};
    ${${$_[0]}->[2]->{data}} .= $_[1];
    my $boundary = substr ${${$_[0]}->[2]->{data}}, $old_length - 1, 2;
    if ($boundary =~ /\A([\x{D800}-\x{DBFF}])([\x{DC00}-\x{DFFF}])\z/) {
      substr (${${$_[0]}->[2]->{data}}, $old_length - 1, 2)
          = chr (2**16 + ((ord $1) & 0x3FF) * 2**10 + ((ord $2) & 0x3FF));
    }
  } else {
    ${${$_[0]}->[2]->{data}} .= $_[1];
  }
  return;
} # append_data

sub substring_data ($$$) {
  # WebIDL: unsigned long
  my $offset = $_[1] % 2**32;
  my $count = $_[2] % 2**32;

  if (${${$_[0]}->[2]->{data}} =~ /[\x{10000}-\x{10FFFF}]/ or
      $count >= 2**31) {
    # 1.-4.
    my @data = split //, ${${$_[0]}->[2]->{data}};
    my @result;
    my $i = 0;
    for (@data) {
      last if $i >= $offset + $count;
      if (/[\x{10000}-\x{10FFFF}]/) {
        if ($offset == $i + 1) {
          push @result, chr ((((ord $_) - 0x10000) % 0x400) + 0xDC00);
        } elsif ($offset + $count == $i + 1) {
          push @result, chr ((((ord $_) - 0x10000) / 0x400) + 0xD800);
        } elsif ($offset <= $i) {
          push @result, $_;
        }
        $i += 2;
      } else {
        if ($offset <= $i) {
          push @result, $_;
        }
        $i++;
      }
    }
    if ($offset > $i) {
      _throw Web::DOM::Exception 'IndexSizeError',
          'Offset is greater than the length';
    }
    return join '', @result;
  } else {
    # 1.-2.
    if ($offset > CORE::length ${${$_[0]}->[2]->{data}}) {
      _throw Web::DOM::Exception 'IndexSizeError',
          'Offset is greater than the length';
    }

    # 3.-4.
    return substr ${${$_[0]}->[2]->{data}}, $offset, $count;
  }
} # substring_data

# XXX data methods

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
