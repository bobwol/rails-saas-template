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
RSpec.describe Plan, type: :model do
  it 'should have valid factory' do
    expect(FactoryGirl.build(:plan)).to be_valid
  end

  describe '.allow_custom_path' do
    it 'can be true' do
      plan = FactoryGirl.build(:plan, allow_custom_path: true)
      expect(plan).to be_valid
    end

    it 'can be false' do
      plan = FactoryGirl.build(:plan, allow_custom_path: false)
      expect(plan).to be_valid
    end
  end

  describe '.allow_hostname' do
    it 'can be true' do
      plan = FactoryGirl.build(:plan, allow_hostname: true)
      expect(plan).to be_valid
    end

    it 'can be false' do
      plan = FactoryGirl.build(:plan, allow_hostname: false)
      expect(plan).to be_valid
    end
  end

  describe '.allow_subdomain' do
    it 'can be true' do
      plan = FactoryGirl.build(:plan, allow_subdomain: true)
      expect(plan).to be_valid
    end

    it 'can be false' do
      plan = FactoryGirl.build(:plan, allow_subdomain: false)
      expect(plan).to be_valid
    end
  end

  describe '.amount' do
    it 'is required' do
      plan = FactoryGirl.build(:plan, amount: '')
      expect(plan).to_not be_valid
      expect(plan.errors[:amount]).to include 'can\'t be blank'
    end

    it 'must be an integer' do
      plan = FactoryGirl.build(:plan, amount: 5.3)
      expect(plan).to be_valid
      expect(plan.amount).to eq 5
    end

    it 'must be greater than or equal to zero' do
      plan = FactoryGirl.build(:plan, amount: -1)
      expect(plan).to_not be_valid
      expect(plan.errors[:amount]).to include 'must be greater than or equal to 0'
    end

    it 'cannot be changed' do
      plan = FactoryGirl.create(:plan, amount: 1900)
      expect(plan.update(amount: 3900)).to eq false
      expect(plan.errors[:amount]).to include 'cannot change the amount'
    end
  end

  describe '.available' do
    it 'returns active plans' do
      # Three inactive plans
      FactoryGirl.create(:plan, active: false)
      FactoryGirl.create(:plan, public: false)
      FactoryGirl.create(:plan, stripe_id: nil)
      # On active plan
      plan = FactoryGirl.create(:plan)

      plans = Plan.available
      expect(plans.count).to eq 1
      expect(plans).to include plan
    end
  end

  describe '.currency' do
    it 'is required' do
      plan = FactoryGirl.build(:plan, currency: '')
      expect(plan).to_not be_valid
      expect(plan.errors[:currency]).to include 'can\'t be blank'
    end

    it 'can be AUD' do
      plan = FactoryGirl.build(:plan, currency: 'AUD')
      expect(plan).to be_valid
    end

    it 'can be CAD' do
      plan = FactoryGirl.build(:plan, currency: 'CAD')
      expect(plan).to be_valid
    end

    it 'can be EUR' do
      plan = FactoryGirl.build(:plan, currency: 'EUR')
      expect(plan).to be_valid
    end

    it 'can be GBP' do
      plan = FactoryGirl.build(:plan, currency: 'GBP')
      expect(plan).to be_valid
    end

    it 'can be NZD' do
      plan = FactoryGirl.build(:plan, currency: 'NZD')
      expect(plan).to be_valid
    end

    it 'can be USD' do
      plan = FactoryGirl.build(:plan, currency: 'USD')
      expect(plan).to be_valid
    end

    it 'doesn\'t allow random values' do
      plan = FactoryGirl.build(:plan, currency: Faker::Lorem.characters(20))
      expect(plan).to_not be_valid
      expect(plan.errors[:currency]).to include 'is not included in the list'
    end

    it 'cannot be changed' do
      plan = FactoryGirl.create(:plan, currency: 'USD')
      expect(plan.update(currency: 'AUD')).to eq false
      expect(plan.errors[:currency]).to include 'cannot change the currency'
    end
  end

  describe '.interval' do
    it 'is required' do
      plan = FactoryGirl.build(:plan, interval: '')
      expect(plan).to_not be_valid
      expect(plan.errors[:interval]).to include 'can\'t be blank'
    end

    it 'can be day' do
      plan = FactoryGirl.build(:plan, interval: 'day')
      expect(plan).to be_valid
    end

    it 'can be week' do
      plan = FactoryGirl.build(:plan, interval: 'week')
      expect(plan).to be_valid
    end

    it 'can be month' do
      plan = FactoryGirl.build(:plan, interval: 'month')
      expect(plan).to be_valid
    end

    it 'can be year' do
      plan = FactoryGirl.build(:plan, interval: 'year')
      expect(plan).to be_valid
    end

    it 'doesn\'t allow random values' do
      plan = FactoryGirl.build(:plan, interval: Faker::Lorem.characters(20))
      expect(plan).to_not be_valid
      expect(plan.errors[:interval]).to include 'is not included in the list'
    end

    it 'cannot be changed' do
      plan = FactoryGirl.create(:plan, interval: 'year')
      expect(plan.update(interval: 'week')).to eq false
      expect(plan.errors[:interval]).to include 'cannot change the interval'
    end
  end

  describe '.interval_count' do
    it 'is required' do
      plan = FactoryGirl.build(:plan, interval_count: '')
      expect(plan).to_not be_valid
      expect(plan.errors[:interval_count]).to include 'can\'t be blank'
    end

    it 'must be an integer' do
      plan = FactoryGirl.build(:plan, interval_count: 5.3)
      expect(plan).to be_valid
      expect(plan.interval_count).to eq 5
    end

    it 'must be greater than or equal to one' do
      plan = FactoryGirl.build(:plan, interval_count: 0)
      expect(plan).to_not be_valid
      expect(plan.errors[:interval_count]).to include 'must be greater than or equal to 1'
    end

    it 'cannot be changed' do
      plan = FactoryGirl.create(:plan, interval_count: 30)
      expect(plan.update(interval_count: 15)).to eq false
      expect(plan.errors[:interval_count]).to include 'cannot change the interval count'
    end
  end

  describe '.label' do
    it 'is not required' do
      plan = FactoryGirl.build(:plan, label: '')
      expect(plan).to be_valid
    end

    it 'must be 30 characters or less' do
      plan = FactoryGirl.build(:plan, label: Faker::Lorem.characters(31))
      expect(plan).to_not be_valid
      expect(plan.errors[:label]).to include 'is too long (maximum is 30 characters)'
    end
  end

  describe '.max_users' do
    it 'is required' do
      plan = FactoryGirl.build(:plan, max_users: '')
      expect(plan).to_not be_valid
      expect(plan.errors[:max_users]).to include 'can\'t be blank'
    end

    it 'must be an integer' do
      plan = FactoryGirl.build(:plan, max_users: 5.3)
      expect(plan).to be_valid
      expect(plan.max_users).to eq 5
    end

    it 'must be greater than or equal to one' do
      plan = FactoryGirl.build(:plan, max_users: 0)
      expect(plan).to_not be_valid
      expect(plan.errors[:max_users]).to include 'must be greater than or equal to 1'
    end
  end

  describe '.name' do
    it 'is required' do
      plan = FactoryGirl.build(:plan, name: '')
      expect(plan).to_not be_valid
      expect(plan.errors[:name]).to include 'can\'t be blank'
    end

    it 'must be 150 characters or less' do
      plan = FactoryGirl.build(:plan, name: Faker::Lorem.characters(151))
      expect(plan).to_not be_valid
      expect(plan.errors[:name]).to include 'is too long (maximum is 150 characters)'
    end
  end

  describe '.paused_plan_id' do
    it 'cannot be the plan_id' do
      plan = FactoryGirl.create(:plan)
      expect(plan.update(paused_plan_id: plan.id)).to eq false
      expect(plan.errors[:paused_plan_id]).to include 'cannot use a plan as its own paused plan'
    end
  end

  describe '.statement_description' do
    it 'is not required' do
      plan = FactoryGirl.build(:plan, statement_description: '')
      expect(plan).to be_valid
    end

    it 'must be 150 characters or less' do
      plan = FactoryGirl.build(:plan, statement_description: Faker::Lorem.characters(151))
      expect(plan).to_not be_valid
      expect(plan.errors[:statement_description]).to include 'is too long (maximum is 150 characters)'
    end
  end

  describe '.stripe_id' do
    it 'is not required' do
      plan = FactoryGirl.build(:plan, stripe_id: '')
      expect(plan).to be_valid
    end

    it 'must be 150 characters or less' do
      plan = FactoryGirl.build(:plan, stripe_id: Faker::Lorem.characters(81))
      expect(plan).to_not be_valid
      expect(plan.errors[:stripe_id]).to include 'is too long (maximum is 80 characters)'
    end
  end

  describe '.to_s' do
    it 'is the name' do
      plan = FactoryGirl.build(:plan)
      expect(plan.to_s).to eq plan.name
    end
  end

  describe '.trial_period_days' do
    it 'is required' do
      plan = FactoryGirl.build(:plan, trial_period_days: '')
      expect(plan).to_not be_valid
      expect(plan.errors[:trial_period_days]).to include 'can\'t be blank'
    end

    it 'must be an integer' do
      plan = FactoryGirl.build(:plan, trial_period_days: 5.3)
      expect(plan).to be_valid
      expect(plan.trial_period_days).to eq 5
    end

    it 'must be greater than or equal to zero' do
      plan = FactoryGirl.build(:plan, trial_period_days: -1, require_card_upfront: true)
      expect(plan).to_not be_valid
      expect(plan.errors[:trial_period_days]).to include 'must be greater than or equal to 0'
    end

    it 'must be greater than or equal to one if card not required upfront' do
      plan = FactoryGirl.build(:plan, trial_period_days: 0, require_card_upfront: false)
      expect(plan).to_not be_valid
      expect(plan.errors[:trial_period_days]).to include 'must be greater than or equal to 1'
    end

    it 'cannot be changed' do
      plan = FactoryGirl.create(:plan, trial_period_days: 30)
      expect(plan.update(trial_period_days: 15)).to eq false
      expect(plan.errors[:trial_period_days]).to include 'cannot change the trial period days'
    end
  end
end
