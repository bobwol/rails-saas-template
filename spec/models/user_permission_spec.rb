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
RSpec.describe UserPermission, type: :model do
  it 'should have valid factory' do
    expect(FactoryGirl.build(:user_permission)).to be_valid
  end

  describe '.account' do
    it 'connects to Account' do
      account = FactoryGirl.create(:account)
      user_permission = FactoryGirl.create(:user_permission, account_id: account.id)
      expect(user_permission).to be_valid
      expect(user_permission.account).to eq account
    end
  end

  describe '.account_id' do
    it 'is required' do
      user_permission = FactoryGirl.build(:user_permission, account_id: '')
      expect(user_permission).to_not be_valid
      expect(user_permission.errors[:account_id]).to include 'can\'t be blank'
    end
  end

  describe '.account_admin' do
    it 'can be false' do
      user_permission = FactoryGirl.build(:user_permission, account_admin: false)
      expect(user_permission).to be_valid
    end

    it 'can be true' do
      user_permission = FactoryGirl.build(:user_permission, account_admin: true)
      expect(user_permission).to be_valid
    end
  end

  describe '.user' do
    it 'connects to User' do
      user = FactoryGirl.create(:user)
      user_permission = FactoryGirl.create(:user_permission, user_id: user.id)
      expect(user_permission).to be_valid
      expect(user_permission.user).to eq user
    end
  end

  describe '.rec_num' do
    it 'must be unique within an account' do
      account = FactoryGirl.create(:account)
      FactoryGirl.create(:user_permission, account: account, rec_num: 1)
      user_permission2 = FactoryGirl.build(:user_permission, account: account, rec_num: 1)
      expect(user_permission2).to_not be_valid
      expect(user_permission2.errors[:rec_num]).to include 'has already been taken'
    end

    it 'can be duplicate with a different agency' do
      user_permission = FactoryGirl.create(:user_permission, rec_num: 1)
      expect(user_permission).to be_valid
      user_permission2 = FactoryGirl.create(:user_permission, rec_num: 1)
      expect(user_permission2).to be_valid
    end

    context 'when creating a record' do
      it 'is automatically assigned if not provided' do
        user_permission = FactoryGirl.create(:user_permission)
        expect(user_permission).to be_valid
      end

      it 'starts at 1' do
        user_permission = FactoryGirl.create(:user_permission)
        expect(user_permission).to be_valid
        expect(user_permission.rec_num).to eq 1
      end

      it 'increments correctly' do
        account = FactoryGirl.create(:account)
        user_permission1 = FactoryGirl.create(:user_permission, account: account)
        expect(user_permission1).to be_valid
        user_permission2 = FactoryGirl.create(:user_permission, account: account)
        expect(user_permission2).to be_valid
        expect(user_permission2.rec_num).to eq user_permission1.rec_num + 1
        user_permission3 = FactoryGirl.create(:user_permission)
        expect(user_permission3).to be_valid
        expect(user_permission3.rec_num).to eq 1
      end
    end

    context 'when updating a record' do
      it 'is required' do
        user_permission = FactoryGirl.create(:user_permission)
        expect(user_permission).to be_valid
        user_permission.rec_num = ''
        expect(user_permission).to_not be_valid
        expect(user_permission.errors[:rec_num]).to include 'can\'t be blank'
      end
    end
  end

  describe '.to_param' do
    it 'returns rec_num' do
      user_permission = FactoryGirl.create(:user_permission)
      user_permission.rec_num = user_permission.id + 1
      expect(user_permission.to_param).to eq user_permission.rec_num
      expect(user_permission.to_param).to_not eq user_permission.id
    end
  end

  describe '.user_id' do
    it 'is required' do
      user_permission = FactoryGirl.build(:user_permission, user_id: '')
      expect(user_permission).to_not be_valid
      expect(user_permission.errors[:user_id]).to include 'can\'t be blank'
    end

    it 'must be unique to an account' do
      user = FactoryGirl.create(:user)
      account = FactoryGirl.create(:account)
      user_permission1 = FactoryGirl.create(:user_permission, account_id: account.id, user_id: user.id)
      expect(user_permission1).to be_valid
      user_permission2 = FactoryGirl.build(:user_permission, account_id: account.id, user_id: user.id)
      expect(user_permission2).to_not be_valid
      expect(user_permission2.errors[:user_id]).to include 'has already been taken'
    end
  end
end
