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

# Tests for the user invitations controller
RSpec.describe Users::UserInvitationsController, type: :controller do
  describe 'POST #accept' do
    context 'without a logged in user' do
      context 'without an invite_code' do
        it 'it redirects to login' do
          post :accept
          expect(response).to be_redirect
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'with an invalid invite_code' do
        it 'it redirects to login' do
          post :accept, invite_code: 1234
          expect(response).to be_redirect
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'with a valid invite_code' do
        it 'it redirects to login' do
          user_invitation = FactoryGirl.create(:user_invitation)
          post :accept, invite_code: user_invitation.invite_code
          expect(response).to be_redirect
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    context 'with a logged in user' do
      before :each do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      context 'without an invite_code' do
        it 'it redirects to user' do
          post :accept
          expect(response).to be_redirect
          expect(response).to redirect_to(new_user_invitation_path(invite_code: nil))
        end
      end

      context 'with an invalid invite_code' do
        it 'it redirects to user' do
          post :accept, invite_code: 1234
          expect(response).to be_redirect
          expect(response).to redirect_to(new_user_invitation_path(invite_code: 1234))
        end
      end

      context 'with a valid invite_code' do
        before :each do
          @account = FactoryGirl.create(:account)
          @user_invitation = FactoryGirl.create(:user_invitation, account: @account)
          mailer = double(ActionMailer::Base)
          expect(mailer).to receive(:deliver).once
          expect(UserMailer).to receive(:welcome).with(kind_of(User)).once.and_return(mailer)
        end

        it 'assigns an existing user invitation' do
          post :accept, invite_code: @user_invitation.invite_code
          account = assigns(:account)
          expect(account).to_not be_nil
          expect(account).to_not be_new_record
          expect(account).to eq @account
        end

        it 'renders the accept template' do
          post :accept, invite_code: @user_invitation.invite_code
          expect(response).to render_template('accept')
          expect(response).to render_template('layouts/marketing')
        end
      end
    end
  end

  describe 'GET #show' do
    context 'without an invite_code' do
      it 'responds successfully with an HTTP 200 status code' do
        get :show
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'renders the new template' do
        get :show
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/marketing')
      end

      it 'assigns a new user invitation' do
        get :show
        user_invitation = assigns(:user_invitation)
        expect(user_invitation).to_not be_nil
        expect(user_invitation).to be_new_record
      end
    end

    context 'with an invalid invite_code' do
      it 'responds successfully with an HTTP 200 status code' do
        get :show, invite_code: 1234
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'renders the new template' do
        get :show, invite_code: 1234
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/marketing')
      end

      it 'assigns an existing user invitation' do
        get :show, invite_code: 1234
        user_invitation = assigns(:user_invitation)
        expect(user_invitation).to_not be_nil
        expect(user_invitation).to be_new_record
        expect(user_invitation.invite_code).to eq '1234'
      end
    end

    context 'with a invalid invite_code' do
      before :each do
        @user_invitation = FactoryGirl.create(:user_invitation)
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :show, invite_code: 1234
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'renders the new template' do
        get :show, invite_code: 1234
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/marketing')
      end

      it 'assigns an existing user invitation' do
        get :show, invite_code: @user_invitation.invite_code
        user_invitation = assigns(:user_invitation)
        expect(user_invitation).to_not be_nil
        expect(user_invitation).to be_new_record
        expect(user_invitation.invite_code).to eq @user_invitation.invite_code
      end
    end
  end
end
