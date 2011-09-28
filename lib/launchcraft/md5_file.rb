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

require 'os'
require 'launchcraft'

class LaunchCraft
  MD5File = Class.new {
    attr_accessor :lwjgl, :jinput, :lwjgl_util, :minecraft
    attr_accessor "#{OS.parse.to_s.gsub(/^macos$/, 'macosx')}_natives".to_sym

    def initialize
      rehash
    end

    def rehash
      @path = File.join(LaunchCraft.working_dir, 'bin', 'md5s')
      self.lwjgl = self.jinput = self.lwjgl_util = self.minecraft = self.natives = nil
      parse if File.file?(@path)
    end

    "#{OS.parse.to_s.gsub(/^macos$/, 'macosx')}_natives".tap {|m|
      alias_method :natives, m.to_sym
      alias_method :natives=, "#{m}=".to_sym
    }

    def to_s
      n = OS.parse.to_s.gsub(/^macos$/, 'macosx')
      "#md5 hashes for downloaded files\nlwjgl.jar=#{@lwjgl}\njinput.jar=#{@jinput}\n" +
      "lwjgl_util.jar=#{@lwjgl_util}\n#{n}_natives.jar.lzma=" +
      "#{instance_variable_get("@#{n}_natives")}\nminecraft.jar=#{@minecraft}"
    end

    def save
      File.open(@path, 'wb') {|f|
        f.write to_s
      }
    end

    protected
    def parse
      File.read(@path).split(/\r?\n/).each {|line|
        next if line =~ /^\s*#/

        key, value = line.split('=', 2).map(&:strip)
        instance_variable_set("@#{key.split('.').first}".to_sym, value)
      }
    end
  }.new
end
