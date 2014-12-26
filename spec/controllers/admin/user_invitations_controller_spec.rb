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

# Tests for the admin user invitations controller
RSpec.describe Admin::UserInvitationsController, type: :controller do
  before :each do
    @account = FactoryGirl.create(:account)
  end

  describe 'POST #create' do
    context 'as anonymous user' do
      it 'redirects to login page' do
        post :create, account_id: @account.id, user_invitation: FactoryGirl.attributes_for(:user_invitation)
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not create a user' do
        # rubocop:disable Style/Blocks
        expect {
          post :create,
               account_id: @account.id,
               user_invitation: FactoryGirl.attributes_for(:user_invitation)
        }.to change { UserInvitation.count }.by(0)
        # rubocop:enable Style/Blocks
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        post :create, account_id: @account.id, user_invitation: FactoryGirl.attributes_for(:user_invitation)
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        post :create, account_id: @account.id, user_invitation: FactoryGirl.attributes_for(:user_invitation)
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end

      it 'does not create a user' do
        # rubocop:disable Style/Blocks
        expect {
          post :create,
               account_id: @account.id,
               user_invitation: FactoryGirl.attributes_for(:user_invitation)
        }.to change { UserInvitation.count }.by(0)
        # rubocop:enable Style/Blocks
      end
    end

    context 'as super admin user' do
      before :each do
        @admin = FactoryGirl.create(:admin)
        sign_in :user, @admin
      end

      context 'with valid attributes' do
        before(:each) do
          mailer = double(ActionMailer::Base)
          expect(mailer).to receive(:deliver_now).once
          expect(UserMailer).to receive(:user_invitation).with(kind_of(UserInvitation)).once.and_return(mailer)
        end

        it 'sets the nav_item to users' do
          post :create, account_id: @account.id, user_invitation: FactoryGirl.attributes_for(:user_invitation)
          expect(assigns(:nav_item)).to eq 'accounts'
        end

        it 'it redirects to user_invitation' do
          post :create, account_id: @account.id, user_invitation: FactoryGirl.attributes_for(:user_invitation)
          user_invitation = assigns(:user_invitation)
          expect(response).to be_redirect
          expect(response).to redirect_to(admin_account_user_invitation_path(user_invitation.account, user_invitation))
        end

        it 'sets a notice' do
          post :create, account_id: @account.id, user_invitation: FactoryGirl.attributes_for(:user_invitation)
          expect(request.flash[:notice]).to eq 'User invitation was successfully created.'
        end

        it 'creates a user invitation' do
          # rubocop:disable Style/Blocks
          expect {
            post :create,
                 account_id: @account.id,
                 user_invitation: FactoryGirl.attributes_for(:user_invitation)
          }.to change { UserInvitation.count }.by(1)
          # rubocop:enable Style/Blocks
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to users' do
          post :create, account_id: @account.id, user_invitation: FactoryGirl.attributes_for(:user_invitation)
          expect(assigns(:nav_item)).to eq 'accounts'
        end

        it 'it renders the new template' do
          post :create,
               account_id: @account.id,
               user_invitation: FactoryGirl.attributes_for(:user_invitation, email: '')
          expect(response).to render_template('new')
          expect(response).to render_template('layouts/admin')
        end

        it 'it pass a new user invitation' do
          post :create,
               account_id: @account.id,
               user_invitation: FactoryGirl.attributes_for(:user_invitation, email: '')
          user_invitation = assigns(:user_invitation)
          expect(user_invitation).to_not be_nil
          expect(user_invitation).to be_new_record
        end

        it 'does not create a user invitation' do
          # rubocop:disable Style/Blocks
          expect {
            post :create,
                 account_id: @account.id,
                 user_invitation: FactoryGirl.attributes_for(:user_invitation, email: '')
          }.to change { UserInvitation.count }.by(0)
          # rubocop:enable Style/Blocks
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @user_invitation = FactoryGirl.create(:user_invitation, account: @account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        delete :destroy, account_id: @account.id, id: @user_invitation.id
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not delete a user invitation' do
        # rubocop:disable Style/Blocks
        expect {
          delete :destroy, account_id: @account.id, id: @user_invitation.id
        }.to change { UserInvitation.count }.by(0)
        # rubocop:enable Style/Blocks
      end
    end

    context 'as unauthorized user invitations' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        delete :destroy, account_id: @account.id, id: @user_invitation.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        delete :destroy, account_id: @account.id, id: @user_invitation.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end

      it 'does not delete a user invitation' do
        # rubocop:disable Style/Blocks
        expect {
          delete :destroy, account_id: @account.id, id: @user_invitation.id
        }.to change { UserInvitation.count }.by(0)
        # rubocop:enable Style/Blocks
      end
    end

    context 'as super admin user' do
      before(:each) do
        @admin = FactoryGirl.create(:admin)
        sign_in :user, @admin
      end

      it 'it redirects to users' do
        delete :destroy, account_id: @account.id, id: @user_invitation.id
        expect(response).to be_redirect
        expect(response).to redirect_to(admin_account_user_invitations_path(@account))
      end

      it 'sets a notice' do
        delete :destroy, account_id: @account.id, id: @user_invitation.id
        expect(request.flash[:notice]).to eq 'User invitation was successfully removed.'
      end

      it 'deletes a user' do
        # rubocop:disable Style/Blocks
        expect {
          delete :destroy, account_id: @account.id, id: @user_invitation.id
        }.to change { UserInvitation.count }.by(-1)
        # rubocop:enable Style/Blocks
      end
    end
  end

  describe 'GET #edit' do
    before(:each) do
      @user_invitation = FactoryGirl.create(:user_invitation)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :edit, account_id: @account.id, id: @user_invitation.id
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        get :edit, account_id: @account.id, id: @user_invitation.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :edit, account_id: @account.id, id: @user_invitation.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :edit, account_id: @account.id, id: @user_invitation.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'sets the nav_item to users' do
        get :edit, account_id: @account.id, id: @user_invitation.id
        expect(assigns(:nav_item)).to eq 'accounts'
      end

      it 'renders the edit template' do
        get :edit, account_id: @account.id, id: @user_invitation.id
        expect(response).to render_template('edit')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a edit user invitation' do
        get :edit, account_id: @account.id, id: @user_invitation.id
        ui = assigns(:user_invitation)
        expect(ui).to_not be_nil
        expect(ui.id).to eq @user_invitation.id
      end
    end
  end

  describe 'GET #index without account_id' do
    context 'as anonymous user' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        get :index
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :index
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :index
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to users' do
        get :index
        expect(assigns(:nav_item)).to eq 'accounts'
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template('index')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns users correctly' do
        user_invitation = FactoryGirl.create(:user_invitation, account: @account)
        user_invitation2 = FactoryGirl.create(:user_invitation, account: @account, email: 'john-2@example.com')

        get :index
        user_invitations = assigns(:user_invitations)
        expect(user_invitations).to_not be_nil
        expect(user_invitations.count).to eq 2
        expect(user_invitations).to include user_invitation
        expect(user_invitations).to include user_invitation2
      end
    end
  end

  describe 'GET #index with account_id' do
    context 'as anonymous user' do
      it 'redirects to login page' do
        get :index, account_id: @account.id
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        get :index, account_id: @account.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :index, account_id: @account.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :index, account_id: @account.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to accounts' do
        get :index, account_id: @account.id
        expect(assigns(:nav_item)).to eq 'accounts'
      end

      it 'renders the index template' do
        get :index, account_id: @account.id
        expect(response).to render_template('index')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns users correctly' do
        user_invitation = FactoryGirl.create(:user_invitation, account: @account)
        user_invitation2 = FactoryGirl.create(:user_invitation, account: @account, email: 'john-2@example.com')

        get :index, account_id: @account.id
        user_invitations = assigns(:user_invitations)
        expect(user_invitations).to_not be_nil
        expect(user_invitations.count).to eq 2
        expect(user_invitations).to include user_invitation
        expect(user_invitations).to include user_invitation2
      end
    end
  end

  describe 'GET #new' do
    context 'as anonymous user' do
      it 'redirects to login page' do
        get :new, account_id: @account.id
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        get :new, account_id: @account.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :new, account_id: @account.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :new, account_id: @account.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to users' do
        get :new, account_id: @account.id
        expect(assigns(:nav_item)).to eq 'accounts'
      end

      it 'renders the new template' do
        get :new, account_id: @account.id
        expect(response).to render_template('new')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a new user' do
        get :new, account_id: @account.id
        user_invitation = assigns(:user_invitation)
        expect(user_invitation).to_not be_nil
        expect(user_invitation).to be_new_record
      end
    end
  end

  describe 'GET #show' do
    before(:each) do
      @user_invitation = FactoryGirl.create(:user_invitation, account: @account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :show, account_id: @account.id, id: @user_invitation.id
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        get :show, account_id: @account.id, id: @user_invitation.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :show, account_id: @account.id, id: @user_invitation.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :show, account_id: @account.id, id: @user_invitation.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to users' do
        get :show, account_id: @account.id, id: @user_invitation.id
        expect(assigns(:nav_item)).to eq 'accounts'
      end

      it 'renders the show template' do
        get :show, account_id: @account.id, id: @user_invitation.id
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a show user invitation' do
        get :show, account_id: @account.id, id: @user_invitation.id
        ui = assigns(:user_invitation)
        expect(ui).to_not be_nil
        expect(ui.id).to eq @user_invitation.id
      end
    end
  end

  describe 'PATCH #update' do
    before(:each) do
      @user_invitation = FactoryGirl.create(:user_invitation, account: @account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        patch :update,
              account_id: @account.id,
              id: @user_invitation.id,
              user_invitation: FactoryGirl.attributes_for(:user_invitation)
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        patch :update,
              account_id: @account.id,
              id: @user_invitation.id,
              user_invitation: FactoryGirl.attributes_for(:user_invitation)
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        patch :update,
              account_id: @account.id,
              id: @user_invitation.id,
              user_invitation: FactoryGirl.attributes_for(:user_invitation)
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      context 'with valid attributes' do
        before :each do
          mailer = double(ActionMailer::Base)
          expect(mailer).to receive(:deliver_now).once
          expect(UserMailer).to receive(:user_invitation).with(kind_of(UserInvitation)).once.and_return(mailer)
        end

        it 'sets the nav_item to users' do
          patch :update,
                account_id: @account.id,
                id: @user_invitation.id,
                user_invitation: FactoryGirl.attributes_for(:user_invitation)
          expect(assigns(:nav_item)).to eq 'accounts'
        end

        it 'it redirects to user' do
          patch :update,
                account_id: @account.id,
                id: @user_invitation.id,
                user_invitation: FactoryGirl.attributes_for(:user_invitation)
          expect(response).to be_redirect
          # rubocop:disable Metrics/LineLength
          expect(response).to redirect_to(admin_account_user_invitation_path(@user_invitation.account, @user_invitation))
          # rubocop:enable Metrics/LineLength
        end

        it 'sets a notice' do
          patch :update,
                account_id: @account.id,
                id: @user_invitation.id,
                user_invitation: FactoryGirl.attributes_for(:user_invitation)
          expect(request.flash[:notice]).to eq 'User invitation was successfully updated.'
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to users' do
          patch :update,
                account_id: @account.id,
                id: @user_invitation.id,
                user_invitation: FactoryGirl.attributes_for(:user_invitation, email: '')
          expect(assigns(:nav_item)).to eq 'accounts'
        end

        it 'it renders the new template' do
          patch :update,
                account_id: @account.id,
                id: @user_invitation.id,
                user_invitation: FactoryGirl.attributes_for(:user_invitation, email: '')
          expect(response).to render_template('edit')
          expect(response).to render_template('layouts/admin')
        end

        it 'it pass a new user invite' do
          patch :update,
                account_id: @account.id,
                id: @user_invitation.id,
                user_invitation: FactoryGirl.attributes_for(:user_invitation, email: '')
          user_invitation = assigns(:user_invitation)
          expect(user_invitation).to_not be_nil
          expect(user_invitation).to_not be_new_record
        end
      end
    end
  end
end
