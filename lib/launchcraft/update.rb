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
require 'launchcraft/md5_file'
require 'launchcraft/config'
require 'launchcraft/lzma'
require 'launchcraft/zip'
require 'launchcraft/uri'

require 'fileutils'
require 'net/http'

class LaunchCraft
  class Update
    class Entry < Struct.new(:file, :url, :md5, :length)
      alias size length
      alias size= length=

      def to_s
        file
      end
    end

    class Global < Struct.new(:total, :partial, :current)
    end

    def initialize
      @dir = File.join(LaunchCraft.working_dir, 'bin')
      @os = OS.parse.to_s.gsub(/^macos$/, 'macosx')

      @entries = {
        lwjgl: Entry.new('lwjgl.jar', Config['url.download'] + 'lwjgl.jar'),
        jinput: Entry.new('jinput.jar', Config['url.download'] + 'jinput.jar'),
        lwjgl_util: Entry.new('lwjgl_util.jar', Config['url.download'] + 'lwjgl_util.jar'),
        "#{@os}_natives".to_sym => Entry.new("#{@os}_natives.jar.lzma", Config['url.download'] + "#{@os}_natives.jar.lzma"),
        minecraft: Entry.new('minecraft.jar', 'http://cloud.github.com/downloads/shurizzle/MyCraft/minecraft.jar')
      }
    end

    def check
      @entries.each {|name, entry|
        yield entry if block_given?
        entry.md5, entry.size = get_infos(entry.url)
      }
    end

    def update (&blk)
      _update @entries.map {|name, entry|
        entry if MD5File.send(name) != entry.md5
      }.compact, &blk
    end

    def force_update (&blk)
      _update @entries.values, &blk
    end

    protected
    def _update (ent)
      tot = ent.map(&:size).reduce(:+)
      part = 0
      stat = Global.new(tot, part, nil)

      ent.each {|e|
        uri = URI.parse(e.url)
        File.open(File.join(@dir, e.file), 'wb') {|f|
          Net::HTTP.start(uri.host, uri.port) {|http|
            http.request(Net::HTTP::Get.new(uri.request)) {|res|
              res.read_body {|segment|
                part += segment.bytesize
                f.write(segment)
                stat.total = tot
                stat.partial = part
                stat.current = e
                yield stat if block_given?
              }
            }
          }
        }
        MD5File.send("#{e.file.split('.').first}=", e.md5)

        if e.file == "#{@os}_natives.jar.lzma"
          dir = File.join(@dir, 'natives')
          file = File.join(@dir, e.file)
          FileUtils.rm_rf(dir) if File.exists?(dir)
          file = LZMA.extract(file).tap {
            FileUtils.rm_f(file)
          }
          Zip.extract(file, dir)
          FileUtils.rm_f(file)
          FileUtils.rm_rf(File.join(dir, 'META-INF'))
        end
      }

      MD5File.save
    end

    def get_infos (url)
      uri = URI.parse(url)
      Net::HTTP.start(uri.host, uri.port) {|http|
        res = http.head(uri.request)
        [res['etag'].gsub('"', '').strip, res['content-length'].to_i]
      }
    end
  end
end
