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

require 'fileutils'
require 'zip'

module Zip
  def self.extract (archive, path=Dir.pwd)
    FileUtils.mkdir_p(path)

    ZipFile.open(archive) {|zf|
      zf.entries.each {|entry|
        FileUtils.mkdir_p(File.dirname(File.join(path, entry.name)))
        entry.extract(File.join(path, entry.name))
      }
    }
  end
end
