require 'rails_helper'

RSpec.describe AuthenticationController, type: :request do
  it 'returns unauthorized' do
    post "/authenticate?email=bademail&password=badpassowrd"
    expect(response.status).to eq(401)
  end
end
