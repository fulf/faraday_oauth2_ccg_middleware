RSpec.describe FaradayOauth2CcgMiddleware do
  let(:oauth_host) { 'https://oauth_host' }
  let(:token_url) { '/token_url' }
  let(:client_id) { 'client_id' }
  let(:client_secret) { 'client_secret' }
  let(:cache_store) { nil }

  let(:oauth2_ccg_config) do
    {
      oauth_host:    oauth_host,
      token_url:     token_url,
      client_id:     client_id,
      client_secret: client_secret,
      cache_store:   cache_store
    }
  end

  let(:oauth_response) do
    {
      access_token:       'access_token',
      expires_in:         1800,
      refresh_expires_in: 3600,
      refresh_token:      'refresh_token',
      token_type:         'bearer',
      session_state:      'session_state',
      scope:              'profile email'
    }
  end

  let(:oauth_faraday_mock) do
    Faraday.new do |f|
      f.adapter :test do |stub|
        stub.post(token_url) { [200, {}, oauth_response.to_json] }
      end
    end
  end

  before :each do
    allow(Faraday).to receive(:new).and_call_original
    allow(Faraday).to receive(:new).with(url: oauth_host).and_return(oauth_faraday_mock)
  end

  it 'calls the OAUTH token endpoint' do
    expect(oauth_faraday_mock).to receive(:post).with(
      token_url,
      client_id: client_id,
      client_secret: client_secret,
      grant_type: 'client_credentials'
    ).and_call_original

    Faraday.new do |f|
      f.request :oauth2_ccg, oauth2_ccg_config
      f.adapter(:test) { |stub| stub.get('/') { [200, {}, 'success'] } }
    end.get('/')
  end

  it 'sets the request Authorization header' do
    Faraday.new do |f|
      f.request :oauth2_ccg, oauth2_ccg_config

      f.adapter :test do |stub|
        stub.get('/') do |env|
          expect(env.request_headers).to have_key('Authorization')
          expect(env.request_headers['Authorization']).to eq("Bearer #{oauth_response[:access_token]}")

          [200, {}, 'success']
        end
      end
    end.get('/')
  end

  context 'with caching' do
    let(:cache_store) do
      double('cache_store')
    end

    let(:cache_key) { Digest::MD5.hexdigest("#{oauth_host}#{client_id}#{client_secret}") }

    it 'should fetch the cached result if available' do
      expect(cache_store).to receive(:fetch).with(cache_key, expires_in: oauth_response[:expires_in]) do |*_args, &blk|
        expect(blk.call).to eq(oauth_response[:access_token])
      end

      Faraday.new do |f|
        f.request :oauth2_ccg, oauth2_ccg_config
        f.adapter(:test) { |stub| stub.get('/') { [200, {}, 'success'] } }
      end.get('/')
    end
  end
end
