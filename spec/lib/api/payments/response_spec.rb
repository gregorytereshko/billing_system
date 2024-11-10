RSpec.describe Api::Payments::Response do
  let(:success_response) { described_class.new(status: 'success') }
  let(:failed_response) { described_class.new(status: 'failed') }
  let(:insufficient_funds_response) { described_class.new(status: 'insufficient_funds') }

  describe '#status' do
    it 'returns the status' do
      expect(success_response.status).to eq('success')
    end
  end

  describe '#success?' do
    it 'returns true if status is success' do
      expect(success_response.success?).to be true
    end

    it 'returns false if status is not success' do
      expect(failed_response.success?).to be false
    end
  end

  describe '#failed?' do
    it 'returns true if status is failed' do
      expect(failed_response.failed?).to be true
    end

    it 'returns false if status is not failed' do
      expect(success_response.failed?).to be false
    end
  end

  describe '#insufficient_funds?' do
    it 'returns true if status is insufficient_funds' do
      expect(insufficient_funds_response.insufficient_funds?).to be true
    end

    it 'returns false if status is not insufficient_funds' do
      expect(success_response.insufficient_funds?).to be false
    end
  end
end