require 'concerns/check_person_present'

class ExpaSignUp
  def self.call(params)
    new(params).call
  end

  attr_reader :exchange_participant, :status

  def initialize(params)
    @status = true
    @exchange_participant = ExchangeParticipant.find_by(
      id: params['exchange_participant_id']
    )
  end

  def call
    @status = send_data_to_expa(@exchange_participant)

    @status
  end

  private

  def submit_data(exchange_participant)
    HTTParty.post(
      'https://auth.aiesec.org/users/',
      body: {
        'authenticity_token' => authenticity_token,
        'utf8' => '✓',
        'user[email]' => exchange_participant.email,
        'user[first_name]' => exchange_participant.first_name,
        'user[last_name]' => exchange_participant.last_name,
        'user[password]' => exchange_participant.decrypted_password,
        'user[phone]' => exchange_participant.cellphone,
        'user[country]' => 'Brazil',
        'user[mc]' => '1606',
        'user[lc]' => exchange_participant.local_committee.expa_id,
        'user[lc_input]' => exchange_participant.local_committee.expa_id,
        'user[allow_phone_communication]' => exchange_participant.cellphone_contactable
      }
    )

    result.data&.check_person_present?
  end

  def exchange_participant_present?(exchange_participant)
    EXPAAPI::Client.query(
      ExistsQuery,
      variables: { email: exchange_participant.email }
    ).data&.check_person_present?
  end

  def agent
    Mechanize.new do |a|
      a.ssl_version = 'TLSv1'
      a.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end

  def sign_in_page
    agent.get('https://auth.aiesec.org/users/sign_in')
  end
end
