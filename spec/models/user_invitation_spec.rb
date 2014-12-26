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

# Tests for the user invitation model
RSpec.describe UserInvitation, type: :model do
  it 'should have valid factory' do
    expect(FactoryGirl.build(:user_invitation)).to be_valid
  end

  describe '.account' do
    it 'connects to Account' do
      account = FactoryGirl.create(:account)
      user_invitation = FactoryGirl.create(:user_invitation, account: account)
      expect(user_invitation.account).to eq account
    end
  end

  describe '.email' do
    it 'is required' do
      user_invitation = FactoryGirl.build(:user_invitation, email: '')
      expect(user_invitation).to_not be_valid
    end

    it 'must be less than 256 characters' do
      user_invitation = FactoryGirl.build(:user_invitation, email: Faker::Lorem.characters(256))
      expect(user_invitation).to_not be_valid
      expect(user_invitation.errors[:email]).to include 'is too long (maximum is 255 characters)'
    end

    it 'must be unique' do
      FactoryGirl.create(:user_invitation, email: 'john@example')
      user_invitation = FactoryGirl.build(:user_invitation, email: 'john@example')
      expect(user_invitation).to_not be_valid
      expect(user_invitation.errors[:email]).to include 'has already been taken'
    end
  end

  describe '.first_name' do
    it 'is not required' do
      user_invitation = FactoryGirl.build(:user_invitation, first_name: '')
      expect(user_invitation).to be_valid
    end

    it 'must be less than 60 characters' do
      user_invitation = FactoryGirl.build(:user_invitation, first_name: Faker::Lorem.characters(61))
      expect(user_invitation).to_not be_valid
      expect(user_invitation.errors[:first_name]).to include 'is too long (maximum is 60 characters)'
    end
  end

  describe '.invite_code' do
    it 'must be less than 37 characters' do
      user_invitation = FactoryGirl.build(:user_invitation, invite_code: Faker::Lorem.characters(37))
      expect(user_invitation).to_not be_valid
      expect(user_invitation.errors[:invite_code]).to include 'is too long (maximum is 36 characters)'
    end

    it 'is automatically generated if blank' do
      user_invitation = FactoryGirl.build(:user_invitation, invite_code: nil)
      expect(user_invitation).to be_valid
      expect(user_invitation.invite_code).to_not be_nil
    end

    it 'is automatically generated if nil' do
      user_invitation = FactoryGirl.build(:user_invitation, invite_code: nil)
      expect(user_invitation).to be_valid
      expect(user_invitation.invite_code).to_not be_nil
    end

    it 'must be unique' do
      uuid = SecureRandom.uuid
      FactoryGirl.create(:user_invitation, invite_code: uuid)
      user_invitation = FactoryGirl.build(:user_invitation, invite_code: uuid)
      expect(user_invitation).to_not be_valid
      expect(user_invitation.errors[:invite_code]).to include 'has already been taken'
    end
  end

  describe '.last_name' do
    it 'is required' do
      user_invitation = FactoryGirl.build(:user_invitation, last_name: '')
      expect(user_invitation).to_not be_valid
      expect(user_invitation.errors[:last_name]).to include 'can\'t be blank'
    end

    it 'must be less than 60 characters' do
      user_invitation = FactoryGirl.build(:user_invitation, last_name: Faker::Lorem.characters(61))
      expect(user_invitation).to_not be_valid
      expect(user_invitation.errors[:last_name]).to include 'is too long (maximum is 60 characters)'
    end
  end
end
