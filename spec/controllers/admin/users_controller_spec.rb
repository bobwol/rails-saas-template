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

# Tests for the admin users controller
RSpec.describe Admin::UsersController, type: :controller do
  describe 'POST #create' do
    context 'as anonymous user' do
      it 'redirects to login page' do
        post :create, user: FactoryGirl.attributes_for(:user)
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not create a user' do
        expect {
          post :create, user: FactoryGirl.attributes_for(:user)
        }.to change { User.count }.by(0)
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        post :create, user: FactoryGirl.attributes_for(:user)
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        post :create, user: FactoryGirl.attributes_for(:user)
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end

      it 'does not create a user' do
        expect {
          post :create, user: FactoryGirl.attributes_for(:user)
        }.to change { User.count }.by(0)
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      context 'with valid attributes' do
        it 'sets the nav_item to users' do
          post :create, user: FactoryGirl.attributes_for(:user)
          expect(assigns(:nav_item)).to eq 'users'
        end

        it 'it redirects to user' do
          post :create, user: FactoryGirl.attributes_for(:user)
          user = assigns(:user)
          expect(response).to be_redirect
          expect(response).to redirect_to(admin_user_path(user))
        end

        it 'sets a notice' do
          post :create, user: FactoryGirl.attributes_for(:user)
          expect(request.flash[:notice]).to eq 'User was successfully created.'
        end

        it 'creates a user' do
          expect {
            post :create, user: FactoryGirl.attributes_for(:user)
          }.to change { User.count }.by(1)
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to users' do
          post :create, user: FactoryGirl.attributes_for(:user)
          expect(assigns(:nav_item)).to eq 'users'
        end

        it 'it renders the new template' do
          post :create, user: FactoryGirl.attributes_for(:user, email: '')
          expect(response).to render_template('new')
          expect(response).to render_template('layouts/admin')
        end

        it 'it pass a new user' do
          post :create, user: FactoryGirl.attributes_for(:user, email: '')
          user = assigns(:user)
          expect(user).to_not be_nil
          expect(user).to be_new_record
        end

        it 'does not create a user' do
          expect {
            post :create, user: FactoryGirl.attributes_for(:user, email: '')
          }.to change { User.count }.by(0)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        delete :destroy, id: @user.id
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not delete a user' do
        expect {
          delete :destroy, id: @user.id
        }.to change { User.count }.by(0)
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        sign_in :user, @user
      end

      it 'responds with forbidden' do
        delete :destroy, id: @user.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        delete :destroy, id: @user.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end

      it 'does not delete a user' do
        expect {
          delete :destroy, id: @user.id
        }.to change { User.count }.by(0)
      end
    end

    context 'as super admin user' do
      before(:each) do
        @admin = FactoryGirl.create(:admin)
        sign_in :user, @admin
      end

      context 'deleting another user' do
        it 'it redirects to users' do
          delete :destroy, id: @user.id
          expect(response).to be_redirect
          expect(response).to redirect_to(admin_users_path)
        end

        it 'sets a notice' do
          delete :destroy, id: @user.id
          expect(request.flash[:notice]).to eq 'User was successfully removed.'
        end

        it 'deletes a user' do
          expect {
            delete :destroy, id: @user.id
          }.to change { User.count }.by(-1)
        end
      end

      context 'deleting yourself' do
        it 'it redirects to users' do
          delete :destroy, id: @admin.id
          expect(response).to be_redirect
          expect(response).to redirect_to(admin_user_path(@admin))
        end

        it 'sets a notice' do
          delete :destroy, id: @admin.id
          expect(request.flash[:alert]).to eq 'You cannot delete yourself.'
        end

        it 'does not delete a user' do
          expect {
            delete :destroy, id: @admin.id
          }.to change { User.count }.by(0)
        end
      end
    end
  end

  describe 'GET #accounts' do
    before(:each) do
      @user = FactoryGirl.create(:user)
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
        sign_in :user, @user
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

      it 'sets the nav_item to users' do
        get :accounts, user_id: @user.id
        expect(assigns(:nav_item)).to eq 'users'
      end

      it 'renders the accounts template' do
        get :accounts, user_id: @user.id
        expect(response).to render_template('accounts')
        expect(response).to render_template('layouts/admin')
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
        sign_in :user, @user
      end

      it 'responds with forbidden' do
        get :edit, id: @user.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :edit, id: @user.id
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
        get :edit, id: @user.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'sets the nav_item to users' do
        get :edit, id: @user.id
        expect(assigns(:nav_item)).to eq 'users'
      end

      it 'renders the edit template' do
        get :edit, id: @user.id
        expect(response).to render_template('edit')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a edit user' do
        get :edit, id: @user.id
        u = assigns(:user)
        expect(u).to_not be_nil
        expect(u.id).to eq @user.id
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
        expect(assigns(:nav_item)).to eq 'users'
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template('index')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns users correctly' do
        user = FactoryGirl.create(:user)
        user2 = FactoryGirl.create(:user, email: 'john-2@example.com')

        get :index
        users = assigns(:users)
        expect(users).to_not be_nil
        # Remember that we've already created the admin so it's 3 not 2
        expect(users.count).to eq 3
        expect(users).to include user
        expect(users).to include user2
      end
    end
  end

  describe 'GET #new' do
    context 'as anonymous user' do
      it 'redirects to login page' do
        get :new
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
        get :new
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :new
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
        get :new
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to users' do
        get :new
        expect(assigns(:nav_item)).to eq 'users'
      end

      it 'renders the new template' do
        get :new
        expect(response).to render_template('new')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a new user' do
        get :new
        user = assigns(:user)
        expect(user).to_not be_nil
        expect(user).to be_new_record
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
        sign_in :user, @user
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

      it 'sets the nav_item to users' do
        get :show, id: @user.id
        expect(assigns(:nav_item)).to eq 'users'
      end

      it 'renders the show template' do
        get :show, id: @user.id
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a show user' do
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
        sign_in :user, @user
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

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      context 'with valid attributes' do
        it 'sets the nav_item to users' do
          patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user)
          expect(assigns(:nav_item)).to eq 'users'
        end

        it 'it redirects to user' do
          patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user)
          user = assigns(:user)
          expect(response).to be_redirect
          expect(response).to redirect_to(admin_user_path(user))
        end

        it 'sets a notice' do
          patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user)
          expect(request.flash[:notice]).to eq 'User was successfully updated.'
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to users' do
          patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user)
          expect(assigns(:nav_item)).to eq 'users'
        end

        it 'it renders the new template' do
          patch :update, id: @user.id, user: FactoryGirl.attributes_for(:user, email: '')
          expect(response).to render_template('edit')
          expect(response).to render_template('layouts/admin')
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
