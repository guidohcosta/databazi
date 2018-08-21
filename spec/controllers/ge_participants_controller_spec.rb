require 'rails_helper'

RSpec.describe GeParticipantsController, type: :controller do
  let(:english_level) { build(:english_level) }
  let(:exchange_participant) { build(:exchange_participant) }
  let(:ge_participant) do
    build(:ge_participant, english_level: english_level,
                           exchange_participant: exchange_participant)
  end

  describe '#create', aws: true do
    subject(:do_create) { post :create, params: { ge_participant: ge_params } }

    let(:ge_params) do
      {
        fullname: ge_participant.fullname,
        email: ge_participant.email,
        cellphone: ge_participant.cellphone,
        birthdate: ge_participant.birthdate,
        english_level: ge_participant.english_level.to_s,
        spanish_level: ge_participant.spanish_level.to_s,
        local_committee_id: exchange_participant.local_committee_id,
        university_id: exchange_participant.university_id,
        college_course_id: exchange_participant.college_course_id,
        password: exchange_participant.password
      }
    end
    let(:response) { JSON.parse(subject.body) }

    it { is_expected.to be_successful }

    context 'when successful' do
      before { SignUpWorker.stub(:perform_async) }

      it { expect { do_create }.to change(ExchangeParticipant, :count).by 1 }
      it { expect { do_create }.to change(GeParticipant, :count).by 1 }
      it { expect { do_create }.to change(EnglishLevel, :count).by 1 }
      it 'sends message to sqs' do
        do_create

        expect(SignUpWorker).to have_received(:perform_async)
      end

      describe 'response' do
        it { expect(response['status']).to eq 'success' }
      end
    end

    context 'when unsuccessful' do
      before do
        allow(participant_double).to receive(:save).and_return(false)
        allow(errors).to receive(:messages).and_return(['error'])
        allow(participant_double).to receive(:errors).and_return(errors)
        allow(controller)
          .to receive(:ge_participant).and_return(participant_double)
      end

      let(:participant_double) { instance_double(GeParticipant) }
      let(:errors) { instance_double(ActiveModel::Errors) }

      it { expect { do_create }.not_to change(ExchangeParticipant, :count) }
      it { expect { do_create }.not_to change(GeParticipant, :count) }
      it { expect { do_create }.not_to change(EnglishLevel, :count) }

      describe 'response' do
        it { expect(response['status']).to eq 'failure' }
      end
    end
  end
end
