require 'rails_helper'

RSpec.describe ExchangeParticipant, type: :model do
  describe '#attributes' do
    it { is_expected.to respond_to :fullname }
    it { is_expected.to respond_to :cellphone }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :birthdate }
    it { is_expected.to respond_to :password }
    it { is_expected.to respond_to :cellphone_contactable }
    it do
      expect(ExchangeParticipant.new).to define_enum_for(:scholarity)
        .with(%i[highschool incomplete_graduation graduating post_graduated
                 almost_graduated graduated other])
    end
  end

  describe '#validations' do
    it { is_expected.to validate_presence_of :fullname }
    it { is_expected.to validate_presence_of :cellphone }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_uniqueness_of :email }
    it { is_expected.to validate_presence_of :birthdate }
    it { is_expected.to validate_presence_of :password }
  end

  describe '#associations' do
    it { is_expected.to belong_to :registerable }
    it { is_expected.to belong_to :campaign }
    it { is_expected.to belong_to :local_committee }
    it { is_expected.to belong_to :university }
    it { is_expected.to belong_to :college_course }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for :campaign }
  end

  describe '#methods' do
    let(:exchange_participant) do
      create(:exchange_participant,
             fullname: 'Forrest Gump',
             registerable: build(:gv_participant), password: 'test')
    end

    describe '#decrypted_password' do
      it { expect(exchange_participant.password).not_to eq 'test' }
      it { expect(exchange_participant.decrypted_password).to eq 'test' }

      context 'when changing password' do
        before { exchange_participant.password = 'changed' }

        it { expect(exchange_participant.password).to eq 'changed' }
        it { expect(exchange_participant.decrypted_password).to eq 'changed' }
      end
    end

    describe '#first_name' do
      subject { exchange_participant.first_name }

      it { is_expected.to eq 'Forrest' }
    end

    describe '#last_name' do
      subject { exchange_participant.last_name }

      it { is_expected.to eq 'Gump' }
    end

    describe '#as_sqs' do
      subject { exchange_participant.as_sqs }

      let(:expected) do
        { exchange_participant_id: exchange_participant.id }
      end

      it { is_expected.to match_array expected }
    end
  end

  describe '#custom_validations' do
    describe 'age validation' do
      let(:younger_than_18) do
        build(:exchange_participant,
              birthdate: 18.years.ago + 1.day,
              registerable: build(:gv_participant))
      end
      let(:older_than_30) do
        build(:exchange_participant,
              birthdate: 30.years.ago - 1.day,
              registerable: build(:gv_participant))
      end
      let(:youth) do
        build(:exchange_participant, registerable: build(:gv_participant))
      end

      it { expect(younger_than_18).not_to be_valid }

      it { expect(older_than_30).not_to be_valid }

      it { expect(youth).to be_valid }
    end
  end
end
