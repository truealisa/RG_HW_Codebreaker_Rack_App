require 'erb'
require 'bundler/setup'
require 'rg_hw_codebreaker'

class CodebreakerApp
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    case @request.path
    when '/'
      @request.session.clear
      Rack::Response.new(render('index.html.erb'))
    when '/help' then Rack::Response.new(render('help.html.erb'))
    when '/best_results' then Rack::Response.new(render('best_results.html.erb'))
    when '/game'
      start_game unless @request.session[:game]
      Rack::Response.new(render('game.html.erb'))
    when '/submit_guess'
      submit_guess(@request.params['guess'])
      Rack::Response.new { |response| response.redirect('/game') }
    when '/enter_name'
      enter_name(@request.params['name'])
      Rack::Response.new { |response| response.redirect('/best_results') }
    when '/show_hint'
      show_hint
      Rack::Response.new { |response| response.redirect('/game') }
    else Rack::Response.new('Not found', 404)
    end
  end

  private

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def start_game
    @request.session[:game] = RgHwCodebreaker::Game.new
    @request.session[:game].start
    @request.session[:attempts] = []
    @request.session[:show_hint] = false
  end

  def submit_guess(guess)
    if @request.session[:game].valid_guess?(guess)
      guess_result = @request.session[:game].check_guess(guess)
      @request.session[:attempts] << { guess: guess, guess_result: guess_result }
    else
      @request.session[:error_msg] = 'Your input is invalid'
    end
  end

  def enter_name(player_name)
    current_result = [player_name, Date.today, 10 - @request.session[:game].turns]
    RgHwCodebreaker::Cli.new.write_result_to_file(current_result)
    @request.session[:notice_msg] = 'Your result saved'
  end

  def show_hint
    @request.session[:show_hint] = true
    @request.session[:hint] = if @request.session[:game].any_hints_left?
                                "Hint: #{@request.session[:game].give_a_hint}***"
                              else
                                'No hints left :('
                              end
  end
end
