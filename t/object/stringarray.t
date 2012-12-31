use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::Document;

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('hoge');
  my $tokens = $adef->allowed_tokens;

  is scalar @$tokens, 0;

  push @$tokens, 12, 55, "aa", "hoge";

  is scalar @$tokens, 4;

  shift @$tokens;

  is scalar @$tokens, 3;

  done $c;
} n => 3, name => 'fetchsize allowed_tokens';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('hoge');
  my $tokens = $adef->allowed_tokens;
  
  $#$tokens = 4;

  is_deeply $tokens, ['', '', '', '', ''];

  push @$tokens, 'ho ge';
  $#$tokens = 7;

  is_deeply $tokens, ['', '', '', '', '', 'ho ge', '', ''];

  $#$tokens = 3;

  is_deeply $tokens, ['', '', '', ''];

  is_deeply $adef->allowed_tokens, ['', '', '', ''];

  done $c;
} n => 4, name => 'storesize allowed_tokens';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('hoge');
  my $tokens = $adef->allowed_tokens;

  $tokens->[0] = 'hoge';
  $tokens->[1] = 'ab dce';
  my $hoge = [];
  $tokens->[2] = $hoge;

  is_deeply $tokens, ['hoge', 'ab dce', ''.$hoge];

  $tokens->[5] = 'foo';

  is_deeply $tokens, ['hoge', 'ab dce', ''.$hoge, '', '', 'foo'];

  done $c;
} n => 2, name => 'store allowed_tokens';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('hoge');
  my $tokens = $adef->allowed_tokens;

  push @$tokens, 12, 'ho ge', 'foo&', '';
  is $tokens->[0], '12';
  is $tokens->[3], '';
  is $tokens->[4], undef;
  is $tokens->[-1], '';
  is $tokens->[0.6], '12';
  is $tokens->[100], undef;

  is scalar @$tokens, 4;

  done $c;
} n => 7, name => 'fetch allowed_tokens';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('hoge');
  my $tokens = $adef->allowed_tokens;

  push @$tokens, 12, 64, 'aa';

  @$tokens = ();

  is_deeply $tokens, [];

  done $c;
} n => 1, name => 'clear allowed_tokens';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('hoge');
  my $tokens = $adef->allowed_tokens;
  push @$tokens, 12, 64, 'aa';

  pop @$tokens;

  is_deeply $tokens, ['12', '64'];

  is pop @$tokens, '64';

  is_deeply $tokens, ['12'];

  done $c;
} n => 3, name => 'pop allowed_tokens';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('hoge');
  my $tokens = $adef->allowed_tokens;

  my $hoge = {};
  push @$tokens, '12', "\x{45000}aa", $hoge;

  is_deeply $tokens, ['12', "\x{45000}aa", ''.$hoge];

  push @$tokens;

  is_deeply $tokens, ['12', "\x{45000}aa", ''.$hoge];

  push @$tokens, 12;

  is_deeply $tokens, ['12', "\x{45000}aa", ''.$hoge, '12'];

  done $c;
} n => 3, name => 'push allowed_tokens';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('hoge');
  my $tokens = $adef->allowed_tokens;
  push @$tokens, 12, 64, 'aa';

  shift @$tokens;

  is_deeply $tokens, ['64', 'aa'];

  is shift @$tokens, '64';

  is_deeply $tokens, ['aa'];

  done $c;
} n => 3, name => 'shift allowed_tokens';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('hoge');
  my $tokens = $adef->allowed_tokens;

  my $hoge = {};
  unshift @$tokens, '12', "\x{45000}aa", $hoge;

  is_deeply $tokens, ['12', "\x{45000}aa", ''.$hoge];

  unshift @$tokens;

  is_deeply $tokens, ['12', "\x{45000}aa", ''.$hoge];

  unshift @$tokens, 12;

  is_deeply $tokens, ['12', '12', "\x{45000}aa", ''.$hoge];

  done $c;
} n => 3, name => 'unshift allowed_tokens';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('hoge');
  my $tokens = $adef->allowed_tokens;

  push @$tokens, 12, 'ho ge', 'foo&', '';
  ok exists $tokens->[0];
  ok exists $tokens->[3];
  ok not exists $tokens->[4];
  ok exists $tokens->[-1];
  ok exists $tokens->[0.6];
  ok not exists $tokens->[100];

  is scalar @$tokens, 4;

  done $c;
} n => 7, name => 'exists allowed_tokens';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('hoge');
  my $tokens = $adef->allowed_tokens;

  is delete $tokens->[0], undef;
  delete $tokens->[1];

  is scalar @$tokens, 0;

  push @$tokens, 12, 34, 5152;

  is delete $tokens->[2], '5152';
  is scalar @$tokens, 2;
  
  push @$tokens, 'hoge,', 'fuga';

  delete $tokens->[7];
  delete $tokens->[2];

  is_deeply $tokens, ['12', '34', '', 'fuga'];

  done $c;
} n => 5, name => 'delete allowed_tokens';

test {
  my $c = shift;
  my $doc = new Web::DOM::Document;
  my $adef = $doc->create_attribute_definition ('hoge');
  my $tokens = $adef->allowed_tokens;

  is_deeply [splice @$tokens, 0, 6], [];
  dies_here_ok {
    is_deeply [splice @$tokens, -1], [];
  };
  is_deeply [splice @$tokens, 500, 0], [];

  my $hoge = [];
  splice @$tokens, 0, 0, 'hoge', 'fuga', $hoge, 'aa', 'bbbb', 'cc';

  is_deeply [splice @$tokens, 0, 2], ['hoge', 'fuga'];
  is_deeply [splice @$tokens, 0, 1], [''.$hoge];
  is_deeply [splice @$tokens, 1, 1], ['bbbb'];

  is_deeply $tokens, ['aa', 'cc'];

  done $c;
} n => 7, name => 'splice allowed_tokens';

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
