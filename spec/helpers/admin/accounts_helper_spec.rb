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

# Specs in this file have access to a helper object that includes
# the Admin::AccountsHelper. For example:
#
# describe Admin::AccountsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe Admin::AccountsHelper, type: :helper do
  describe '.account_status' do
    context 'account is nil' do
      it 'returns unknown' do
        expect(helper.account_status(nil)).to eq '<span class="label label-default">Unknown</span>'
      end
    end

    context 'account is active' do
      it 'returns active' do
        account = FactoryGirl.build(:account)
        expect(helper.account_status(account)).to eq '<span class="label label-success">Active</span>'
      end
    end

    context 'account is cancel pending' do
      it 'returns cancel_pending' do
        account = FactoryGirl.build(:account, cancelled_at: Time.now)
        expect(helper.account_status(account)).to eq '<span class="label label-warning">Cancel Pending</span>'
      end
    end

    context 'account is cancelled' do
      it 'returns cancelled' do
        account = FactoryGirl.build(:account, active: false)
        expect(helper.account_status(account)).to eq '<span class="label label-danger">Cancelled</span>'
      end
    end

    context 'account is expired' do
      it 'returns expired' do
        account = FactoryGirl.build(:account, expires_at: Time.now - 3.days)
        expect(helper.account_status(account)).to eq '<span class="label label-warning">Expired</span>'
      end
    end

    context 'account is paused' do
      it 'returns paused' do
        plan = FactoryGirl.create(:plan)
        account = FactoryGirl.build(:account, paused_plan: plan)
        expect(helper.account_status(account)).to eq '<span class="label label-warning">Paused</span>'
      end
    end
  end
end
