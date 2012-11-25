use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->parent->parent->subdir ('t_deps', 'modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Web::DOM::Error;

sub create_error (;%) {
  return bless {@_}, 'Web::DOM::Error';
} # create_error

test {
  my $c = shift;

  my $error = create_error message => 'Error message',
      file_name => 'path/to file', line_number => 120;
  is $error->name, 'Error';
  is $error->message, 'Error message';
  is $error->file_name, 'path/to file';
  is $error->line_number, 120;
  is $error . '', "Error message at path/to file line 120.\n";
  done $c;
} name => 'with message', n => 5;

test {
  my $c = shift;

  my $error = create_error
      file_name => 'path/to file', line_number => 120;
  is $error->name, 'Error';
  is $error->message, 'Error';
  is $error->file_name, 'path/to file';
  is $error->line_number, 120;
  is $error . '', "Error at path/to file line 120.\n";
  done $c;
} name => 'without message', n => 5;

run_tests;

=head1 LICENSE

Copyright 2012 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
