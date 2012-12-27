use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;

  my $config1 = $doc1->dom_config;
  my $config2 = $doc2->dom_config;

  ok $config1;
  like $config1, qr{^Web::DOM::Configuration=};

  ok $config1 eq $config1;
  ok not $config1 ne $config1;
  ok not $config2 eq $config1;
  ok $config2 ne $config1;
  ok $config1 ne undef;
  ok not $config1 eq undef;
  is $config1 cmp $config1, 0;
  isnt $config1 cmp $config2, 0;

  # XXX test unitinialized warning by eq/ne/cmp-ing with undef
  
  done $c;
} name => 'eq', n => 10;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;

  my $dom1 = $doc->dom_config;
  my $dom2 = $doc->dom_config;

  is $dom1, $dom2;

  my $dom_s = $dom1 . '';

  undef $dom1;
  undef $dom2;

  is $doc->dom_config . '', $dom_s;
  isnt $doc->dom_config, $dom_s;

  done $c;
} n => 3;

{
  package test::DestroyCallback;
  sub DESTROY {
    $_[0]->();
  }
}

test {
  my $c = shift;

  my $invoked;
  my $doc = new Web::DOM::Document;
  $doc->set_user_data (destroy => bless sub {
                         $invoked = 1;
                       }, 'test::DestroyCallback');

  my $config = $doc->dom_config;

  undef $doc;
  ok !$invoked;

  undef $config;
  ok $invoked;

  done $c;
} name => 'destroy', n => 2;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $config = $doc->dom_config;

  ok $config->{manakai_strict_document_children};
  ok $config->{'http://suika.fam.cx/www/2006/dom-config/strict-document-children'};

  $config->{manakai_strict_document_children} = 0;
  ok not $config->{manakai_strict_document_children};
  ok not $config->{'http://suika.fam.cx/www/2006/dom-config/strict-document-children'};
  ok not $config->get_parameter ('manakai-strict-document-children');
  ok not $config->get_parameter ('http://suika.fam.cx/www/2006/dom-config/strict-document-children');

  $config->{manakai_strict_document_children} = 3;
  ok $config->{manakai_strict_document_children};
  ok $config->{'http://suika.fam.cx/www/2006/dom-config/strict-document-children'};
  ok $config->get_parameter ('manakai-strict-document-children');
  ok $config->get_parameter ('http://suika.fam.cx/www/2006/dom-config/strict-document-children');

  delete $config->{manakai_strict_document_children};
  ok $config->{manakai_strict_document_children};
  ok $config->{'http://suika.fam.cx/www/2006/dom-config/strict-document-children'};
  ok $config->get_parameter ('manakai-strict-document-children');
  ok $config->get_parameter ('http://suika.fam.cx/www/2006/dom-config/strict-document-children');

  $config->{'http://suika.fam.cx/www/2006/dom-config/strict-document-children'} = undef;
  ok not $config->{manakai_strict_document_children};
  ok not $config->{'http://suika.fam.cx/www/2006/dom-config/strict-document-children'};
  ok not $config->get_parameter ('manakai-strict-document-children');
  ok not $config->get_parameter ('http://suika.fam.cx/www/2006/dom-config/strict-document-children');

  $config->{'http://suika.fam.cx/www/2006/dom-config/strict-document-children'} = 1;
  ok $config->{manakai_strict_document_children};
  ok $config->{'http://suika.fam.cx/www/2006/dom-config/strict-document-children'};
  is $config->{'manakai-strict-document-children'}, undef;
  is $config->{'http://suika.fam.cx/www/2006/dom_config/strict_document_children'}, undef;
  ok $config->get_parameter ('manakai-strict-document-children');
  ok $config->get_parameter ('http://suika.fam.cx/www/2006/dom-config/strict-document-children');
  
  dies_here_ok {
    $config->get_parameter ('manakai_strict_document_children');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'Parameter not found';

  dies_here_ok {
    $config->get_parameter ('http://suika.fam.cx/www/2006/dom_config/strict_document_children');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'Parameter not found';

  done $c;
} n => 32, name => 'manakai-strict-document-children';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $config = $doc->dom_config;

  ok not $config->{manakai_create_child_element};
  ok not $config->{'http://suika.fam.cx/www/2006/dom-config/create-child-element'};

  $config->{manakai_create_child_element} = 0;
  ok not $config->{manakai_create_child_element};
  ok not $config->{'http://suika.fam.cx/www/2006/dom-config/create-child-element'};
  ok not $config->get_parameter ('manakai-create-child-element');
  ok not $config->get_parameter ('http://suika.fam.cx/www/2006/dom-config/create-child-element');

  $config->{manakai_create_child_element} = 3;
  ok $config->{manakai_create_child_element};
  ok $config->{'http://suika.fam.cx/www/2006/dom-config/create-child-element'};
  ok $config->get_parameter ('manakai-create-child-element');
  ok $config->get_parameter ('http://suika.fam.cx/www/2006/dom-config/create-child-element');

  delete $config->{manakai_create_child_element};
  ok not $config->{manakai_create_child_element};
  ok not $config->{'http://suika.fam.cx/www/2006/dom-config/create-child-element'};
  ok not $config->get_parameter ('manakai-create-child-element');
  ok not $config->get_parameter ('http://suika.fam.cx/www/2006/dom-config/create-child-element');

  $config->{'http://suika.fam.cx/www/2006/dom-config/create-child-element'} = undef;
  ok not $config->{manakai_create_child_element};
  ok not $config->{'http://suika.fam.cx/www/2006/dom-config/create-child-element'};
  ok not $config->get_parameter ('manakai-create-child-element');
  ok not $config->get_parameter ('http://suika.fam.cx/www/2006/dom-config/create-child-element');

  $config->{'http://suika.fam.cx/www/2006/dom-config/create-child-element'} = 1;
  ok $config->{manakai_create_child_element};
  ok $config->{'http://suika.fam.cx/www/2006/dom-config/create-child-element'};
  is $config->{'manakai-create-child-element'}, undef;
  is $config->{'http://suika.fam.cx/www/2006/dom_config/create_child_element'}, undef;
  ok $config->get_parameter ('manakai-create-child-element');
  ok $config->get_parameter ('http://suika.fam.cx/www/2006/dom-config/create-child-element');
  
  dies_here_ok {
    $config->get_parameter ('manakai_create_child_element');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'Parameter not found';

  dies_here_ok {
    $config->get_parameter ('http://suika.fam.cx/www/2006/dom_config/create_child_element');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'Parameter not found';

  done $c;
} n => 32, name => 'manakai-create-child-element';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $config = $doc->dom_config;

  $config->{hoge} = 23;
  is $config->{hoge}, undef;
  ok not exists $config->{hoge};
  dies_here_ok {
    $config->get_parameter ('hoge');
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'Parameter not found';
  
  delete $config->{hoge};
  is $config->{hoge}, undef;
  ok not exists $config->{hoge};

  dies_here_ok {
    $config->set_parameter ('hoge' => 123);
  };
  isa_ok $@, 'Web::DOM::Exception';
  is $@->name, 'NotFoundError';
  is $@->message, 'Parameter not found';
  
  is $config->{hoge}, undef;
  
  done $c;
} n => 13, name => 'parameter not found';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $config = $doc->dom_config;

  my @expected1 = qw(
    http://suika.fam.cx/www/2006/dom-config/create-child-element
    http://suika.fam.cx/www/2006/dom-config/strict-document-children
    manakai_create_child_element
    manakai_strict_document_children
  );
  my @expected2 = qw(
    http://suika.fam.cx/www/2006/dom-config/create-child-element
    http://suika.fam.cx/www/2006/dom-config/strict-document-children
    manakai-create-child-element
    manakai-strict-document-children
  );

  is_deeply $config->parameter_names, \@expected2;
  is_deeply [keys %$config], \@expected1;

  my @name;
  while ($_ = each %$config) {
    push @name, $_;
  }
  is_deeply \@name, \@expected1;

  @name = ();
  while ($_ = each %$config) {
    push @name, $_;
  }
  is_deeply \@name, \@expected1;
  
  done $c;
} n => 4, name => 'keys';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $config = $doc->dom_config;

  my $list = $config->parameter_names;
  is ref $list, 'ARRAY';
  is scalar @$list, 4;
  
  dies_here_ok {
    push @$list, 'hoge';
  };
  ok not ref $@;
  
  is scalar @$list, 4;

  done $c;
} n => 5, name => 'parameter_names read-only';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $config = $doc->dom_config;

  is $config->parameter_names, $config->parameter_names;

  done $c;
} n => 1, name => 'parameter_names same';

test {
  my $c = shift;
  my $doc1 = new Web::DOM::Document;
  my $doc2 = new Web::DOM::Document;
  my $config1 = $doc1->dom_config;
  my $config2 = $doc2->dom_config;

  isnt $config1->parameter_names, $config2->parameter_names;

  done $c;
} n => 1, name => 'parameter_names not same';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $config = $doc->dom_config;

  ok exists $config->{manakai_strict_document_children};
  ok exists $config->{manakai_create_child_element};
  ok exists $config->{'http://suika.fam.cx/www/2006/dom-config/create-child-element'};
  ok exists $config->{'http://suika.fam.cx/www/2006/dom-config/strict-document-children'};
  ok not exists $config->{hoge};
  ok not exists $config->{'manakai-strict-document-children'};

  done $c;
} n => 6, name => 'exists';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $config = $doc->dom_config;

  ok $config->can_set_parameter ('manakai-strict-document-children' => undef);
  ok $config->can_set_parameter ('manakai-strict-document-children' => 0);
  ok $config->can_set_parameter ('manakai-strict-document-children' => "hoge");
  ok $config->can_set_parameter ('manakai-strict-document-children' => {});
  ok $config->can_set_parameter ('http://suika.fam.cx/www/2006/dom-config/create-child-element' => undef);
  ok $config->can_set_parameter ('http://suika.fam.cx/www/2006/dom-config/create-child-element' => 0);
  ok not $config->can_set_parameter (manakai => undef);
  ok not $config->can_set_parameter ('manakai_strict_document_children' => undef);

  done $c;
} n => 8, name => 'can_set_parameter';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $config = $doc->dom_config;

  $config->{manakai_strict_document_children} = 0;
  $config->{'http://suika.fam.cx/www/2006/dom-config/create-child-element'} = 1;
  %$config = ();

  ok $config->{manakai_strict_document_children};
  ok not $config->{'http://suika.fam.cx/www/2006/dom-config/create-child-element'};
  
  done $c;
} n => 2, name => 'clear';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $config = $doc->dom_config;
  
  ok scalar keys %$config;

  done $c;
} n => 1, name => 'scalar';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
