shared_context 'user is signed in' do
  let(:user) { double('User') }
  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end
end
