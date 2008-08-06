use inc::Module::Install;

name     'Document-Writer';
all_from 'lib/Document/Writer.pm';
author   'Cory G Watson <gphat@cpan.org>';

build_requires 'Test::More';

test_requires 'Pod::Coverage::Moose';

requires 'Forest' => '0.02';
requires 'Layout::Manager' => '0.10';
requires 'Moose' => '0.54';
requires 'MooseX::AttributeHelpers' => '0.12';
requires 'Paper::Spec' => '0.10';

auto_install;

WriteAll;

