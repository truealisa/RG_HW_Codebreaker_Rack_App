require 'securerandom'
require 'codebreaker_app'

use Rack::Reloader, 0
use Rack::Session::Cookie, path: '/', secret: SecureRandom.base64(10)
use Rack::Static, :urls => ["/stylesheets"], :root => "public"

run CodebreakerApp
