# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mailjet_mailer/version"

Gem::Specification.new do |s|
  s.name        = "mailjet_mailer"
  s.version     = MailjetMailer::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jeremiah Church"]
  s.email       = ["jeremiahchurch@gmail.com"]
  s.homepage    = "https://github.com/Tongboy/mailjet_mailer"
  s.summary     = %q{Transactional Mailer for Mailjet}
  s.description = %q{Transactional Mailer for Mailjet}
  s.license = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  #s.add_dependency 'activesupport'
  # s.add_dependency 'actionpack'
  s#.add_dependency 'activejob'
  s.add_runtime_dependency 'mailjet', '~> 1.3.8'

  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec'

end
