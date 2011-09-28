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

require 'launchcraft'

class LaunchCraft
  Config = Class.new(Hash) {
    def initialize
      rehash
    end

    def rehash
      @path = File.join(LaunchCraft.working_dir, 'options.txt')
      set_default
      File.file?(@path) ? parse : save
    end

    def []= (key, value)
      super(key.to_s, value.to_s)
    end

    def to_s
      map {|*kv|
        kv.join(':')
      }.join("\n")
    end

    def save
      File.open(@path, 'wb') {|f|
        f.write to_s
      }
    end

    protected
    def set_default
      update({
        'music' => '1.0',
        'sound' => '1.0',
        'invertYMouse' => 'false',
        'mouseSensitivity' => '0.5',
        'fov' => '0.0',
        'gamma' => '0.0',
        'viewDistance' => '0',
        'guiScale' => '0',
        'bobView' => 'false',
        'anaglyph3d' => 'false',
        'advancedOpengl' => 'false',
        'fpsLimit' => '1',
        'difficulty' => '0',
        'fancyGraphics' => 'true',
        'ao' => 'false',
        'skin' => 'Default',
        'lastServer' => '',
        'url.login' => 'https://login.minecraft.net/',
        'url.joinserver' => 'http://session.minecraft.net/game/joinserver.jsp',
        'url.skins' => 'http://s3.amazonaws.com/MinecraftSkins/',
        'url.resources' => 'http://s3.amazonaws.com/MinecraftResources/',
        'url.download' => 'http://s3.amazonaws.com/MinecraftDownload/',
        'url.has_paid' => 'https://login.minecraft.net/session',
        'url.cloacks' => 'http://s3.amazonaws.com/MinecraftCloaks/',
        'key_key.attack' => '-100',
        'key_key.use' => '-99',
        'key_key.forward' => '17',
        'key_key.left' => '30',
        'key_key.back' => '31',
        'key_key.right' => '32',
        'key_key.jump' => '57',
        'key_key.sneak' => '42',
        'key_key.drop' => '16',
        'key_key.inventory' => '18',
        'key_key.chat' => '20',
        'key_key.playerList' => '15',
        'key_key.pickItem' => '-98',
      })
    end

    def parse
      update(Hash[File.read(@path).split(/\r?\n/).map {|line|
        next if line =~ /^\s*#/

        line.split(':', 2)
      }])
      save
    end
  }.new
end
