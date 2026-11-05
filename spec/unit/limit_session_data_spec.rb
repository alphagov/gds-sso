RSpec.describe GDS::SSO::LimitSessionData do
  subject(:middleware) { described_class.new(app) }
  let(:app) { ->(_env) { [200, { "content-type" => "text/plain" }, %w[ok]] } }

  context "when the session isn't loaded" do
    let(:session) { double("Unloaded Session", loaded?: false, to_hash: {}) }

    it "passes through without reading an unloaded session" do
      status, _headers, body = middleware.call("rack.session" => session)

      expect(status).to eq(200)
      expect(body).to eq(%w[ok])
      expect(session).not_to have_received(:to_hash)
    end
  end

  context "when the session is loaded" do
    let(:session) { double("Loaded Session", loaded?: true, to_hash:, delete:) }
    let(:to_hash) { { "omniauth.params" => { "payload" => "A" * 3000 } } }
    let(:delete) { ->(key) { to_hash.delete(key) } }

    it "will inspect a loaded session" do
      status, = middleware.call("rack.session" => session)

      expect(status).to eq(400)
      expect(session).to have_received(:to_hash).twice
      expect(session).to have_received(:delete).with("omniauth.params")
    end
  end
end
