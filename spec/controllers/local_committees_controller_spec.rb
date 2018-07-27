require 'rails_helper'

RSpec.describe LocalCommitteesController, type: :controller do
  describe "#index" do
    subject(:do_index) { get :index }
    let(:response) { JSON.parse(subject.body) }

    it { is_expected.to be_successful }

    describe "response" do
      context "empty list" do
        it { expect(response).to be_empty }
      end

      context "filled list" do
        before { create_list(:local_committee, 3) }
        it { expect(response.first.keys).to match_array(['id', 'name', 'podio_id', 'expa_id']) }
        it { expect(response.count).to eq LocalCommittee.count }
      end
    end
  end
end