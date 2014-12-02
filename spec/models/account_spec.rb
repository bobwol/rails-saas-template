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

  describe '.admin_all_users' do
    it 'makes all users an account admin' do
      account = FactoryGirl.create(:account)
      permission0 = FactoryGirl.create(:user_permission, account: account)
      permission1 = FactoryGirl.create(:user_permission, account: account)
      expect(permission0.account_admin).to eq false
      expect(permission1.account_admin).to eq false
      account.admin_all_users
      account = Account.find(account.id)
      account.user_permissions.each do |up|
        expect(up.account_admin).to eq true
      end
    end
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

  describe '.app_events' do
    it 'connects to AppEvent' do
      account = FactoryGirl.create(:account)
      app_event1 = FactoryGirl.create(:app_event, account: account)
      app_event2 = FactoryGirl.create(:app_event, account: account)
      expect(account.app_events.count).to eq 2
      expect(account.app_events).to include app_event1
      expect(account.app_events).to include app_event2
    end
  end

  describe '.cancel' do
    before :each do
      @cancellation_category = FactoryGirl.create(:cancellation_category)
    end
    context 'on success' do
      it 'returns true on cancellation' do
        account = FactoryGirl.create(:account)
        result = account.cancel(cancellation_category: @cancellation_category,
                                cancellation_reason: nil,
                                cancellation_message: 'xxx')
        expect(result).to eq true
      end

      it 'sets active to false' do
        account = FactoryGirl.create(:account)
        account.cancel(cancellation_category: @cancellation_category,
                       cancellation_reason: nil,
                       cancellation_message: 'xxx')
        expect(account.active).to eq false
      end

      it 'sets cancelled_at' do
        account = FactoryGirl.create(:account)
        account.cancel(cancellation_category: @cancellation_category,
                       cancellation_reason: nil,
                       cancellation_message: 'xxx')
        expect(account.cancelled_at).to_not be_nil
      end
    end

    it 'returns false on failure' do
      account = FactoryGirl.create(:account)
      result = account.cancel(cancellation_category_id: nil, cancellation_reason_id: nil, cancellation_message: '')
      expect(result).to eq false
    end
  end

  describe '.cancelled_at' do
    # t.datetime :cancelled_at
  end

  describe '.cancellation_category_id' do
    context 'when not cancelled' do
      it 'is not required' do
        account = FactoryGirl.build(:account, cancellation_category_id: nil, cancelled_at: '')
        expect(account).to be_valid
      end
    end

    context 'when cancelled' do
      it 'is required' do
        account = FactoryGirl.build(:account,
                                    cancellation_category: nil,
                                    cancelled_at: '2014-01-01 00:00:00')
        expect(account).to_not be_valid
        expect(account.errors[:cancellation_category_id]).to include 'can\'t be blank'
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

    context 'when require_cancellation_message returns false' do
      it 'is not required' do
        account = FactoryGirl.build(:account, cancellation_message: '')
        allow(account).to receive(:require_cancellation_message).and_return(false)
        expect(account).to be_valid
      end
    end

    context 'when require_cancellation_message returns true' do
      it 'is required' do
        account = FactoryGirl.build(:account, cancellation_message: '')
        allow(account).to receive(:require_cancellation_message).and_return(true)
        expect(account).to_not be_valid
        expect(account.errors[:cancellation_message]).to include 'can\'t be blank'
      end
    end
  end

  describe '.cancellation_reason_id' do
    context 'when require_cancellation_reason_id returns false' do
      it 'is not required' do
        account = FactoryGirl.build(:account, cancellation_reason_id: nil)
        allow(account).to receive(:require_cancellation_reason_id).and_return(false)
        expect(account).to be_valid
      end
    end

    context 'when require_cancellation_reason_id returns true' do
      it 'is required' do
        account = FactoryGirl.build(:account, cancellation_reason_id: nil)
        allow(account).to receive(:require_cancellation_reason_id).and_return(true)
        expect(account).to_not be_valid
        expect(account.errors[:cancellation_reason_id]).to include 'can\'t be blank'
      end
    end
  end

  describe '.card_token' do
    it 'must be 60 characters or less' do
      account = FactoryGirl.build(:account, card_token: Faker::Lorem.characters(61))
      expect(account).to_not be_valid
      expect(account.errors[:card_token]).to include 'is too long (maximum is 60 characters)'
    end

    it 'is required if plan requires card upfront' do
      plan = FactoryGirl.create(:plan, require_card_upfront: true)
      account = FactoryGirl.build(:account, card_token: '', plan: plan)
      expect(account).to_not be_valid
      expect(account.errors[:card_token]).to include 'can\'t be blank'
    end

    it 'is not requried if plan does not requires card upfront' do
      plan = FactoryGirl.create(:plan, require_card_upfront: false)
      account = FactoryGirl.build(:account, card_token: '', plan: plan)
      expect(account).to be_valid
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

  describe '.custom_path' do
    before :each do
      @plan = FactoryGirl.create(:plan, allow_custom_path: true)
    end

    it 'must be 2 characters or less' do
      account = FactoryGirl.build(:account, plan: @plan, custom_path: 'A')
      expect(account).to_not be_valid
      expect(account.errors[:custom_path]).to include 'is too short (minimum is 2 characters)'
    end

    it 'must be 60 characters or less' do
      account = FactoryGirl.build(:account, plan: @plan, custom_path: Faker::Lorem.characters(61))
      expect(account).to_not be_valid
      expect(account.errors[:custom_path]).to include 'is too long (maximum is 60 characters)'
    end

    it 'can be nil' do
      account = FactoryGirl.build(:account, plan: @plan, custom_path: nil)
      expect(account).to be_valid
    end

    it 'cannot be numeric' do
      account = FactoryGirl.build(:account, plan: @plan, custom_path: '123')
      expect(account).to_not be_valid
      expect(account.errors[:custom_path]).to include 'must contain at least one letter'
    end

    it 'can start with a number' do
      account = FactoryGirl.build(:account, plan: @plan, custom_path: '123me')
      expect(account).to be_valid
    end

    it 'must be unique if not nil' do
      account1 = FactoryGirl.create(:account, plan: @plan, custom_path: '123mex')
      expect(account1).to be_valid

      account2 = FactoryGirl.build(:account, plan: @plan, custom_path: '123mex')
      expect(account2).to_not be_valid
      expect(account2.errors[:custom_path]).to include 'has already been taken'
    end

    it 'can be nil if others are' do
      account1 = FactoryGirl.create(:account, plan: @plan, custom_path: nil)
      expect(account1).to be_valid

      account2 = FactoryGirl.build(:account, plan: @plan, custom_path: nil)
      expect(account2).to be_valid
    end

    it 'cannot contain illegal characters' do
      account = FactoryGirl.build(:account, plan: @plan, custom_path: '123&me')
      expect(account).to_not be_valid
      expect(account.errors[:custom_path]).to include 'can only contain letters and numbers'
    end
  end

  describe '.destroy' do
    it 'destroys related AppEvents' do
      account = FactoryGirl.create(:account)
      FactoryGirl.create(:app_event, account: account)
      expect { account.destroy }.to change { AppEvent.count }.by(-1)
      expect(AppEvent.where(account_id: account.id).count).to eq 0
    end

    it 'destroys related UserInvitations' do
      account = FactoryGirl.create(:account)
      FactoryGirl.create(:user_invitation, account: account)
      expect { account.destroy }.to change { UserInvitation.count }.by(-1)
      expect(UserInvitation.where(account_id: account.id).count).to eq 0
    end

    it 'destroys related UserPermissions' do
      account = FactoryGirl.create(:account)
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:user_permission, account: account, user: user)
      expect { account.destroy }.to change { UserPermission.count }.by(-1)
      expect(UserPermission.where(account_id: account.id).count).to eq 0
    end

    it 'does not destroy related Users' do
      account = FactoryGirl.create(:account)
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:user_permission, account: account, user: user)
      expect { account.destroy }.to change { User.count }.by(0)
      expect(User.where(id: user.id).count).to eq 1
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

  describe '.hostname' do
    before :each do
      @plan = FactoryGirl.create(:plan, allow_hostname: true)
    end

    it 'must be 255 characters or less' do
      account = FactoryGirl.build(:account, plan: @plan, hostname: Faker::Lorem.characters(256))
      expect(account).to_not be_valid
      expect(account.errors[:hostname]).to include 'is too long (maximum is 255 characters)'
    end

    it 'is required' do
      account = FactoryGirl.build(:account, plan: @plan, hostname: nil)
      expect(account).to be_valid
    end

    it 'can be a domain name' do
      account = FactoryGirl.build(:account, plan: @plan, hostname: 'my-app.example.com')
      expect(account).to be_valid
    end

    it 'must be unique if not nil' do
      account1 = FactoryGirl.create(:account, plan: @plan, hostname: 'www.example.com')
      expect(account1).to be_valid

      account2 = FactoryGirl.build(:account, plan: @plan, hostname: 'www.example.com')
      expect(account2).to_not be_valid
      expect(account2.errors[:hostname]).to include 'has already been taken'
    end

    it 'can be nil if others are' do
      account1 = FactoryGirl.create(:account, plan: @plan, hostname: nil)
      expect(account1).to be_valid

      account2 = FactoryGirl.build(:account, plan: @plan, hostname: nil)
      expect(account2).to be_valid
    end

    it 'cannot contain illegal characters' do
      account = FactoryGirl.build(:account, plan: @plan, hostname: 'www&example.com')
      expect(account).to_not be_valid
      expect(account.errors[:hostname]).to include 'is invalid'
    end
  end

  describe '.find_by_hostname' do
    context 'plan that allows hostname' do
      before :each do
        @plan = FactoryGirl.create(:plan, allow_hostname: true)
      end

      it 'finds active accounts' do
        account = FactoryGirl.create(:account, active: true, hostname: 'my-app.example.com', plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_hostname('my-app.example.com')
        expect(a).to eq account
      end

      it 'does not find inactive accounts' do
        account = FactoryGirl.create(:account, active: false, hostname: 'my-app.example.com', plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_hostname('my-app.example.com')
        expect(a).to be_nil
      end
    end

    context 'plan that does not allows hostname' do
      before :each do
        @plan = FactoryGirl.create(:plan, allow_hostname: false)
      end

      it 'does not find active accounts' do
        account = FactoryGirl.create(:account, active: true, hostname: 'my-app.example.com', plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_hostname('my-app.example.com')
        expect(a).to be_nil
      end

      it 'does not find inactive accounts' do
        account = FactoryGirl.create(:account, active: false, hostname: 'my-app.example.com', plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_hostname('my-app.example.com')
        expect(a).to be_nil
      end
    end
  end

  describe '.find_by_path' do
    context 'plan that allow custom path' do
      before :each do
        @plan = FactoryGirl.create(:plan, allow_custom_path: true)
      end

      it 'finds active accounts by ID' do
        account = FactoryGirl.create(:account, active: true, plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_path(account.id)
        expect(a).to eq account
      end

      it 'does not find inactive accounts by ID' do
        account = FactoryGirl.create(:account, active: false, plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_path(account.id)
        expect(a).to be_nil
      end

      it 'finds active accounts by custom path' do
        account = FactoryGirl.create(:account, active: true, plan: @plan, custom_path: 'abc')
        expect(account).to be_valid

        a = Account.find_by_path('abc')
        expect(a).to eq account
      end

      it 'does not find inactive accounts by  custom path' do
        account = FactoryGirl.create(:account, active: false, plan: @plan, custom_path: 'abc')
        expect(account).to be_valid

        a = Account.find_by_path('abc')
        expect(a).to be_nil
      end
    end

    context 'plan that do not allow custom path' do
      before :each do
        @plan = FactoryGirl.create(:plan, allow_custom_path: false)
      end

      it 'finds active accounts by ID' do
        account = FactoryGirl.create(:account, active: true, plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_path(account.id)
        expect(a).to eq account
      end

      it 'does not find inactive accounts by ' do
        account = FactoryGirl.create(:account, active: false, plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_path(account.id)
        expect(a).to be_nil
      end

      it 'does not find active accounts by custom path' do
        account = FactoryGirl.create(:account, active: true, plan: @plan, custom_path: 'abc')
        expect(account).to be_valid

        a = Account.find_by_path('abc')
        expect(a).to be_nil
      end

      it 'does not find inactive accounts by  custom path' do
        account = FactoryGirl.create(:account, active: false, plan: @plan, custom_path: 'abc')
        expect(account).to be_valid

        a = Account.find_by_path('abc')
        expect(a).to be_nil
      end
    end
  end

  describe '.find_by_path!' do
    context 'plan that allow custom path' do
      before :each do
        @plan = FactoryGirl.create(:plan, allow_custom_path: true)
      end

      it 'finds active accounts by ID' do
        account = FactoryGirl.create(:account, active: true, plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_path!(account.id)
        expect(a).to eq account
      end

      it 'does not find inactive accounts by ID' do
        account = FactoryGirl.create(:account, active: false, plan: @plan)
        expect(account).to be_valid

        expect { Account.find_by_path!(account.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'finds active accounts by custom path' do
        account = FactoryGirl.create(:account, active: true, plan: @plan, custom_path: 'abc')
        expect(account).to be_valid

        a = Account.find_by_path!('abc')
        expect(a).to eq account
      end

      it 'does not find inactive accounts by  custom path' do
        account = FactoryGirl.create(:account, active: false, plan: @plan, custom_path: 'abc')
        expect(account).to be_valid

        expect { Account.find_by_path!('abc') }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'plan that do not allow custom path' do
      before :each do
        @plan = FactoryGirl.create(:plan, allow_custom_path: false)
      end

      it 'finds active accounts by ID' do
        account = FactoryGirl.create(:account, active: true, plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_path!(account.id)
        expect(a).to eq account
      end

      it 'does not find inactive accounts by ' do
        account = FactoryGirl.create(:account, active: false, plan: @plan)
        expect(account).to be_valid

        expect { Account.find_by_path!(account.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'does not find active accounts by custom path' do
        account = FactoryGirl.create(:account, active: true, plan: @plan, custom_path: 'abc')
        expect(account).to be_valid

        expect { Account.find_by_path!('abc') }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'does not find inactive accounts by  custom path' do
        account = FactoryGirl.create(:account, active: false, plan: @plan, custom_path: 'abc')
        expect(account).to be_valid

        expect { Account.find_by_path!('abc') }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.find_by_subdomain' do
    context 'plan that allows subdomain' do
      before :each do
        @plan = FactoryGirl.create(:plan, allow_subdomain: true)
      end

      it 'finds active accounts' do
        account = FactoryGirl.create(:account, active: true, subdomain: 'my-app', plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_subdomain('my-app')
        expect(a).to eq account
      end

      it 'does not find inactive accounts' do
        account = FactoryGirl.create(:account, active: false, subdomain: 'my-app', plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_subdomain('my-app')
        expect(a).to be_nil
      end
    end

    context 'plan that does not allows subdomain' do
      before :each do
        @plan = FactoryGirl.create(:plan, allow_subdomain: false)
      end

      it 'does not find active accounts' do
        account = FactoryGirl.create(:account, active: true, subdomain: 'my-app', plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_subdomain('my-app')
        expect(a).to be_nil
      end

      it 'does not find inactive accounts' do
        account = FactoryGirl.create(:account, active: false, subdomain: 'my-app', plan: @plan)
        expect(account).to be_valid

        a = Account.find_by_subdomain('my-app')
        expect(a).to be_nil
      end
    end
  end

  describe '.pause' do
    it 'fails if there is no paused plan' do
      plan = FactoryGirl.create(:plan, paused_plan: nil)
      account = FactoryGirl.build(:account, plan: plan)
      expect(account.pause).to eq false
    end

    it 'succeeds if there is paused plan' do
      paused_plan = FactoryGirl.create(:plan)
      plan = FactoryGirl.create(:plan, paused_plan: paused_plan)
      account = FactoryGirl.build(:account, plan: plan)
      expect(account.pause).to eq true
    end
  end

  describe '.paused_plan_id' do
    it 'must be an integer' do
      account = FactoryGirl.build(:account, paused_plan_id: 5.3)
      expect(account).to be_valid
      expect(account.paused_plan_id).to eq 5
    end
  end

  describe '.paused_plan_stripe_id' do
    it 'returns the paused plans allow_subdomain' do
      paused_plan = FactoryGirl.create(:plan)
      account = FactoryGirl.build(:account, paused_plan: paused_plan)

      stripe_id = "plan_#{paused_plan.id}"
      paused_plan.stripe_id = stripe_id
      expect(account.paused_plan_stripe_id).to eq stripe_id
    end
  end

  describe '.plan_allow_custom_path' do
    it 'returns the plans allow_custom_path' do
      account = FactoryGirl.build(:account)
      plan = account.plan

      plan.allow_custom_path = true
      expect(account.plan_allow_custom_path).to eq true

      plan.allow_custom_path = false
      expect(account.plan_allow_custom_path).to eq false
    end
  end

  describe '.plan_allow_hostname' do
    it 'returns the plans allow_hostname' do
      account = FactoryGirl.build(:account)
      plan = account.plan

      plan.allow_hostname = true
      expect(account.plan_allow_hostname).to eq true

      plan.allow_hostname = false
      expect(account.plan_allow_hostname).to eq false
    end
  end

  describe '.plan_allow_subdomain' do
    it 'returns the plans allow_subdomain' do
      account = FactoryGirl.build(:account)
      plan = account.plan

      plan.allow_subdomain = true
      expect(account.plan_allow_subdomain).to eq true

      plan.allow_subdomain = false
      expect(account.plan_allow_subdomain).to eq false
    end
  end

  describe '.plan' do
    it 'links to plan' do
      plan = FactoryGirl.create(:plan)
      account = FactoryGirl.build(:account, plan: plan)
      expect(account).to be_valid
      expect(account.plan).to eq plan
    end
  end

  describe '.plan_id' do
    it 'is required' do
      account = FactoryGirl.build(:account, plan_id: '')
      expect(account).to_not be_valid
      expect(account.errors[:plan_id]).to include 'can\'t be blank'
    end
  end

  describe '.plan_stripe_id' do
    it 'returns the plans allow_subdomain' do
      account = FactoryGirl.build(:account)
      plan = account.plan

      stripe_id = "plan_#{plan.id}"
      plan.stripe_id = stripe_id
      expect(account.plan_stripe_id).to eq stripe_id
    end
  end

  describe '.require_cancellation_message' do
    it 'is false if there cancelled_at is nil' do
      cancellation_category = FactoryGirl.create(:cancellation_category, allow_message: true, require_message: true)
      cancellation_reason = FactoryGirl.create(:cancellation_reason,
                                               cancellation_category: cancellation_category,
                                               allow_message: true,
                                               require_message: true)
      account = FactoryGirl.build(:account,
                                  cancelled_at: nil,
                                  cancellation_category: cancellation_category,
                                  cancellation_reason: cancellation_reason)
      expect(account.require_cancellation_message).to eq false
    end

    it 'is false if cancellation_category is nil' do
      account = FactoryGirl.build(:account,
                                  cancelled_at: DateTime.now,
                                  cancellation_category: nil,
                                  cancellation_reason: nil)
      expect(account.require_cancellation_message).to eq false
    end

    it 'is true if cancellation_category requires message' do
      cancellation_category = FactoryGirl.create(:cancellation_category, allow_message: true, require_message: true)
      account = FactoryGirl.build(:account,
                                  cancelled_at: DateTime.now,
                                  cancellation_category: cancellation_category,
                                  cancellation_reason: nil)
      expect(account.require_cancellation_message).to eq true
    end

    it 'is false if cancellation_reason is nil' do
      cancellation_category = FactoryGirl.create(:cancellation_category, allow_message: true, require_message: false)
      account = FactoryGirl.build(:account,
                                  cancelled_at: DateTime.now,
                                  cancellation_category: cancellation_category,
                                  cancellation_reason: nil)
      expect(account.require_cancellation_message).to eq false
    end

    it 'is true if cancellation_reason requires message' do
      cancellation_category = FactoryGirl.create(:cancellation_category, allow_message: true, require_message: false)
      cancellation_reason = FactoryGirl.create(:cancellation_reason,
                                               cancellation_category: cancellation_category,
                                               allow_message: true,
                                               require_message: true)
      account = FactoryGirl.build(:account,
                                  cancelled_at: DateTime.now,
                                  cancellation_category: cancellation_category,
                                  cancellation_reason: cancellation_reason)
      expect(account.require_cancellation_message).to eq true
    end

    it 'is false if cancellation_category and cancellation_reason do not require message' do
      cancellation_category = FactoryGirl.create(:cancellation_category, allow_message: true, require_message: false)
      cancellation_reason = FactoryGirl.create(:cancellation_reason,
                                               cancellation_category: cancellation_category,
                                               allow_message: true,
                                               require_message: false)
      account = FactoryGirl.build(:account,
                                  cancelled_at: DateTime.now,
                                  cancellation_category: cancellation_category,
                                  cancellation_reason: cancellation_reason)
      expect(account.require_cancellation_message).to eq false
    end
  end

  describe '.require_cancellation_reason_id' do
    it 'is false if cancelled_at is nil' do
      cancellation_category = FactoryGirl.create(:cancellation_category)
      account = FactoryGirl.build(:account, cancelled_at: nil, cancellation_category: cancellation_category)
      expect(account.require_cancellation_reason_id).to eq false
    end

    it 'is false if cancellation_category is nil' do
      account = FactoryGirl.build(:account, cancelled_at: DateTime.now, cancellation_category: nil)
      expect(account.require_cancellation_reason_id).to eq false
    end

    it 'is true if there are cancellation_reasons' do
      cancellation_category = FactoryGirl.create(:cancellation_category)
      FactoryGirl.create(:cancellation_reason, active: true, cancellation_category: cancellation_category)
      account = FactoryGirl.build(:account, cancelled_at: DateTime.now, cancellation_category: cancellation_category)
      expect(account.require_cancellation_reason_id).to eq true
    end

    it 'is false if there are no cancellation_reasons' do
      cancellation_category = FactoryGirl.create(:cancellation_category)
      account = FactoryGirl.build(:account, cancelled_at: DateTime.now, cancellation_category: cancellation_category)
      expect(account.require_cancellation_reason_id).to eq false
    end
  end

  describe '.restore' do
    it 'removes the paused plan' do
      cancellation_category = FactoryGirl.create(:cancellation_category)
      cancellation_reason = FactoryGirl.create(:cancellation_reason, cancellation_category: cancellation_category)
      account = FactoryGirl.create(:account,
                                   active: false,
                                   cancelled_at: Time.now - 1.days,
                                   cancellation_category: cancellation_category,
                                   cancellation_message: 'Something',
                                   cancellation_reason: cancellation_reason)
      expect(account.restore).to eq true
      expect(account.active).to eq true
      expect(account.cancelled_at).to be_nil
      expect(account.cancellation_category_id).to be_nil
      expect(account.cancellation_message).to be_nil
      expect(account.cancellation_reason_id).to be_nil
    end
  end

  describe '.status' do
    it 'is canclled when not active' do
      account = FactoryGirl.build(:account, active: false)
      expect(account.status).to eq :cancelled
    end

    it 'is cancel_pending with cancelled_at not nil but still active' do
      account = FactoryGirl.build(:account, active: true, cancelled_at: Time.now)
      expect(account.status).to eq :cancel_pending
    end

    it 'is expired if past expires_at but still active' do
      account = FactoryGirl.build(:account, active: true, expires_at: Time.now - 1.days)
      expect(account.status).to eq :expired
    end

    it 'is paused if there is a a pused plan' do
      paused_plan = FactoryGirl.create(:plan)
      account = FactoryGirl.build(:account, paused_plan: paused_plan)
      expect(account.status).to eq :paused
    end

    it 'is active by default' do
      account = FactoryGirl.build(:account)
      expect(account.status).to eq :active
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

  describe '.subdomain' do
    before :each do
      @plan = FactoryGirl.create(:plan, allow_subdomain: true)
    end

    it 'must be 64 characters or less' do
      account = FactoryGirl.build(:account, plan: @plan, subdomain: Faker::Lorem.characters(65))
      expect(account).to_not be_valid
      expect(account.errors[:subdomain]).to include 'is too long (maximum is 64 characters)'
    end

    it 'is required' do
      account = FactoryGirl.build(:account, plan: @plan, subdomain: nil)
      expect(account).to be_valid
    end

    it 'can be a subdomain name' do
      account = FactoryGirl.build(:account, plan: @plan, subdomain: 'my-app')
      expect(account).to be_valid
    end

    it 'must be unique if not nil' do
      account1 = FactoryGirl.create(:account, plan: @plan, subdomain: 'www')
      expect(account1).to be_valid

      account2 = FactoryGirl.build(:account, plan: @plan, subdomain: 'www')
      expect(account2).to_not be_valid
      expect(account2.errors[:subdomain]).to include 'has already been taken'
    end

    it 'can be nil if others are' do
      account1 = FactoryGirl.create(:account, plan: @plan, subdomain: nil)
      expect(account1).to be_valid

      account2 = FactoryGirl.build(:account, plan: @plan, subdomain: nil)
      expect(account2).to be_valid
    end

    it 'cannot contain illegal characters' do
      account = FactoryGirl.build(:account, plan: @plan, subdomain: 'www.example.com')
      expect(account).to_not be_valid
      expect(account.errors[:subdomain]).to include 'is invalid'
    end
  end

  describe '.to_s' do
    it 'uses the company name' do
      account = FactoryGirl.build(:account)
      expect(account.to_s).to eq account.company_name
    end
  end

  describe '.user_invitationss' do
    it 'connects to User Invitation' do
      account = FactoryGirl.create(:account)
      user_invitation1 = FactoryGirl.create(:user_invitation, account: account)
      user_invitation2 = FactoryGirl.create(:user_invitation, account: account)
      expect(account.user_invitations.count).to eq 2
      expect(account.user_invitations).to include user_invitation1
      expect(account.user_invitations).to include user_invitation2
    end
  end

  describe '.user_permissions' do
    it 'connects to User Permission' do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      account = FactoryGirl.create(:account)
      user_permission1 = FactoryGirl.create(:user_permission, account: account, user: user1)
      user_permission2 = FactoryGirl.create(:user_permission, account: account, user: user2)
      expect(account.user_permissions.count).to eq 2
      expect(account.user_permissions).to include user_permission1
      expect(account.user_permissions).to include user_permission2
    end
  end

  describe '.users' do
    it 'connects to Users' do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      account = FactoryGirl.create(:account)
      FactoryGirl.create(:user_permission, account: account, user: user1)
      FactoryGirl.create(:user_permission, account: account, user: user2)
      account.reload
      expect(account.users.count).to eq 2
      expect(account.users).to include user1
      expect(account.users).to include user2
    end

    it 'validates on create' do
      user = FactoryGirl.build(:user, email: nil)
      account = FactoryGirl.build(:account)
      account.users << user
      expect(account.save).to be false
      expect(user.errors[:email]).to include 'can\'t be blank'
    end
  end
end
