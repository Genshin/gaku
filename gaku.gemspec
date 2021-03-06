require_relative 'common_gaku_gemspec_mixin'

Gem::Specification.new do |s|
  set_gaku_gemspec_shared s

  s.name         = 'gaku'
  s.summary      = 'GAKU Engine - Dynamic Open Source School Management'
  s.description  = \
    'GAKU Engine is a highly customizable Open Source School Management System. ' +
    'It offers extensions to exceed the bounds of a standardized curriculum, ' +
    'and original tools to augment the learning experience.' +
    'It is the engine to drive a more dynamic education.'
  s.post_install_message =  \
    "╔═════════════════════════╼\n" +
    "║⚙学 GAKU Engine [学エンジン] V.#{s.version.to_s}\n" +
    "╟─────────────────────────╼\n" +
    "║©2014 株式会社幻創社 [Phantom Creation Inc.]\n" +
    "║http://www.gakuengine.com\n" +
    "╟─────────────────────────╼\n" +
    "║Thank you for installing GAKU Engine!\n" +
    "║GAKU Engine is Open Source [GPL/AGPL] Software.\n" +
    "╚═════════════════════════╼\n"

  s.files =       Dir.glob('lib/**/*.rb', File::FNM_DOTMATCH) +
                  Dir.glob('bin/**/*', File::FNM_DOTMATCH) +
                  [
                    'common_gaku_dependencies.rb',
                    'common_gaku_gemspec_mixin.rb',
                    'Dockerfile',
                    'docker-compose.yml',
                    'wait-for-it.sh',
                    'Gemfile',
                    'Rakefile',
                    'VERSION',
                    'gaku.gemspec'
                  ]
  s.require_paths = ['lib']
  s.bindir        = 'bin'
  s.executables   << 'gaku'

  s.requirements  << 'postgresql'
  s.requirements  << 'postgresql-contrib'

  s.add_dependency 'gaku_core', s.version
  s.add_dependency 'gaku_api', s.version

  s.add_dependency 'gaku_testing', s.version
  s.add_dependency 'gaku_sample', s.version

  s.add_dependency 'faraday'
end
