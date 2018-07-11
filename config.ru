require 'codebreaker_app'

use Rack::Reloader, 0
use Rack::Static, :urls => ["/stylesheets"], :root => "public"

run CodebreakerApp.new
