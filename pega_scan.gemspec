# coding: utf-8
#
# This file is part of PegaScan
# https://github.com/bcoles/pega_scan
#

Gem::Specification.new do |s|
  s.name        = 'pega_scan'
  s.version     = '0.0.1'
  s.required_ruby_version = '>= 2.0.0'
  s.date        = '2017-05-06'
  s.summary     = 'PegaRules scanner'
  s.description = 'A simple remote scanner for PegaRules'
  s.license     = 'MIT'
  s.authors     = ['Brendan Coles']
  s.email       = 'bcoles@gmail.com'
  s.files       = ['lib/pega_scan.rb']
  s.homepage    = 'https://github.com/bcoles/pega_scan'
  s.executables << 'pega-scan'
end
