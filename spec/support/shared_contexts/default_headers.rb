shared_context 'with default headers' do
  let(:headers) do
    {
      ACCEPT: 'application/json'
    }
  end

  before do
    request&.headers&.merge! headers
  end
end

