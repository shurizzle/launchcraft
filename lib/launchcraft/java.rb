#--
# Copyleft shura. [ shura1991@gmail.com ]
#
# This file is part of launchcraft.
#
# launchcraft is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# launchcraft is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with launchcraft. If not, see <http://www.gnu.org/licenses/>.
#++

if RUBY_PLATFORM =~ /java/
  class LaunchCraft
    class Java
      def self.exec (user, sessid=nil)
          bindir = File.join(LaunchCraft.working_dir, 'bin')
          ::Java::java.lang.System.setProperty('org.lwjgl.librarypath', File.join(bindir, 'natives'))
          ::Java::java.lang.System.setProperty('net.java.games.input.librarypath', File.join(bindir, 'natives'))
          ::Java::java.lang.System.setProperty('minecraft.appname', LaunchCraft.appname)

          %w[jinput lwjgl lwjgl_util minecraft].each {|x|
            ::Kernel.require(File.join(bindir, "#{x}.jar"))
          }

          ::Java::net.minecraft.client.Minecraft.main([user, sessid].compact.to_java(:String))
      end
    end
  end
else
  require 'os'
  require 'launchcraft'

  class Dir
    def self.path
      ((ENV.key?('PATH') and ENV['PATH'] and !ENV['PATH'].empty?) ? ENV['PATH'] : '').split(File::PATH_SEPARATOR)
    end
  end

  module Kernel
    def self.which (bin, which=0)
      bin << '.exe' if OS.windows? and bin !~ /\.exe$/

      res = Dir.path.map {|path|
        File.join(path, bin)
      }.select {|bin|
        File.executable_real?(bin)
      }

      if which == :all
        res
      elsif which.is_a?(Integer)
        res[which]
      else
        res[0]
      end
    end
  end

  class LaunchCraft
    class Java
      BIN = Kernel.which('java').tap {|x|
        next x if x
        break File.join(ENV['JAVA_HOME'], 'bin', 'java') if ENV['JAVA_HOME']
        raise RuntimeError, "java bin not found."
      }

      class << self
        def exec (user, sessid=nil)
          Kernel.exec(*args(user, sessid))
        end

        def launch (user, sessid=nil)
          Kernel.system(*args(user, sessid))
        end

        def spawn (user, sessid=nil)
          Kernel.spawn(*args(user, sessid))
        end

        protected
        def args (user, sessid=nil)
          bindir = File.join(LaunchCraft.working_dir, 'bin')
          [BIN, '-Xmx1024M', '-Xms512M', '-cp', %w[jinput lwjgl lwjgl_util minecraft].map {|x|
            File.join(bindir, "#{x}.jar")
          }.join(File::PATH_SEPARATOR), "-Dorg.lwjgl.librarypath=#{File.join(bindir, 'natives')}",
          "-Dnet.java.games.input.librarypath=#{File.join(bindir, 'natives')}", "-Dminecraft.appname=#{LaunchCraft.appname}",
          'net.minecraft.client.Minecraft', user, sessid].compact
        end
      end
    end
  end
end
