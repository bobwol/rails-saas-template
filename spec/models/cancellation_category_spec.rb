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

# Tests for the cancellation category model
RSpec.describe CancellationCategory, type: :model do
  it 'should have valid factory' do
    expect(FactoryGirl.build(:cancellation_category)).to be_valid
  end

  describe '.active' do
    # t.boolean :active, default: true, null: false
  end

  describe '.allow_message' do
    # t.boolean :active, default: true, null: false
    context '.require_message is true' do
      it 'can be true' do
        cancellation_category = FactoryGirl.build(:cancellation_category,
                                                  allow_message: true,
                                                  require_message: true)
        expect(cancellation_category).to be_valid
      end

      it 'cannot be false' do
        cancellation_category = FactoryGirl.build(:cancellation_category,
                                                  allow_message: false,
                                                  require_message: true)
        expect(cancellation_category).to_not be_valid
        expect(cancellation_category.errors[:allow_message]).to include 'can\'t be blank'
      end
    end

    context '.require_message is false' do
      it 'can be true' do
        cancellation_category = FactoryGirl.build(:cancellation_category,
                                                  allow_message: true,
                                                  require_message: false)
        expect(cancellation_category).to be_valid
      end

      it 'can be false' do
        cancellation_category = FactoryGirl.build(:cancellation_category,
                                                  allow_message: false,
                                                  require_message: false)
        expect(cancellation_category).to be_valid
      end
    end
  end

  describe '.available' do
    it 'returns active cancellation categories' do
      category = FactoryGirl.create(:cancellation_category, active: true)
      FactoryGirl.create(:cancellation_category, active: false)

      categories = CancellationCategory.available
      expect(categories.count).to eq 1
      expect(categories).to include category
    end
  end

  describe '.cancellation_reasons' do
    it 'correctly links to cancellation reasons' do
      category1 = FactoryGirl.create(:cancellation_category)
      expect(category1).to be_valid

      category2 = FactoryGirl.create(:cancellation_category)
      expect(category2).to be_valid

      reason1 = FactoryGirl.create(:cancellation_reason, cancellation_category: category1)
      expect(reason1).to be_valid

      reason2 = FactoryGirl.create(:cancellation_reason, cancellation_category: category2)
      expect(reason2).to be_valid

      reasons = category1.cancellation_reasons
      expect(reasons.count).to eq 1
      expect(reasons).to include reason1
    end
  end

  describe '.name' do
    it 'must be 120 characters or less' do
      cancellation_category = FactoryGirl.build(:cancellation_category, name: Faker::Lorem.characters(121))
      expect(cancellation_category).to_not be_valid
      expect(cancellation_category.errors[:name]).to include 'is too long (maximum is 120 characters)'
    end

    it 'is required' do
      cancellation_category = FactoryGirl.build(:cancellation_category, name: '')
      expect(cancellation_category).to_not be_valid
      expect(cancellation_category.errors[:name]).to include 'can\'t be blank'
    end

    it 'must be unique' do
      cancellation_category = FactoryGirl.create(:cancellation_category, name: 'category')
      expect(cancellation_category).to be_valid

      cancellation_category = FactoryGirl.build(:cancellation_category, name: 'category')
      expect(cancellation_category).to_not be_valid
      expect(cancellation_category.errors[:name]).to include 'has already been taken'
    end
  end

  describe '.require_message' do
    # t.boolean :active, default: true, null: false
  end
end
