RSpec.describe CodebreakerApp do
  let(:app) { CodebreakerApp }

  context 'get to /' do
    before { get '/' }

    specify { expect(last_response).to be_ok }

    it 'clears session' do
      expect(last_request.env['rack.session']).to be_empty
    end

    it 'renders index.html.erb template' do
      expect(last_response.body).to include(File.read('lib/views/index.html.erb'))
    end
  end

  context 'get to /help' do
    before { get '/help' }

    specify { expect(last_response).to be_ok }

    it 'renders help.html.erb template' do
      expect(last_response.body).to include(ERB.new('lib/views/help.html.erb').result
        .gsub('lib/views/help.html.erb', ''))
    end
  end

  context 'get to /best_results' do
    before { get '/best_results' }

    specify { expect(last_response).to be_ok }

    it 'renders best_results.html.erb template' do
      expect(last_response.body).to include(ERB.new('lib/views/best_results.html.erb').result
        .gsub('lib/views/best_results.html.erb', ''))
    end
  end

  context 'get to /game' do
    before { get '/game' }

    specify { expect(last_response).to be_ok }

    context 'new game starting' do
      before do
        allow_any_instance_of(CodebreakerApp).to receive(:start_game)
        allow_any_instance_of(CodebreakerApp).to receive(:render).and_return('rendered')
      end

      context 'game has not been started yet' do
        it 'starts new game' do
          expect_any_instance_of(CodebreakerApp).to receive(:start_game)

          get '/game'
        end
      end

      context 'game has been already started' do
        before do
          env 'rack.session', game: RgHwCodebreaker::Game.new
        end

        it 'does not start new game' do
          expect_any_instance_of(CodebreakerApp).not_to receive(:start_game)

          get '/game'
        end
      end
    end

    it 'renders game.html.erb template' do
      expect(last_response.body).to include(ERB.new('lib/views/game.html.erb').result
        .gsub('lib/views/game.html.erb', ''))
    end
  end

  context 'post to /submit_guess' do
    before do
      env 'rack.session', game: RgHwCodebreaker::Game.new,
                          attempts: []
      post '/submit_guess', 'guess' => '1111'
      follow_redirect!
    end

    specify { expect(last_response).to be_ok }

    it 'submits user guess' do
      expect_any_instance_of(CodebreakerApp).to receive(:submit_guess).with('1111')

      post '/submit_guess', 'guess' => '1111'
    end

    it 'redirects to /game' do
      expect(last_request.url).to eq('http://example.org/game')
    end
  end

  context 'post to /enter_name' do
    before do
      allow_any_instance_of(CodebreakerApp).to receive(:enter_name).with('Username').and_return('saved')
      post '/enter_name', 'name' => 'Username'
      follow_redirect!
    end

    specify { expect(last_response).to be_ok }

    it 'lets user to enter their name' do
      expect_any_instance_of(CodebreakerApp).to receive(:enter_name).with('Username')

      post '/enter_name', 'name' => 'Username'
    end

    it 'redirects to /game' do
      expect(last_request.url).to eq('http://example.org/best_results')
    end
  end

  context 'get to /show_hint' do
    before do
      env 'rack.session', game: RgHwCodebreaker::Game.new,
                          attempts: []
      get '/show_hint'
      follow_redirect!
    end

    specify { expect(last_response).to be_ok }

    it 'shows user a hint' do
      expect_any_instance_of(CodebreakerApp).to receive(:show_hint)

      get '/show_hint'
    end

    it 'redirects to /game' do
      expect(last_request.url).to eq('http://example.org/game')
    end
  end

  context 'get to /unknown_url' do
    before { get '/unknown_url' }

    specify { expect(last_response).not_to be_ok }

    it "returns the body with 'Not found' message" do
      expect(last_response.body).to eq "Not found"
    end
  end
end
