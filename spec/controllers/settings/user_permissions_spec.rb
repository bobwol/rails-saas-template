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

# Tests for the settings user permissions
RSpec.describe Settings::UserPermissionsController, type: :controller do
  before :each do
    @account = FactoryGirl.create(:account)
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user_permission = FactoryGirl.create(:user_permission, account: @account, user: @user)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        delete :destroy, path: @account.id, id: @user_permission.id
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not delete a user permission' do
        expect { delete :destroy, path: @account.id, id: @user_permission.id }.to change { UserPermission.count }.by(0)
      end
    end

    context 'as unauthorized user permissions' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        delete :destroy, path: @account.id, id: @user_permission.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        delete :destroy, path: @account.id, id: @user_permission.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end

      it 'does not delete a user permission' do
        expect { delete :destroy, path: @account.id, id: @user_permission.id }.to change { UserPermission.count }.by(0)
      end
    end

    context 'as account admin user' do
      context 'with yourself' do
        before(:each) do
          user = FactoryGirl.create(:user)
          @user_permission = FactoryGirl.create(:user_permission, account: @account, user: user, account_admin: true)
          sign_in :user, user
        end

        it 'responds with forbidden' do
          delete :destroy, path: @account.id, id: @user_permission.id
          expect(response).to be_forbidden
        end

        it 'renders the forbidden' do
          delete :destroy, path: @account.id, id: @user_permission.id
          expect(response).to render_template('errors/forbidden')
          expect(response).to render_template('layouts/errors')
        end

        it 'does not delete a user' do
          expect { delete :destroy, path: @account.id, id: @user_permission.id }.to change { User.count }.by(0)
        end
      end

      context 'with a different user' do
        before(:each) do
          user = FactoryGirl.create(:user)
          FactoryGirl.create(:user_permission, account: @account, user: user, account_admin: true)
          sign_in :user, user
        end

        it 'it redirects to users' do
          delete :destroy, path: @account.id, id: @user_permission.id
          expect(response).to be_redirect
          expect(response).to redirect_to(settings_user_permissions_path)
        end

        it 'sets a notice' do
          delete :destroy, path: @account.id, id: @user_permission.id
          expect(request.flash[:notice]).to eq 'User was successfully removed.'
        end

        it 'deletes a user' do
          # rubocop:disable Style/Blocks
          expect {
            delete :destroy, path: @account.id, id: @user_permission.id
          }.to change { UserPermission.count }.by(-1)
          # rubocop:enable Style/Blocks
        end
      end
    end

    context 'as super admin user' do
      before(:each) do
        @admin = FactoryGirl.create(:admin)
        sign_in :user, @admin
      end

      it 'it redirects to users' do
        delete :destroy, path: @account.id, id: @user_permission.id
        expect(response).to be_redirect
        expect(response).to redirect_to(settings_user_permissions_path)
      end

      it 'sets a notice' do
        delete :destroy, path: @account.id, id: @user_permission.id
        expect(request.flash[:notice]).to eq 'User was successfully removed.'
      end

      it 'deletes a user' do
        expect { delete :destroy, path: @account.id, id: @user_permission.id }.to change { UserPermission.count }.by(-1)
      end
    end
  end

  describe 'GET #edit' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user_permission = FactoryGirl.create(:user_permission, account: @account, user: @user)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :edit, path: @account.id, id: @user_permission.id
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
        get :edit, path: @account.id, id: @user_permission.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :edit, path: @account.id, id: @user_permission.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as account admin user' do
      before(:each) do
        user = FactoryGirl.create(:user)
        FactoryGirl.create(:user_permission, account: @account, user: user, account_admin: true)
        sign_in :user, user
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :edit, path: @account.id, id: @user_permission.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'sets the nav_item to users' do
        get :edit, path: @account.id, id: @user_permission.id
        expect(assigns(:nav_item)).to eq 'users'
      end

      it 'renders the edit template' do
        get :edit, path: @account.id, id: @user_permission.id
        expect(response).to render_template('edit')
        expect(response).to render_template('layouts/settings')
      end

      it 'assigns a edit user permission' do
        get :edit, path: @account.id, id: @user_permission.id
        ui = assigns(:user_permission)
        expect(ui).to_not be_nil
        expect(ui.id).to eq @user_permission.id
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :edit, path: @account.id, id: @user_permission.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'sets the nav_item to users' do
        get :edit, path: @account.id, id: @user_permission.id
        expect(assigns(:nav_item)).to eq 'users'
      end

      it 'renders the edit template' do
        get :edit, path: @account.id, id: @user_permission.id
        expect(response).to render_template('edit')
        expect(response).to render_template('layouts/settings')
      end

      it 'assigns a edit user permission' do
        get :edit, path: @account.id, id: @user_permission.id
        ui = assigns(:user_permission)
        expect(ui).to_not be_nil
        expect(ui.id).to eq @user_permission.id
      end
    end
  end

  describe 'GET #index' do
    context 'as anonymous user' do
      it 'redirects to login page' do
        get :index, path: @account.id
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        get :index, path: @account.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :index, path: @account.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as account admin user' do
      before(:each) do
        user = FactoryGirl.create(:user)
        FactoryGirl.create(:user_permission, account: @account, user: user, account_admin: true)
        sign_in :user, user
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :index, path: @account.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to user_permissions' do
        get :index, path: @account.id
        expect(assigns(:nav_item)).to eq 'users'
      end

      it 'renders the index template' do
        get :index, path: @account.id
        expect(response).to render_template('index')
        expect(response).to render_template('layouts/settings')
      end

      it 'assigns users correctly' do
        user_permission = FactoryGirl.create(:user_permission, account: @account)
        user_permission2 = FactoryGirl.create(:user_permission, account: @account)

        get :index, path: @account.id
        user_permissions = assigns(:user_permissions)
        expect(user_permissions).to_not be_nil
        expect(user_permissions.count).to eq 3 # Account admin also had permission
        expect(user_permissions).to include user_permission
        expect(user_permissions).to include user_permission2
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :index, path: @account.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to user_permissions' do
        get :index, path: @account.id
        expect(assigns(:nav_item)).to eq 'users'
      end

      it 'renders the index template' do
        get :index, path: @account.id
        expect(response).to render_template('index')
        expect(response).to render_template('layouts/settings')
      end

      it 'assigns users correctly' do
        user_permission = FactoryGirl.create(:user_permission, account: @account)
        user_permission2 = FactoryGirl.create(:user_permission, account: @account)

        get :index, path: @account.id
        user_permissions = assigns(:user_permissions)
        expect(user_permissions).to_not be_nil
        expect(user_permissions.count).to eq 2
        expect(user_permissions).to include user_permission
        expect(user_permissions).to include user_permission2
      end
    end
  end

  describe 'GET #show' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user_permission = FactoryGirl.create(:user_permission, account: @account, user: @user)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :show, path: @account.id, id: @user_permission.id
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
        get :show, path: @account.id, id: @user_permission.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :show, path: @account.id, id: @user_permission.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as account admin user' do
      before(:each) do
        user = FactoryGirl.create(:user)
        FactoryGirl.create(:user_permission, account: @account, user: user, account_admin: true)
        sign_in :user, user
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :show, path: @account.id, id: @user_permission.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to users' do
        get :show, path: @account.id, id: @user_permission.id
        expect(assigns(:nav_item)).to eq 'users'
      end

      it 'renders the show template' do
        get :show, path: @account.id, id: @user_permission.id
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/settings')
      end

      it 'assigns a show user permission' do
        get :show, path: @account.id, id: @user_permission.id
        ui = assigns(:user_permission)
        expect(ui).to_not be_nil
        expect(ui.id).to eq @user_permission.id
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :show, path: @account.id, id: @user_permission.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to users' do
        get :show, path: @account.id, id: @user_permission.id
        expect(assigns(:nav_item)).to eq 'users'
      end

      it 'renders the show template' do
        get :show, path: @account.id, id: @user_permission.id
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/settings')
      end

      it 'assigns a show user permission' do
        get :show, path: @account.id, id: @user_permission.id
        ui = assigns(:user_permission)
        expect(ui).to_not be_nil
        expect(ui.id).to eq @user_permission.id
      end
    end
  end

  describe 'PATCH #update' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user_permission = FactoryGirl.create(:user_permission, account: @account, user: @user)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        patch :update,
              path: @account.id,
              id: @user_permission.id,
              user_permission: FactoryGirl.attributes_for(:user_permission)
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
              path: @account.id,
              id: @user_permission.id,
              user_permission: FactoryGirl.attributes_for(:user_permission)
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        patch :update,
              path: @account.id,
              id: @user_permission.id,
              user_permission: FactoryGirl.attributes_for(:user_permission, user: @user, account: @account)
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as account admin user' do
      before(:each) do
        user = FactoryGirl.create(:user)
        FactoryGirl.create(:user_permission, account: @account, user: user, account_admin: true)
        sign_in :user, user
      end

      context 'with valid attributes' do
        it 'sets the nav_item to users' do
          patch :update,
                path: @account.id,
                id: @user_permission.id,
                user_permission: FactoryGirl.attributes_for(:user_permission)
          expect(assigns(:nav_item)).to eq 'users'
        end

        it 'it redirects to user' do
          patch :update,
                path: @account.id,
                id: @user_permission.id,
                user_permission: FactoryGirl.attributes_for(:user_permission)
          expect(response).to be_redirect
          expect(response).to redirect_to(settings_user_permission_path(@user_permission))
        end

        it 'sets a notice' do
          patch :update,
                path: @account.id,
                id: @user_permission.id,
                user_permission: FactoryGirl.attributes_for(:user_permission)
          expect(request.flash[:notice]).to eq 'User permissions were successfully updated.'
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to users' do
          patch :update,
                path: @account.id,
                id: @user_permission.id,
                user_permission: FactoryGirl.attributes_for(:user_permission, account_admin: '')
          expect(assigns(:nav_item)).to eq 'users'
        end

        it 'it renders the new template' do
          patch :update,
                path: @account.id,
                id: @user_permission.id,
                user_permission: FactoryGirl.attributes_for(:user_permission, account_admin: '')
          expect(response).to render_template('edit')
          expect(response).to render_template('layouts/settings')
        end

        it 'it pass a new user permission' do
          patch :update,
                path: @account.id,
                id: @user_permission.id,
                user_permission: FactoryGirl.attributes_for(:user_permission, account_admin: '')
          user_permission = assigns(:user_permission)
          expect(user_permission).to_not be_nil
          expect(user_permission).to_not be_new_record
        end
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      context 'with valid attributes' do
        it 'sets the nav_item to users' do
          patch :update,
                path: @account.id,
                id: @user_permission.id,
                user_permission: FactoryGirl.attributes_for(:user_permission)
          expect(assigns(:nav_item)).to eq 'users'
        end

        it 'it redirects to user permissions' do
          patch :update,
                path: @account.id,
                id: @user_permission.id,
                user_permission: FactoryGirl.attributes_for(:user_permission)
          expect(response).to be_redirect
          expect(response).to redirect_to(settings_user_permission_path(@user_permission))
        end

        it 'sets a notice' do
          patch :update,
                path: @account.id,
                id: @user_permission.id,
                user_permission: FactoryGirl.attributes_for(:user_permission)
          expect(request.flash[:notice]).to eq 'User permissions were successfully updated.'
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to users' do
          patch :update,
                path: @account.id,
                id: @user_permission.id,
                user_permission: FactoryGirl.attributes_for(:user_permission, account_admin: '')
          expect(assigns(:nav_item)).to eq 'users'
        end

        it 'it renders the new template' do
          patch :update,
                path: @account.id,
                id: @user_permission.id,
                user_permission: FactoryGirl.attributes_for(:user_permission, account_admin: '')
          expect(response).to render_template('edit')
          expect(response).to render_template('layouts/settings')
        end

        it 'it pass a new user permission' do
          patch :update,
                path: @account.id,
                id: @user_permission.id,
                user_permission: FactoryGirl.attributes_for(:user_permission, account_admin: '')
          user_permission = assigns(:user_permission)
          expect(user_permission).to_not be_nil
          expect(user_permission).to_not be_new_record
        end
      end
    end
  end
end
