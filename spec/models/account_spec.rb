# Encoding: utf-8

# Copyright (c) 2014, Richard Buggy
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

# Tests for the plan model
RSpec.describe Account, type: :model do
  it 'should have valid factory' do
    expect(FactoryGirl.build(:account)).to be_valid
  end

  describe '.active' do
    # t.boolean :active, default: true, null: false
  end

  describe '.address_city' do
    it 'must be 120 characters or less' do
      account = FactoryGirl.build(:account, address_city: Faker::Lorem.characters(121))
      expect(account).to_not be_valid
      expect(account.errors[:address_city]).to include 'is too long (maximum is 120 characters)'
    end
  end

  describe '.address_country' do
    it 'must be 2 characters or less' do
      account = FactoryGirl.build(:account, address_country: Faker::Lorem.characters(3))
      expect(account).to_not be_valid
      expect(account.errors[:address_country]).to include 'is too long (maximum is 2 characters)'
    end
  end

  describe '.address_country_name' do
    context 'known .address_country' do
      it 'looks up the name' do
        account = FactoryGirl.build(:account, address_country: 'AU')
        expect(account.address_country_name).to eq 'Australia'
      end
    end

    context 'unknown .address_country' do
      it 'uses .address_country' do
        account = FactoryGirl.build(:account, address_country: 'XX')
        expect(account.address_country_name).to eq 'XX'
      end
    end
  end

  describe '.address_line1' do
    it 'must be 120 characters or less' do
      account = FactoryGirl.build(:account, address_line1: Faker::Lorem.characters(121))
      expect(account).to_not be_valid
      expect(account.errors[:address_line1]).to include 'is too long (maximum is 120 characters)'
    end
  end

  describe '.address_line2' do
    it 'must be 120 characters or less' do
      account = FactoryGirl.build(:account, address_line2: Faker::Lorem.characters(121))
      expect(account).to_not be_valid
      expect(account.errors[:address_line2]).to include 'is too long (maximum is 120 characters)'
    end
  end

  describe '.address_state' do
    it 'must be 60 characters or less' do
      account = FactoryGirl.build(:account, address_state: Faker::Lorem.characters(61))
      expect(account).to_not be_valid
      expect(account.errors[:address_state]).to include 'is too long (maximum is 60 characters)'
    end
  end

  describe '.address_zip' do
    it 'must be 20 characters or less' do
      account = FactoryGirl.build(:account, address_zip: Faker::Lorem.characters(21))
      expect(account).to_not be_valid
      expect(account.errors[:address_zip]).to include 'is too long (maximum is 20 characters)'
    end
  end

  describe '.cancel' do
  end

  describe '.cancelled_at' do
    # t.datetime :cancelled_at
  end

  describe '.cancellation_category' do
    it 'must be 255 characters or less' do
      account = FactoryGirl.build(:account,
                                  cancellation_category: Faker::Lorem.characters(256),
                                  cancelled_at: '2014-01-01 00:00:00')
      expect(account).to_not be_valid
      expect(account.errors[:cancellation_category]).to include 'is too long (maximum is 255 characters)'
    end

    context 'when not cancelled' do
      it 'is not required' do
        account = FactoryGirl.build(:account, cancellation_category: '', cancelled_at: '')
        expect(account).to be_valid
      end
    end

    context 'when cancelled' do
      it 'is required' do
        account = FactoryGirl.build(:account,
                                    cancellation_category: '',
                                    cancellation_reason: 'xxx',
                                    cancellation_message: 'xxx',
                                    cancelled_at: '2014-01-01 00:00:00')
        expect(account).to_not be_valid
        expect(account.errors[:cancellation_category]).to include 'can\'t be blank'
      end
    end
  end

  describe '.cancellation_message' do
    it 'must be 255 characters or less' do
      account = FactoryGirl.build(:account,
                                  cancellation_message: Faker::Lorem.characters(256),
                                  cancelled_at: '2014-01-01 00:00:00')
      expect(account).to_not be_valid
      expect(account.errors[:cancellation_message]).to include 'is too long (maximum is 255 characters)'
    end

    context 'when not cancelled' do
      it 'is not required' do
        account = FactoryGirl.build(:account, cancellation_message: '', cancelled_at: '')
        expect(account).to be_valid
      end
    end

    context 'when cancelled' do
      it 'is required' do
        account = FactoryGirl.build(:account,
                                    cancellation_category: 'xxx',
                                    cancellation_reason: 'xxx',
                                    cancellation_message: '',
                                    cancelled_at: '2014-01-01 00:00:00')
        expect(account).to_not be_valid
        expect(account.errors[:cancellation_message]).to include 'can\'t be blank'
      end
    end
  end

  describe '.cancellation_reason' do
    it 'must be 255 characters or less' do
      account = FactoryGirl.build(:account,
                                  cancellation_reason: Faker::Lorem.characters(256),
                                  cancelled_at: '2014-01-01 00:00:00')
      expect(account).to_not be_valid
      expect(account.errors[:cancellation_reason]).to include 'is too long (maximum is 255 characters)'
    end

    context 'when not cancelled' do
      it 'is not required' do
        account = FactoryGirl.build(:account, cancellation_reason: '', cancelled_at: '')
        expect(account).to be_valid
      end
    end

    context 'when cancelled' do
      it 'is required' do
        account = FactoryGirl.build(:account,
                                    cancellation_category: 'xxx',
                                    cancellation_reason: '',
                                    cancellation_message: 'xxx',
                                    cancelled_at: '2014-01-01 00:00:00')
        expect(account).to_not be_valid
        expect(account.errors[:cancellation_reason]).to include 'can\'t be blank'
      end
    end
  end

  describe '.card_token' do
    it 'must be 60 characters or less' do
      account = FactoryGirl.build(:account, card_token: Faker::Lorem.characters(61))
      expect(account).to_not be_valid
      expect(account.errors[:card_token]).to include 'is too long (maximum is 60 characters)'
    end

    it 'is required' do
      account = FactoryGirl.build(:account, card_token: '')
      expect(account).to_not be_valid
      expect(account.errors[:card_token]).to include 'can\'t be blank'
    end
  end

  describe '.company_name' do
    it 'must be 255 characters or less' do
      account = FactoryGirl.build(:account, company_name: Faker::Lorem.characters(256))
      expect(account).to_not be_valid
      expect(account.errors[:company_name]).to include 'is too long (maximum is 255 characters)'
    end

    it 'is required' do
      account = FactoryGirl.build(:account, company_name: '')
      expect(account).to_not be_valid
      expect(account.errors[:company_name]).to include 'can\'t be blank'
    end
  end

  describe '.email' do
    it 'must be 255 characters or less' do
      account = FactoryGirl.build(:account, email: Faker::Lorem.characters(256))
      expect(account).to_not be_valid
      expect(account.errors[:email]).to include 'is too long (maximum is 255 characters)'
    end

    it 'is required' do
      account = FactoryGirl.build(:account, email: '')
      expect(account).to_not be_valid
      expect(account.errors[:email]).to include 'can\'t be blank'
    end
  end

  describe '.enable' do
  end

  describe '.expires_at' do
    # validates :expires_at, presence: true
  end

  describe '.pause' do
  end

  describe '.paused_plan_id' do
    it 'must be an integer' do
      account = FactoryGirl.build(:account, paused_plan_id: 5.3)
      expect(account).to be_valid
      expect(account.paused_plan_id).to eq 5
    end
  end

  describe '.plan_id' do
    it 'must be an integer' do
      account = FactoryGirl.build(:account, plan_id: 5.3)
      expect(account).to be_valid
      expect(account.plan_id).to eq 5
    end

    it 'is required' do
      account = FactoryGirl.build(:account, plan_id: '')
      expect(account).to_not be_valid
      expect(account.errors[:plan_id]).to include 'can\'t be blank'
    end
  end

  describe '.stripe_customer_id' do
    it 'must be 60 characters or less' do
      account = FactoryGirl.build(:account, stripe_customer_id: Faker::Lorem.characters(61))
      expect(account).to_not be_valid
      expect(account.errors[:stripe_customer_id]).to include 'is too long (maximum is 60 characters)'
    end
  end

  describe '.stripe_subscription_id' do
    it 'must be 60 characters or less' do
      account = FactoryGirl.build(:account, stripe_subscription_id: Faker::Lorem.characters(61))
      expect(account).to_not be_valid
      expect(account.errors[:stripe_subscription_id]).to include 'is too long (maximum is 60 characters)'
    end
  end

  describe '.to_s' do
    it 'uses the company name' do
      account = FactoryGirl.build(:account)
      expect(account.to_s).to eq account.company_name
    end
  end
end
