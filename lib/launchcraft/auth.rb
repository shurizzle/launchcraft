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
require 'launchcraft/config'
require 'launchcraft/uri'

require 'net/http'
require 'cgi'

class LaunchCraft
  class Auth
    class OldVersion < Exception
    end

    class BadLogin < Exception
    end

    attr_reader :username, :password, :uuid

    def initialize (username, password=nil)
      @username, @password, @uuid, @logged = username, password, nil, false
    end

    def logged?
      @logged
    end

    def login
      post(Config['url.login'], "version=13&user=#{CGI.escape(@username)}&password=#{CGI.escape(@password)}", {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Content-Language' => 'en-US'
        }).tap {|b|
          if (@logged = !!(b =~ /^.+?:.+?:(.+?):(.+?):?$/))
            @username, @uuid = $1, $2
          elsif b =~ /old/i
            raise OldVersion
          else
            raise BadLogin
          end
        }
      self
    end

    protected
    def post (url, body, headers={})
      uri = URI.parse(url)
      Net::HTTP.start(uri.host, uri.port) {|http|
        http.request_post(uri.request, body, headers) {|res|
          case res
          when Net::HTTPSuccess then return res.body
          when Net::HTTPRedirection then return post(res['location'], body, headers)
          else raise BadLogin
          end
        }
      }
    end
  end
end
