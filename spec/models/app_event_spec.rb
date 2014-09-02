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

# Tests for the app event model
RSpec.describe AppEvent, type: :model do
  it 'should have valid factory' do
    expect(FactoryGirl.build(:app_event)).to be_valid
  end

  describe '.account_id' do
    it 'is not required' do
      app_event = FactoryGirl.build(:app_event, account_id: '')
      expect(app_event).to be_valid
    end
  end

  describe '.account' do
    it 'returns active plans' do
      account = FactoryGirl.create(:account)
      app_event = FactoryGirl.create(:app_event, account: account)
      expect(app_event.account).to eq account
    end
  end

  describe '.level' do
    it 'is required' do
      app_event = FactoryGirl.build(:app_event, level: '')
      expect(app_event).to_not be_valid
      expect(app_event.errors[:level]).to include 'can\'t be blank'
    end

    it 'can be success' do
      app_event = FactoryGirl.build(:app_event, level: 'success')
      expect(app_event).to be_valid
    end

    it 'can be info' do
      app_event = FactoryGirl.build(:app_event, level: 'info')
      expect(app_event).to be_valid
    end

    it 'can be warning' do
      app_event = FactoryGirl.build(:app_event, level: 'warning')
      expect(app_event).to be_valid
    end

    it 'can be alert' do
      app_event = FactoryGirl.build(:app_event, level: 'alert')
      expect(app_event).to be_valid
    end

    it 'doesn\'t allow random values' do
      app_event = FactoryGirl.build(:app_event, level: Faker::Lorem.characters(20))
      expect(app_event).to_not be_valid
      expect(app_event.errors[:level]).to include 'is not included in the list'
    end
  end

  describe '.message' do
    it 'is required' do
      app_event = FactoryGirl.build(:app_event, message: '')
      expect(app_event).to_not be_valid
      expect(app_event.errors[:message]).to include 'can\'t be blank'
    end

    it 'must be 255 characters or less' do
      app_event = FactoryGirl.build(:app_event, message: Faker::Lorem.characters(256))
      expect(app_event).to_not be_valid
      expect(app_event.errors[:message]).to include 'is too long (maximum is 255 characters)'
    end
  end

  describe '.user_id' do
    it 'is not required' do
      app_event = FactoryGirl.build(:app_event, user_id: '')
      expect(app_event).to be_valid
    end
  end

  describe '.user' do
    it 'returns active plans' do
      user = FactoryGirl.create(:user)
      app_event = FactoryGirl.create(:app_event, user: user)
      expect(app_event.user).to eq user
    end
  end

  describe '.success' do
    before :each do
      @message = Faker::Lorem.characters(50)
      @account = FactoryGirl.create(:account)
      @user = FactoryGirl.create(:user)
    end

    context 'no account or user' do
      it 'should save correctly' do
        event = AppEvent.success(@message)
        expect(event.level).to eq 'success'
        expect(event.message).to eq @message
        expect(event.account).to be_nil
        expect(event.user).to be_nil
      end
    end

    context 'account but no user' do
      it 'should save correctly' do
        event = AppEvent.success(@message, @account)
        expect(event.level).to eq 'success'
        expect(event.message).to eq @message
        expect(event.account).to eq @account
        expect(event.user).to be_nil
      end
    end

    context 'user but no account' do
      it 'should save correctly' do
        event = AppEvent.success(@message, nil, @user)
        expect(event.level).to eq 'success'
        expect(event.message).to eq @message
        expect(event.account).to be_nil
        expect(event.user).to eq @user
      end
    end

    context 'user and account' do
      it 'should save correctly' do
        event = AppEvent.success(@message, @account, @user)
        expect(event.level).to eq 'success'
        expect(event.message).to eq @message
        expect(event.account).to eq @account
        expect(event.user).to eq @user
      end
    end
  end

  describe '.info' do
    before :each do
      @message = Faker::Lorem.characters(50)
      @account = FactoryGirl.create(:account)
      @user = FactoryGirl.create(:user)
    end

    context 'no account or user' do
      it 'should save correctly' do
        event = AppEvent.info(@message)
        expect(event.level).to eq 'info'
        expect(event.message).to eq @message
        expect(event.account).to be_nil
        expect(event.user).to be_nil
      end
    end

    context 'account but no user' do
      it 'should save correctly' do
        event = AppEvent.info(@message, @account)
        expect(event.level).to eq 'info'
        expect(event.message).to eq @message
        expect(event.account).to eq @account
        expect(event.user).to be_nil
      end
    end

    context 'user but no account' do
      it 'should save correctly' do
        event = AppEvent.info(@message, nil, @user)
        expect(event.level).to eq 'info'
        expect(event.message).to eq @message
        expect(event.account).to be_nil
        expect(event.user).to eq @user
      end
    end

    context 'user and account' do
      it 'should save correctly' do
        event = AppEvent.info(@message, @account, @user)
        expect(event.level).to eq 'info'
        expect(event.message).to eq @message
        expect(event.account).to eq @account
        expect(event.user).to eq @user
      end
    end
  end

  describe '.warning' do
    before :each do
      @message = Faker::Lorem.characters(50)
      @account = FactoryGirl.create(:account)
      @user = FactoryGirl.create(:user)
    end

    context 'no account or user' do
      it 'should save correctly' do
        event = AppEvent.warning(@message)
        expect(event.level).to eq 'warning'
        expect(event.message).to eq @message
        expect(event.account).to be_nil
        expect(event.user).to be_nil
      end
    end

    context 'account but no user' do
      it 'should save correctly' do
        event = AppEvent.warning(@message, @account)
        expect(event.level).to eq 'warning'
        expect(event.message).to eq @message
        expect(event.account).to eq @account
        expect(event.user).to be_nil
      end
    end

    context 'user but no account' do
      it 'should save correctly' do
        event = AppEvent.warning(@message, nil, @user)
        expect(event.level).to eq 'warning'
        expect(event.message).to eq @message
        expect(event.account).to be_nil
        expect(event.user).to eq @user
      end
    end

    context 'user and account' do
      it 'should save correctly' do
        event = AppEvent.warning(@message, @account, @user)
        expect(event.level).to eq 'warning'
        expect(event.message).to eq @message
        expect(event.account).to eq @account
        expect(event.user).to eq @user
      end
    end
  end

  describe '.alert' do
    before :each do
      @message = Faker::Lorem.characters(50)
      @account = FactoryGirl.create(:account)
      @user = FactoryGirl.create(:user)
    end

    context 'no account or user' do
      it 'should save correctly' do
        event = AppEvent.alert(@message)
        expect(event.level).to eq 'alert'
        expect(event.message).to eq @message
        expect(event.account).to be_nil
        expect(event.user).to be_nil
      end
    end

    context 'account but no user' do
      it 'should save correctly' do
        event = AppEvent.alert(@message, @account)
        expect(event.level).to eq 'alert'
        expect(event.message).to eq @message
        expect(event.account).to eq @account
        expect(event.user).to be_nil
      end
    end

    context 'user but no account' do
      it 'should save correctly' do
        event = AppEvent.alert(@message, nil, @user)
        expect(event.level).to eq 'alert'
        expect(event.message).to eq @message
        expect(event.account).to be_nil
        expect(event.user).to eq @user
      end
    end

    context 'user and account' do
      it 'should save correctly' do
        event = AppEvent.alert(@message, @account, @user)
        expect(event.level).to eq 'alert'
        expect(event.message).to eq @message
        expect(event.account).to eq @account
        expect(event.user).to eq @user
      end
    end
  end
end
