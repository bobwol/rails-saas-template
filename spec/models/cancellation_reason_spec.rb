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

# Tests for the cancellation reason model
RSpec.describe CancellationReason, type: :model do
  it 'should have valid factory' do
    expect(FactoryGirl.build(:cancellation_reason)).to be_valid
  end

  describe '.active' do
    # t.boolean :active, default: true, null: false
  end

  describe '.allow_message' do
    # t.boolean :active, default: true, null: false
    context '.require_message is true' do
      it 'can be true' do
        cancellation_reason = FactoryGirl.build(:cancellation_reason,
                                                allow_message: true,
                                                require_message: true)
        expect(cancellation_reason).to be_valid
      end

      it 'cannot be false' do
        cancellation_reason = FactoryGirl.build(:cancellation_reason,
                                                allow_message: false,
                                                require_message: true)
        expect(cancellation_reason).to_not be_valid
        expect(cancellation_reason.errors[:allow_message]).to include 'can\'t be blank'
      end
    end

    context '.require_message is false' do
      it 'can be true' do
        cancellation_reason = FactoryGirl.build(:cancellation_reason,
                                                allow_message: true,
                                                require_message: false)
        expect(cancellation_reason).to be_valid
      end

      it 'can be false' do
        cancellation_reason = FactoryGirl.build(:cancellation_reason,
                                                allow_message: false,
                                                require_message: false)
        expect(cancellation_reason).to be_valid
      end
    end
  end

  describe '.available' do
    it 'returns active cancellation reasons' do
      reason = FactoryGirl.create(:cancellation_reason, active: true)
      FactoryGirl.create(:cancellation_reason, active: false)

      reasons = CancellationReason.available
      expect(reasons.count).to eq 1
      expect(reasons).to include reason
    end
  end

  describe '.cancellation_category' do
    it 'correctly links to cancellation category' do
      category = FactoryGirl.create(:cancellation_category)
      expect(category).to be_valid

      reason = FactoryGirl.create(:cancellation_reason, cancellation_category: category)
      expect(reason).to be_valid

      expect(reason.cancellation_category).to eq category
    end
  end

  describe '.name' do
    it 'must be 120 characters or less' do
      cancellation_reason = FactoryGirl.build(:cancellation_reason, name: Faker::Lorem.characters(121))
      expect(cancellation_reason).to_not be_valid
      expect(cancellation_reason.errors[:name]).to include 'is too long (maximum is 120 characters)'
    end

    it 'is required' do
      cancellation_reason = FactoryGirl.build(:cancellation_reason, name: '')
      expect(cancellation_reason).to_not be_valid
      expect(cancellation_reason.errors[:name]).to include 'can\'t be blank'
    end

    it 'must be unique inside a category' do
      category = FactoryGirl.create(:cancellation_category)

      cancellation_reason = FactoryGirl.create(:cancellation_reason, cancellation_category: category, name: 'category')
      expect(cancellation_reason).to be_valid

      cancellation_reason = FactoryGirl.build(:cancellation_reason, cancellation_category: category, name: 'category')
      expect(cancellation_reason).to_not be_valid
      expect(cancellation_reason.errors[:name]).to include 'has already been taken'
    end

    it 'can be the same in different  category' do
      cancellation_reason = FactoryGirl.create(:cancellation_reason, name: 'category')
      expect(cancellation_reason).to be_valid

      cancellation_reason = FactoryGirl.build(:cancellation_reason, name: 'category')
      expect(cancellation_reason).to be_valid
    end
  end

  describe '.require_message' do
    # t.boolean :active, default: true, null: false
  end
end
