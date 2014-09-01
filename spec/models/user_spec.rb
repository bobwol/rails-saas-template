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

# Tests for the user model
RSpec.describe User, type: :model do
  it 'should have valid factory' do
    expect(FactoryGirl.build(:user)).to be_valid
  end

  describe '.accounts' do
    it 'connects to Account' do
      account1 = FactoryGirl.create(:account)
      account2 = FactoryGirl.create(:account)
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:user_permission, account: account1, user: user)
      FactoryGirl.create(:user_permission, account: account2, user: user)
      expect(user.accounts.count).to eq 2
      expect(user.accounts).to include account1
      expect(user.accounts).to include account2
    end
  end

  describe '.app_events' do
    it 'connects to AppEvent' do
      user = FactoryGirl.create(:user)
      app_event1 = FactoryGirl.create(:app_event, user: user)
      app_event2 = FactoryGirl.create(:app_event, user: user)
      expect(user.app_events.count).to eq 2
      expect(user.app_events).to include app_event1
      expect(user.app_events).to include app_event2
    end
  end

  describe '.first_name' do
    it 'is not required' do
      user = FactoryGirl.build(:user, first_name: '')
      expect(user).to be_valid
    end

    it 'must be less than 80 characters' do
      user = FactoryGirl.build(:user, first_name: Faker::Lorem.characters(81))
      expect(user).to_not be_valid
      expect(user.errors[:first_name]).to include 'is too long (maximum is 80 characters)'
    end
  end

  describe '.last_name' do
    it 'is required' do
      user = FactoryGirl.build(:user, last_name: '')
      expect(user).to_not be_valid
      expect(user.errors[:last_name]).to include 'can\'t be blank'
    end

    it 'must be less than 80 characters' do
      user = FactoryGirl.build(:user, last_name: Faker::Lorem.characters(81))
      expect(user).to_not be_valid
      expect(user.errors[:last_name]).to include 'is too long (maximum is 80 characters)'
    end
  end

  describe '.password' do
    context 'on create' do
      it 'cannot be blank' do
        user = FactoryGirl.build(:user, password: '')
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include 'can\'t be blank'
      end

      it 'must be confirmed' do
        user = FactoryGirl.build(:user, password: 'abcd1234', password_confirmation: '')
        expect(user).to_not be_valid
        expect(user.errors[:password_confirmation]).to include 'doesn\'t match Password'
      end

      it 'confirmation must match' do
        user = FactoryGirl.build(:user, password: 'abcd1234', password_confirmation: 'abcd1234')
        expect(user).to be_valid
      end
    end

    context 'on update' do
      before(:each) do
        @user = FactoryGirl.create(:user)
      end

      it 'can be blank' do
        @user.password = ''
        expect(@user).to_not be_valid
        expect(@user.errors[:password]).to include 'can\'t be blank'
      end

      it 'must be confirmed' do
        @user.password = 'abcd1234'
        @user.password_confirmation = ''
        expect(@user).to_not be_valid
        expect(@user.errors[:password_confirmation]).to include 'doesn\'t match Password'
      end

      it 'confirmation must match' do
        @user.password = 'abcd1234'
        @user.password_confirmation = 'abcd1234'
        expect(@user).to be_valid
      end
    end
  end

  describe '.to_s' do
    context 'no first or last name' do
      it 'defaults to unknown' do
        user = FactoryGirl.build(:user, first_name: '', last_name: '')
        expect(user.to_s).to eq '(unknown)'
      end
    end

    context 'first name only' do
      it 'uses the first name' do
        user = FactoryGirl.build(:user, last_name: '')
        expect(user.to_s).to eq user.first_name
      end
    end

    context 'last name only' do
      it 'uses the last name' do
        user = FactoryGirl.build(:user, first_name: '')
        expect(user.to_s).to eq user.last_name
      end
    end

    context 'first and last name' do
      it 'uses both names' do
        user = FactoryGirl.build(:user)
        name = user.first_name + ' ' + user.last_name
        expect(user.to_s).to eq name
      end
    end
  end

  describe '.user_permissions' do
    it 'connects to UserPermission' do
      account1 = FactoryGirl.create(:account)
      account2 = FactoryGirl.create(:account)
      user = FactoryGirl.create(:user)
      user_permission1 = FactoryGirl.create(:user_permission, account: account1, user: user)
      user_permission2 = FactoryGirl.create(:user_permission, account: account2, user: user)
      expect(user.user_permissions.count).to eq 2
      expect(user.user_permissions).to include user_permission1
      expect(user.user_permissions).to include user_permission2
    end
  end
end
