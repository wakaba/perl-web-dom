package Web::DOM::Element;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '1.0';
use Web::DOM::Internal;
use Web::DOM::Node;
use Web::DOM::RootNode;
use Web::DOM::ChildNode;
push our @ISA, qw(Web::DOM::Node Web::DOM::RootNode Web::DOM::ChildNode);
use Char::Class::XML qw(
  InXMLNameChar InXMLNameStartChar
  InXMLNCNameChar InXMLNCNameStartChar
);

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

## Attributes
##
## An attribute is represented as either:
##
##   - The reference to a string, or
##   - An |Attr| object.
##
## The string reference represents an attribute whose value is the
## referenced string.  It can only be used to represent a
## null-namespace attribute.
## 
## $$node->[2]->{attrs}->{$ns // ''}->{$ln} = (\value or attribute node ID)
## $$node->[2]->{attributes} = [array of (\name or attribute node ID)]
##
## The |attrs| hashref contains the attributes of the node.  The
## |attributes| arrayref, which is used to preserve the order of
## attributes, contains strings and/or |Attr| objects.  Strings refer
## null-namespace attributes in the |attrs| hashref by its local name.

sub attributes ($) {
  return ${$_[0]}->[0]->collection ('attributes', $_[0], sub {
    my $node = $_[0];
    for (@{$$node->[2]->{attributes} or []}) {
      if (ref $_) {
        my $data = {node_type => ATTRIBUTE_NODE,
                    local_name => Web::DOM::Internal->text ($$_),
                    value => ${$$node->[2]->{attrs}->{''}->{$$_}}};
        my $attr_id = $$node->[0]->add_data ($data);
        $$node->[2]->{attrs}->{''}->{$$_} = $attr_id;
        $_ = $attr_id;
      }
    }
    return @{$$node->[2]->{attributes} or []};
  });
} # attributes

sub has_attributes ($) {
  return !!@{${$_[0]}->[2]->{attributes} or []};
} # has_attributes

sub has_attribute ($$) {
  my $node = $_[0];
  my $name = ''.$_[1];

  # 1.
  if (${$$node->[2]->{namespace_uri} || \''} eq HTML_NS and
      $$node->[0]->{data}->[0]->{is_html}) {
    $name =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  # 2.
  return 1 if ref ($$node->[2]->{attrs}->{''}->{$name} || '');
  for (@{$$node->[2]->{attributes} or []}) {
    if (ref $_) {
      return 1 if $$_ eq $name;
    } else { # node ID
      return 1 if $$node->[0]->node ($_)->name eq $name;
    }
  }
  return 0;
} # has_attribute

sub has_attribute_ns ($$$) {
  # WebIDL, 1., 2.
  return defined ${$_[0]}->[2]->{attrs}->{defined $_[1] ? $_[1] : ''}->{''.$_[2]};
} # has_attribute_ns

sub get_attribute ($$) {
  my $node = $_[0];
  my $name = ''.$_[1];

  # 1.
  if (${$$node->[2]->{namespace_uri} || \''} eq HTML_NS and
      $$node->[0]->{data}->[0]->{is_html}) {
    $name =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  # 2.
  for (@{$$node->[2]->{attributes} or []}) {
    if (ref $_) {
      if ($$_ eq $name) {
        return ${$$node->[2]->{attrs}->{''}->{$name}};
      }
    } else { # node ID
      my $attr_node = $$node->[0]->node ($_);
      if ($attr_node->name eq $name) {
        return $attr_node->value;
      }
    }
  }
  return undef;
} # get_attribute

sub get_attribute_ns ($$$) {
  my $node = $_[0];
  my $nsurl = defined $_[1] ? ''.$_[1] : undef;
  my $ln = ''.$_[2];

  # 1., 2. / Get an attribute 1., 2.
  my $attr_id = $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln};
  if (defined $attr_id) {
    if (ref $attr_id) {
      return $$attr_id;
    } else {
      return $$node->[0]->{data}->[$attr_id]->{value};
    }
  } else {
    return undef;
  }
} # get_attribute_ns

sub set_attribute ($$$) {
  my $node = $_[0];
  my $name = ''.$_[1];
  my $value = ''.$_[2];

  # XXX strictErrorChecking

  # 1.
  unless ($name =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The name is not an XML Name';
  }

  # 2.
  if (${$$node->[2]->{namespace_uri} || \''} eq HTML_NS and
      $$node->[0]->{data}->[0]->{is_html}) {
    $name =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  # 3.
  for (@{$$node->[2]->{attributes} or []}) {
    if (ref $_) {
      if ($$_ eq $name) {
        # 5.
        {
          # Change 1.
          # XXX mutation

          # Change 2.
          $$node->[2]->{attrs}->{''}->{$name} = \$value;

          # Change 3.
          # XXX attribute is set, attribute is changed
        }
        return;
      }
    } else { # node ID
      my $attr_node = $$node->[0]->node ($_);
      if ($attr_node->name eq $name) {
        # 5.
        {
          # Change 1.
          # XXX mutation

          # Change 2.
          $$attr_node->[2]->{value} = $value;

          # Change 3.
          # XXX attribute is set, attribute is changed
        }
        return;
      }
    }
  }

  # 4.
  {
    # Append 1.
    # XXX mutation

    # Append 2.
    push @{$$node->[2]->{attributes} ||= []},
        Web::DOM::Internal->text ($name);
    $$node->[2]->{attrs}->{''}->{$name} = \$value;

    # Append 3.
    # XXX attribute is set, attribute is added
  }
} # set_attribute

sub set_attribute_ns ($$$$) {
  my $node = $_[0];
  my $qname = ''.$_[2];
  my $value = ''.$_[3];

  # 1.
  my $nsurl = defined $_[1] ? length $_[1] ? ''.$_[1] : undef : undef;

  # XXX strictErrorChecking

  # 2.
  unless ($qname =~ /\A\p{InXMLNameStartChar}\p{InXMLNameChar}*\z/) {
    _throw Web::DOM::Exception 'InvalidCharacterError',
        'The qualified name is not an XML Name';
  }

  # 3.
  unless ($qname =~ /\A\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*(?::\p{InXMLNCNameStartChar}\p{InXMLNCNameChar}*)?\z/) {
    _throw Web::DOM::Exception 'NamespaceError',
        'The qualified name is not an XML QName';
  }

  # 4.
  my ($prefix, $ln) = split /:/, $qname, 2;
  ($prefix, $ln) = (undef, $prefix) unless defined $ln;
  
  # 5.
  if (defined $prefix and not defined $nsurl) {
    _throw Web::DOM::Exception 'NamespaceError',
        'Namespace prefix cannot be bound to the null namespace';
  }

  # 6.
  if (defined $prefix and $prefix eq 'xml' and
      (not defined $nsurl or $nsurl ne XML_NS)) {
    _throw Web::DOM::Exception 'NamespaceError',
        'Prefix |xml| cannot be bound to anything other than XML namespace';
  }

  # 7.
  if (($qname eq 'xmlns' or (defined $prefix and $prefix eq 'xmlns')) and
      (not defined $nsurl or $nsurl ne XMLNS_NS)) {
    _throw Web::DOM::Exception 'NamespaceError',
        'Namespace of |xmlns| or |xmlns:*| must be the XMLNS namespace';
  }

  # 8.
  if (defined $nsurl and $nsurl eq XMLNS_NS and
      not ($qname eq 'xmlns' or (defined $prefix and $prefix eq 'xmlns'))) {
    _throw Web::DOM::Exception 'NamespaceError',
        'XMLNS namespace must be bound to |xmlns| or |xmlns:*|';
  }

  # 9. Set an attribute
  {
    # Set 1.-4.
    my $attr_id = $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln};
    if (defined $attr_id) {
      # 6.
      {
        # Change 1.
        # XXX mutation

        # Change 2.
        if (ref $attr_id) {
          $$attr_id = $value;
        } else {
          $$node->[0]->{data}->[$attr_id]->{value} = $value;
        }

        # Change 3.
        # XXX attribute is set, attribute is changed
      }
    } else {
      # 5.
      {
        # Append 1.
        # XXX mutation

        # Append 2.
        if (defined $nsurl or defined $prefix) {
          my $data = {node_type => ATTRIBUTE_NODE,
                      namespace_uri => Web::DOM::Internal->text ($nsurl),
                      prefix => Web::DOM::Internal->text ($prefix),
                      local_name => Web::DOM::Internal->text ($ln),
                      value => $value};
          my $attr_id = $$node->[0]->add_data ($data);
          push @{$$node->[2]->{attributes} ||= []}, $attr_id;
          $$node->[2]->{attrs}->{$nsurl}->{$ln} = $attr_id;
          $$node->[0]->connect ($attr_id => $$node->[1]);
        } else {
          push @{$$node->[2]->{attributes} ||= []},
              Web::DOM::Internal->text ($ln);
          $$node->[2]->{attrs}->{''}->{$ln} = \$value;
        }

        # Append 3.
        # XXX attribute is set, attribute is added
      }
    }
  }
} # set_attribute_ns

sub remove_attribute ($$) {
  my $node = $_[0];
  my $name = ''.$_[1];

  # 1.
  if (${$$node->[2]->{namespace_uri} || \''} eq HTML_NS and
      $$node->[0]->{data}->[0]->{is_html}) {
    $name =~ tr/A-Z/a-z/; ## ASCII lowercase
  }

  # 2. Remove
  {
    # Remove 1.
    # XXX mutation

    # Remove 2.
    my $found;
    @{$$node->[2]->{attributes} or []} = map {
      if ($found) {
        $_;
      } elsif (ref $_) {
        if ($$_ eq $name) {
          $found = 1;
          delete $$node->[2]->{attrs}->{''}->{$name};
          ();
        } else {
          $_;
        }
      } else { # node ID
        my $attr_node = $$node->[0]->node ($_);
        if ($attr_node->name eq $name) {
          $found = 1;
          my $nsurl = $attr_node->namespace_uri;
          $nsurl = '' unless defined $nsurl;
          delete $$node->[2]->{attrs}->{$nsurl}->{$attr_node->local_name};
          $$node->[0]->disconnect ($_);
          ();
        } else {
          $_;
        }
      }
    } @{$$node->[2]->{attributes} or []};

    # Remove 3.
    # XXX attribute is removed
  }
} # remove_attribute

sub remove_attribute_ns ($$$) {
  my $node = $_[0];
  my $ln = ''.$_[2];
  
  # 1., 2.
  my $nsurl = $_[1];
  my $attr_id = $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln};
  if (defined $attr_id) {
    # Remove 1.
    # XXX mutation

    # Remove 2.
    if (ref $attr_id) {
      @{$$node->[2]->{attributes}} = grep { not ref $_ or $$_ ne $ln } @{$$node->[2]->{attributes}};
    } else {
      $$node->[0]->disconnect ($attr_id);
      @{$$node->[2]->{attributes}} = grep { $_ ne $attr_id } @{$$node->[2]->{attributes}};
    }
    delete $$node->[2]->{attrs}->{defined $nsurl ? $nsurl : ''}->{$ln};

    # Remove 3.
    # XXX attribute is removed
  }
} # remove_attribute_ns

# XXX attr node methods

# XXX id / class attrs

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
