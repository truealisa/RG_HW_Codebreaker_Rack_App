require 'erb'
require 'bundler/setup'
require 'rg_hw_codebreaker'

class CodebreakerApp
  def initialize
    @flash = { error: nil, notice: nil }
  end

  def call(env)
    request = Rack::Request.new(env)
    case request.path
    when '/' then Rack::Response.new(render('index.html.erb'))
    when '/help' then Rack::Response.new(render('help.html.erb'))
    when '/best_results' then Rack::Response.new(render('best_results.html.erb'))
    when '/game'
      start_game unless @game
      Rack::Response.new(render('game.html.erb'))
    when '/submit_guess'
      submit_guess(request.params['guess'])
      Rack::Response.new { |response| response.redirect('/game') }
    when '/enter_name'
      enter_name(request.params['name'])
      Rack::Response.new { |response| response.redirect('/game') }
    when '/show_hint'
      show_hint
      Rack::Response.new { |response| response.redirect('/game') }
    else Rack::Response.new('Not found', 404)
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def break_the_lines(text)
    text.to_s.gsub(/\n/, '<br/>')
  end

  def start_game
    @game = nil if @game
    @game = RgHwCodebreaker::Game.new
    @game.start
    @attempts = []
    @show_hint = false
  end

  def submit_guess(guess)
    if @game.valid_guess?(guess)
      guess_result = @game.check_guess(guess)
      @attempts << { guess: guess, guess_result: guess_result }
    else
      @flash[:error] = 'Your input is invalid'
    end
  end

  def enter_name(player_name)
    current_result = [player_name, Date.today, 10 - @game.turns]
    RgHwCodebreaker::Cli.new.write_result_to_file(current_result)
    @flash[:notice] = 'Your result saved'
  end

  def show_hint
    @show_hint = true
    @hint = @game.any_hints_left? ? "Hint: #{@game.give_a_hint}***" : 'No hints left :('
  end
end
