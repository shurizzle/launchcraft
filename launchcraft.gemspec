Gem::Specification.new {|g|
    g.name          = 'launchcraft'
    g.version       = '0.0.1'
    g.author        = 'shura'
    g.email         = 'shura1991@gmail.com'
    g.homepage      = 'http://github.com/shurizzle/launchcraft'
    g.platform      = Gem::Platform::RUBY
    g.description   = 'Simple cli launcher for minecraft'
    g.summary       = g.description
    g.files         = Dir.glob('lib/**/*')
    g.require_path  = 'lib'
    g.executables   = [ 'minecraft' ]

    g.add_dependency('ruby-lzma')
    g.add_dependency('zip')
    g.add_dependency('highline')
}
