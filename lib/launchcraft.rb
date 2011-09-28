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
require 'launchcraft/version'

class LaunchCraft
  def self.appname
    @appname ||= 'minecraft'
  end

  def self.appname=(name)
    @appname = name.to_s
    Config.rehash
    MD5File.rehash
    @appname
  end

  def self.working_dir (appname=self.appname)
    res = case OS.parse
          when :linux, :solaris
            File.join(ENV['HOME'], ".#{appname}")
          when :windows
            File.join(ENV['APPDATA'] || ENV['HOME'], ".#{appname}")
          when :macos
            File.join(ENV['HOME'], 'Library', 'Application Support', appname)
          else
            File.join(ENV['HOME'], appname)
          end

    Dir.mkdir(res) unless File.directory?(res)
    %w[bin resources saves screenshots stats texturepacks].each {|dir|
      dir = File.join(res, dir)
      Dir.mkdir(dir) unless File.directory?(dir)
    }
    return res
  end
end

require 'launchcraft/update'
require 'launchcraft/auth'
require 'launchcraft/java'
