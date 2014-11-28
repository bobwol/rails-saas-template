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

# Tests for the users controller
RSpec.describe UsersController, type: :controller do
  describe 'GET #accounts' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user_permission = FactoryGirl.create(:user_permission, user: @user)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :accounts, user_id: @user.id
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
        get :accounts, user_id: @user.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :accounts, user_id: @user.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as yourself' do
      before(:each) do
        sign_in :user, @user
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :accounts, user_id: @user.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'renders the accounts template' do
        get :accounts, user_id: @user.id
        expect(response).to render_template('accounts')
        expect(response).to render_template('layouts/application')
      end

      it 'assigns a user' do
        get :accounts, user_id: @user.id
        u = assigns(:user)
        expect(u).to_not be_nil
        expect(u.id).to eq @user.id
      end

      it 'assigns permissions' do
        get :accounts, user_id: @user.id
        permissions = assigns(:user_permissions)
        expect(permissions).to_not be_nil
        expect(permissions.count).to eq 1
        expect(permissions).to include @user_permission
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :accounts, user_id: @user.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'renders the accounts template' do
        get :accounts, user_id: @user.id
        expect(response).to render_template('accounts')
        expect(response).to render_template('layouts/application')
      end

      it 'assigns a user' do
        get :accounts, user_id: @user.id
        u = assigns(:user)
        expect(u).to_not be_nil
        expect(u.id).to eq @user.id
      end

      it 'assigns permissions' do
        get :accounts, user_id: @user.id
        permissions = assigns(:user_permissions)
        expect(permissions).to_not be_nil
        expect(permissions.count).to eq 1
        expect(permissions).to include @user_permission
      end
    end
  end

  describe 'GET #index' do
    context 'as anonymous user' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as logged in user' do
      it 'redirects to the users page' do
        @user = FactoryGirl.create(:user)
        sign_in :user, @user
        get :index
        expect(response).to be_redirect
        expect(response).to redirect_to(user_path(@user))
      end
    end
  end

  describe 'GET #user_invitations' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user_invitation = FactoryGirl.create(:user_invitation, email: @user.email)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :user_invitations, user_id: @user.id
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
        get :user_invitations, user_id: @user.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :user_invitations, user_id: @user.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as yourself' do
      before(:each) do
        sign_in :user, @user
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :user_invitations, user_id: @user.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'renders the accounts template' do
        get :user_invitations, user_id: @user.id
        expect(response).to render_template('user_invitations')
        expect(response).to render_template('layouts/application')
      end

      it 'assigns a user' do
        get :user_invitations, user_id: @user.id
        u = assigns(:user)
        expect(u).to_not be_nil
        expect(u.id).to eq @user.id
      end

      it 'assigns invitations' do
        get :user_invitations, user_id: @user.id
        invitations = assigns(:user_invitations)
        expect(invitations).to_not be_nil
        expect(invitations.count).to eq 1
        expect(invitations).to include @user_invitation
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :user_invitations, user_id: @user.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'renders the accounts template' do
        get :user_invitations, user_id: @user.id
        expect(response).to render_template('user_invitations')
        expect(response).to render_template('layouts/application')
      end

      it 'assigns a user' do
        get :user_invitations, user_id: @user.id
        u = assigns(:user)
        expect(u).to_not be_nil
        expect(u.id).to eq @user.id
      end

      it 'assigns invitations' do
        get :user_invitations, user_id: @user.id
        invitations = assigns(:user_invitations)
        expect(invitations).to_not be_nil
        expect(invitations.count).to eq 1
        expect(invitations).to include @user_invitation
      end
    end
  end

  describe 'GET #edit' do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :edit, id: @user.id
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
        get :edit, id: @user.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :show, id: @user.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as yourself' do
      before(:each) do
        sign_in :user, @user
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :edit, id: @user.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'renders the edit template' do
        get :edit, id: @user.id
        expect(response).to render_template('edit')
        expect(response).to render_template('layouts/application')
      end

      it 'assigns a user' do
        get :edit, id: @user.id
        u = assigns(:user)
        expect(u).to_not be_nil
        expect(u.id).to eq @user.id
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :edit, id: @user.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'renders the edit template' do
        get :edit, id: @user.id
        expect(response).to render_template('edit')
        expect(response).to render_template('layouts/application')
      end

      it 'assigns a user' do
        get :edit, id: @user.id
        u = assigns(:user)
        expect(u).to_not be_nil
        expect(u.id).to eq @user.id
      end
    end
  end

  describe 'GET #show' do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :show, id: @user.id
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
        get :show, id: @user.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :show, id: @user.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as yourself' do
      before(:each) do
        sign_in :user, @user
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :show, id: @user.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'renders the show template' do
        get :show, id: @user.id
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/application')
      end

      it 'assigns a user' do
        get :show, id: @user.id
        u = assigns(:user)
        expect(u).to_not be_nil
        expect(u.id).to eq @user.id
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :show, id: @user.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'renders the show template' do
        get :show, id: @user.id
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/application')
      end

      it 'assigns a user' do
        get :show, id: @user.id
        u = assigns(:user)
        expect(u).to_not be_nil
        expect(u.id).to eq @user.id
      end
    end
  end

  describe 'PATCH #update' do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user)
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
        patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user)
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user)
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as yourself' do
      before(:each) do
        sign_in :user, @user
      end

      context 'with valid attributes' do
        it 'it redirects to user' do
          patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user)
          user = assigns(:user)
          expect(response).to be_redirect
          expect(response).to redirect_to(user_path(user))
        end

        it 'sets a notice' do
          patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user)
          expect(request.flash[:notice]).to eq 'User was successfully updated.'
        end
      end

      context 'with invalid attributes' do
        it 'it renders the new template' do
          patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user, email: '')
          expect(response).to render_template('edit')
          expect(response).to render_template('layouts/application')
        end

        it 'it pass a new user' do
          patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user, email: '')
          user = assigns(:user)
          expect(user).to_not be_nil
          expect(user).to_not be_new_record
        end
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      context 'with valid attributes' do
        it 'it redirects to user' do
          patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user)
          user = assigns(:user)
          expect(response).to be_redirect
          expect(response).to redirect_to(user_path(user))
        end

        it 'sets a notice' do
          patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user)
          expect(request.flash[:notice]).to eq 'User was successfully updated.'
        end
      end

      context 'with invalid attributes' do
        it 'it renders the new template' do
          patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user, email: '')
          expect(response).to render_template('edit')
          expect(response).to render_template('layouts/application')
        end

        it 'it pass a new user' do
          patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user, email: '')
          user = assigns(:user)
          expect(user).to_not be_nil
          expect(user).to_not be_new_record
        end
      end
    end
  end
end
