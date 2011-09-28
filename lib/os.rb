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

class OS
  class << self
    if RUBY_PLATFORM =~ /java/
      def parse (what=Java::java.lang.System.getProperty('os.name'))
        case what.downcase
        when /win/
          :windows
        when /mac/
          :macos
        when /solaris|sunos/
          :solaris
        when /linux|unix/
          :linux
        else
          :unknown
        end
      end
    else
      def parse (what=RUBY_PLATFORM)
        case what
        when /(?<!dar)win|w32/
          :windows
        when /darwin/
          :macos
        when /linux/
          :linux
        when /solaris/
          :solaris
        else
          :unknown
        end
      end
    end

    def windows?
      parse == :windows
    end

    def macos?
      parse == :macos
    end

    def solaris?
      parse == :solaris
    end

    def linux?
      parse == :linux
    end
  end
end
