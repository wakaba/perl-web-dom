use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'lib')->stringify;
use Test::X1;
use Test::More;
use Test::DOM::Exception;
use Web::DOM::TypeError;

test {
  my $c = shift;

  my $error = new Web::DOM::TypeError ('Error message');
  isa_ok $error, 'Web::DOM::TypeError';
  isa_ok $error, 'Web::DOM::Error';

  is $error->name, 'TypeError';
  is $error->message, 'Error message';
  is $error->file_name, undef;
  is $error->line_number, 0;
  is $error . '', "Error message at (unknown) line 0.\n";

  done $c;
} name => 'with message', n => 7;

test {
  my $c = shift;

  my $error = new Web::DOM::TypeError;
  is $error->name, 'TypeError';
  is $error->message, 'TypeError';
  is $error->file_name, undef;
  is $error->line_number, 0;
  is $error . '', "TypeError at (unknown) line 0.\n";
  done $c;
} name => 'without message', n => 5;

test {
  my $c = shift;
  my $error1 = new Web::DOM::TypeError ('hoge');
  my $error2 = new Web::DOM::TypeError ('hoge');

  ok $error1 eq $error1;
  ok not $error1 ne $error1;
  ok not $error2 eq $error1;
  ok $error2 ne $error1;
  ok $error1 ne undef;
  ok not $error1 eq undef;
  is $error1 cmp $error1, 0;
  isnt $error1 cmp $error2, 0;
  isnt $error1 . '', $error1;

  # XXX test unitinialized warning by eq/ne/cmp-ing with undef
  
  done $c;
} name => 'eq', n => 9;

test {
  my $c = shift;
  dies_here_ok {
    _throw Web::DOM::TypeError 'hoge fuga';
  };
  isa_ok $@, 'Web::DOM::TypeError';
  is $@->name, 'TypeError';
  is $@->message, 'hoge fuga';
  is $@->file_name, __FILE__;
  is $@->line_number, __LINE__ - 6;
  is $@ . '', 'hoge fuga at ' . __FILE__ . ' line ' . (__LINE__ - 7) . ".\n";
  done $c;
} name => '_throw', n => 7;

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
