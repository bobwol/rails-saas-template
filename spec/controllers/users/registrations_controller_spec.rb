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

# Test for customized Devise registrations controller
RSpec.describe Users::RegistrationsController, type: :controller do
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'GET #new' do
    it 'responds successfully with an HTTP 200 status code' do
      get :new
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the registration form' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'POST #create' do
    before :each do
      account = FactoryGirl.create(:account)
      @user_invitation = FactoryGirl.create(:user_invitation, account: account)
      mailer = double(ActionMailer::Base)
      expect(mailer).to receive(:deliver).once
      expect(UserMailer).to receive(:welcome).with(kind_of(User)).once.and_return(mailer)
    end

    it 'responds successfully with an HTTP 200 status code' do
      post :create, user: FactoryGirl.attributes_for(:user), invite_code: @user_invitation.invite_code
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end
end
