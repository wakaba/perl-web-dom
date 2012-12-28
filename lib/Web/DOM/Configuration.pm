package Web::DOM::Configuration;
use strict;
use warnings;
our $VERSION = '1.0';
use Carp;
our @CARP_NOT = qw(Web::DOM::Document Web::DOM::TypeError);
use Web::DOM::TypeError;
use Web::DOM::Exception;

use overload
    '""' => sub {
      return ref ($_[0]) . '=DOM(' . ${$_[0]}->[0] . ')';
    },
    bool => sub { 1 },
    cmp => sub {
      carp "Use of uninitialized value in string comparison (cmp)"
          unless defined $_[1];
      overload::StrVal ($_[0]) cmp overload::StrVal ($_[1])
    },
    '%{}' => sub {
      return ${$_[0]}->[0]->config_hashref;
    },
    fallback => 1;

my $Defs = [
  {
    name => 'manakai-strict-document-children',
    obs_name => 'http://suika.fam.cx/www/2006/dom-config/strict-document-children',
    perl_name => 'manakai_strict_document_children',
    not => 1,
  },
  {
    name => 'manakai-create-child-element',
    obs_name => 'http://suika.fam.cx/www/2006/dom-config/create-child-element',
    perl_name => 'manakai_create_child_element',
  },
  {
    name => 'manakai-allow-doctype-children',
    perl_name => 'manakai_allow_doctype_children',
  },
];

my $DOMParams = {};
my $DOMNotParams = {};
my $DOMNames = [];
my $PerlParams = {};
my $PerlNotParams = {};
my $PerlNames = [];

for (@$Defs) {
  if ($_->{not}) { # boolean, negation
    $PerlNotParams->{$_->{perl_name}} = "not_$_->{perl_name}";
    $DOMNotParams->{$_->{name}} = "not_$_->{perl_name}";
    if (defined $_->{obs_name}) {
      $PerlNotParams->{$_->{obs_name}} = "not_$_->{perl_name}";
      $DOMNotParams->{$_->{obs_name}} = "not_$_->{perl_name}";
    }
  } else { # boolean
    $PerlParams->{$_->{perl_name}} = $_->{perl_name};
    $DOMParams->{$_->{name}} = $_->{perl_name};
    if (defined $_->{obs_name}) {
      $PerlParams->{$_->{obs_name}} = $_->{perl_name};
      $DOMParams->{$_->{obs_name}} = $_->{perl_name};
    }
  }
  push @$DOMNames, $_->{name};
  push @$PerlNames, $_->{perl_name};
  if (defined $_->{obs_name}) {
    push @$DOMNames, $_->{obs_name};
    push @$PerlNames, $_->{obs_name};
  }
}

@$DOMNames = sort { $a cmp $b } @$DOMNames;
@$PerlNames = sort { $a cmp $b } @$PerlNames;

sub parameter_names ($) {
  return ${$_[0]}->[0]->{config_names} ||= do {
    my $list = [@$DOMNames];
    Internals::SvREADONLY (@$list, 1);
    $list;
  };
} # parameter_names

sub get_parameter {
  my $key = ''.$_[1];
  if ($DOMParams->{$key}) {
    return ${$_[0]}->[0]->{config}->{$DOMParams->{$key}};
  } elsif ($DOMNotParams->{$key}) {
    return not ${$_[0]}->[0]->{config}->{$DOMNotParams->{$key}};
  } else {
    _throw Web::DOM::Exception 'NotFoundError', 'Parameter not found';
  }
} # get_parameter

sub set_parameter ($$;$) {
  my $key = ''.$_[1];
  if ($DOMParams->{$key}) {
    ${$_[0]}->[0]->{config}->{$DOMParams->{$key}} = !!$_[2];
  } elsif ($DOMNotParams->{$key}) {
    ${$_[0]}->[0]->{config}->{$DOMNotParams->{$key}} = !$_[2];
  } else {
    _throw Web::DOM::Exception 'NotFoundError', 'Parameter not found';
  }
} # set_parameter

sub can_set_parameter ($$;$) {
  my $key = ''.$_[1];
  return $DOMParams->{$key} || $DOMNotParams->{$key};
} # can_set_parameter

package Web::DOM::Configuration::Hash;

sub TIEHASH ($$) {
  return bless [$_[1]], $_[0]
} # TIEHASH

sub FETCH ($$) {
  my $key = ''.$_[1];
  if ($PerlParams->{$key}) {
    return $_[0]->[0]->{config}->{$PerlParams->{$key}};
  } elsif ($PerlNotParams->{$key}) {
    return not $_[0]->[0]->{config}->{$PerlNotParams->{$key}};
  } else {
    return undef;
  }
} # FETCH

sub STORE ($$$) {
  my $key = ''.$_[1];
  if ($PerlParams->{$key}) {
    $_[0]->[0]->{config}->{$PerlParams->{$key}} = !!$_[2];
  } elsif ($PerlNotParams->{$key}) {
    $_[0]->[0]->{config}->{$PerlNotParams->{$key}} = !$_[2];
  }
} # STORE

sub DELETE ($$) {
  my $key = ''.$_[1];
  if ($PerlParams->{$key}) {
    delete $_[0]->[0]->{config}->{$PerlParams->{$key}};
  } elsif ($PerlNotParams->{$key}) {
    delete $_[0]->[0]->{config}->{$PerlNotParams->{$key}};
  }
} # DELETE

sub CLEAR ($) {
  %{$_[0]->[0]->{config} or {}} = ();
} # CLEAR

sub EXISTS ($$) {
  my $key = ''.$_[1];
  return $PerlParams->{$key} || $PerlNotParams->{$key};
} # EXISTS

sub FIRSTKEY ($) {
  return $PerlNames->[0];
} # FIRSTKEY

sub NEXTKEY ($$) {
  for (0..$#$PerlNames) {
    return $PerlNames->[$_ + 1] if $PerlNames->[$_] eq $_[1]
  }
  return undef;
} # NEXTKEY

sub SCALAR ($) {
  return 1;
} # SCALAR

sub DESTROY ($) {
  {
    local $@;
    eval { die };
    warn "Potential memory leak detected" if $@ =~ /during global destruction/;
  }
} # DESTROY

1;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
