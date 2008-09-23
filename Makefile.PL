use inc::Module::Install;

name     'Document-Writer';
all_from 'lib/Document/Writer.pm';
author   'Cory G Watson <gphat@cpan.org>';

build_requires 'Test::More';

test_requires 'Pod::Coverage::Moose';

requires 'Forest' => '0.02';
requires 'Graphics::Primitive' => '0.31';
requires 'Layout::Manager' => '0.18';
requires 'Moose' => '0.57';
requires 'MooseX::AttributeHelpers' => '0.13';
requires 'Paper::Specs' => '0.10';
requires 'Text::Flow' => '0.01';

WriteAll;

