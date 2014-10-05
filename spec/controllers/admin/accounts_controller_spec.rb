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

# Tests for the admin accounts controller
RSpec.describe Admin::AccountsController, type: :controller do
  describe 'POST #create' do
    context 'as anonymous user' do
      it 'redirects to login page' do
        post :create, account: FactoryGirl.attributes_for(:account)
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not create an account' do
        expect { post :create, account: FactoryGirl.attributes_for(:account) }.to change { Account.count }.by(0)
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        post :create, account: FactoryGirl.attributes_for(:account)
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        post :create, account: FactoryGirl.attributes_for(:account)
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end

      it 'does not create an account' do
        expect { post :create, account: FactoryGirl.attributes_for(:account) }.to change { Account.count }.by(0)
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      context 'with valid attributes' do
        before(:each) do
          plan = FactoryGirl.create(:plan)
          @account_attributes = FactoryGirl.attributes_for(:account).merge(plan_id: plan.id)
        end

        it 'sets the nav_item to accounts' do
          post :create, account: @account_attributes
          expect(assigns(:nav_item)).to eq 'accounts'
        end

        it 'it redirects to account' do
          post :create, account: @account_attributes
          account = assigns(:account)
          expect(response).to be_redirect
          expect(response).to redirect_to(admin_account_path(account))
        end

        it 'sets a notice' do
          post :create, account: @account_attributes
          expect(request.flash[:notice]).to eq 'Account was successfully created.'
        end

        it 'creates an account' do
          expect { post :create, account: @account_attributes }.to change { Account.count }.by(1)
        end
      end

      context 'with invalid attributes' do
        before :each do
          @attrs = FactoryGirl.attributes_for(:account, company_name: '')
        end

        it 'sets the nav_item to accounts' do
          post :create, account: @attrs
          expect(assigns(:nav_item)).to eq 'accounts'
        end

        it 'it renders the new template' do
          post :create, account: @attrs
          expect(response).to render_template('new')
          expect(response).to render_template('layouts/admin')
        end

        it 'it pass a new account' do
          post :create, account: @attrs
          account = assigns(:account)
          expect(account).to_not be_nil
          expect(account).to be_new_record
        end

        it 'does not create an account' do
          expect { post :create, account: @attrs }.to change { Account.count }.by(0)
        end
      end
    end
  end

  describe 'PATCH #cancel' do
  end

  describe 'GET #confirm_cancel' do
    before(:each) do
      @account = FactoryGirl.create(:account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :confirm_cancel, account_id: @account.id
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
        get :confirm_cancel, account_id: @account.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :confirm_cancel, account_id: @account.id
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
        get :confirm_cancel, account_id: @account.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'sets the nav_item to accounts' do
        get :confirm_cancel, account_id: @account.id
        expect(assigns(:nav_item)).to eq 'accounts'
      end

      it 'renders the confirm_cancel template' do
        get :confirm_cancel, account_id: @account.id
        expect(response).to render_template('confirm_cancel')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a confirm_cancel account' do
        get :confirm_cancel, account_id: @account.id
        a = assigns(:account)
        expect(a).to_not be_nil
        expect(a.id).to eq @account.id
      end
    end
  end

  describe 'GET #confirm_restore' do
    before(:each) do
      @account = FactoryGirl.create(:account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :confirm_restore, account_id: @account.id
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
        get :confirm_restore, account_id: @account.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :confirm_restore, account_id: @account.id
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
        get :confirm_restore, account_id: @account.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'sets the nav_item to accounts' do
        get :confirm_restore, account_id: @account.id
        expect(assigns(:nav_item)).to eq 'accounts'
      end

      it 'renders the confirm_restore template' do
        get :confirm_restore, account_id: @account.id
        expect(response).to render_template('confirm_restore')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a confirm_restore account' do
        get :confirm_restore, account_id: @account.id
        a = assigns(:account)
        expect(a).to_not be_nil
        expect(a.id).to eq @account.id
      end
    end
  end

  describe 'GET #edit' do
    before(:each) do
      @account = FactoryGirl.create(:account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :edit, id: @account.id
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
        get :edit, id: @account.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :edit, id: @account.id
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
        get :edit, id: @account.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'sets the nav_item to accounts' do
        get :edit, id: @account.id
        expect(assigns(:nav_item)).to eq 'accounts'
      end

      it 'renders the edit template' do
        get :edit, id: @account.id
        expect(response).to render_template('edit')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a edit account' do
        get :edit, id: @account.id
        a = assigns(:account)
        expect(a).to_not be_nil
        expect(a.id).to eq @account.id
      end
    end
  end

  describe 'GET #events' do
    before(:each) do
      @account = FactoryGirl.create(:account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :events, account_id: @account.id
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
        get :events, account_id: @account.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :events, account_id: @account.id
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
        get :events, account_id: @account.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'sets the nav_item to accounts' do
        get :events, account_id: @account.id
        expect(assigns(:nav_item)).to eq 'accounts'
      end

      it 'renders the events template' do
        get :events, account_id: @account.id
        expect(response).to render_template('events')
        expect(response).to render_template('layouts/admin')
      end
    end
  end

  describe 'GET #index' do
    context 'as anonymous user' do
      it 'redirects to login page' do
        get :index
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

      it 'sets the nav_item to accounts' do
        get :index
        expect(assigns(:nav_item)).to eq 'accounts'
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template('index')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns accounts correctly' do
        account = FactoryGirl.create(:account)
        account2 = FactoryGirl.create(:account, company_name: 'Account2')

        get :index
        accounts = assigns(:accounts)
        expect(accounts).to_not be_nil
        expect(accounts.count).to eq 2
        expect(accounts).to include account
        expect(accounts).to include account2
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

      it 'sets the nav_item to accounts' do
        get :new
        expect(assigns(:nav_item)).to eq 'accounts'
      end

      it 'renders the new template' do
        get :new
        expect(response).to render_template('new')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a new account' do
        get :new
        account = assigns(:account)
        expect(account).to_not be_nil
        expect(account).to be_new_record
      end
    end
  end

  describe 'GET #show' do
    before(:each) do
      @account = FactoryGirl.create(:account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :show, id: @account.id
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
        get :show, id: @account.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :show, id: @account.id
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
        get :show, id: @account.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to accounts' do
        get :show, id: @account.id
        expect(assigns(:nav_item)).to eq 'accounts'
      end

      it 'renders the show template' do
        get :show, id: @account.id
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a show account' do
        get :show, id: @account.id
        a = assigns(:account)
        expect(a).to_not be_nil
        expect(a.id).to eq @account.id
      end
    end
  end

  describe 'GET #users' do
    before(:each) do
      @account = FactoryGirl.create(:account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :users, account_id: @account.id
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
        get :users, account_id: @account.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :users, account_id: @account.id
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
        get :users, account_id: @account.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'sets the nav_item to accounts' do
        get :users, account_id: @account.id
        expect(assigns(:nav_item)).to eq 'accounts'
      end

      it 'renders the users template' do
        get :users, account_id: @account.id
        expect(response).to render_template('users')
        expect(response).to render_template('layouts/admin')
      end
    end
  end

  describe 'PATCH #cancel' do
    before(:each) do
      @account = FactoryGirl.create(:account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        patch :cancel, account_id: @account.id, account: { cancellation_category: 'xxx',
                                                           cancellation_reason: 'yyy',
                                                           cancellation_message: 'zzz' }
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
        patch :cancel, account_id: @account.id, account: { cancellation_category: 'xxx',
                                                           cancellation_reason: 'yyy',
                                                           cancellation_message: 'zzz' }
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        patch :cancel, account_id: @account.id, account: { cancellation_category: 'xxx',
                                                           cancellation_reason: 'yyy',
                                                           cancellation_message: 'zzz' }
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
        it 'sets the nav_item to accounts' do
          patch :cancel, account_id: @account.id, account: { cancellation_category: 'xxx',
                                                             cancellation_reason: 'yyy',
                                                             cancellation_message: 'zzz' }
          expect(assigns(:nav_item)).to eq 'accounts'
        end

        it 'it redirects to account' do
          patch :cancel, account_id: @account.id, account: { cancellation_category: 'xxx',
                                                             cancellation_reason: 'yyy',
                                                             cancellation_message: 'zzz' }
          account = assigns(:account)
          expect(response).to be_redirect
          expect(response).to redirect_to(admin_account_path(account))
        end

        it 'sets a notice' do
          post :cancel, account_id: @account.id, account: { cancellation_category: 'xxx',
                                                            cancellation_reason: 'yyy',
                                                            cancellation_message: 'zzz' }
          expect(request.flash[:notice]).to eq 'Account was successfully cancelled.'
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to accounts' do
          patch :cancel, account_id: @account.id, account: { something: 'xxx' }
          expect(assigns(:nav_item)).to eq 'accounts'
        end

        it 'it renders the confirm_cancel template' do
          patch :cancel, account_id: @account.id, account: { something: 'xxx' }
          expect(response).to render_template('confirm_cancel')
          expect(response).to render_template('layouts/admin')
        end

        it 'it pass a new account' do
          patch :cancel, account_id: @account.id, account: { something: 'xxx' }
          account = assigns(:account)
          expect(account).to_not be_nil
          expect(account).to_not be_new_record
        end
      end
    end
  end

  describe 'PATCH #restore' do
    before(:each) do
      @account = FactoryGirl.create(:account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        patch :restore, account_id: @account.id, account: {}
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
        patch :restore, account_id: @account.id, account: {}
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        patch :restore, account_id: @account.id, account: {}
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
        it 'sets the nav_item to accounts' do
          patch :restore, account_id: @account.id, account: {}
          expect(assigns(:nav_item)).to eq 'accounts'
        end

        it 'it redirects to account' do
          patch :restore, account_id: @account.id, account: {}
          account = assigns(:account)
          expect(response).to be_redirect
          expect(response).to redirect_to(admin_account_path(account))
        end

        it 'sets a notice' do
          post :restore, account_id: @account.id, account: {}
          expect(request.flash[:notice]).to eq 'Account was successfully restored.'
        end
      end
    end
  end

  describe 'PATCH #update' do
    before(:each) do
      @account = FactoryGirl.create(:account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        patch :update, id: @account.id, account: FactoryGirl.attributes_for(:account)
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
        patch :update, id: @account.id, account: FactoryGirl.attributes_for(:account)
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        patch :update, id: @account.id, account: FactoryGirl.attributes_for(:account)
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
        it 'sets the nav_item to accounts' do
          patch :update, id: @account.id, account: FactoryGirl.attributes_for(:account)
          expect(assigns(:nav_item)).to eq 'accounts'
        end

        it 'it redirects to account' do
          patch :update, id: @account.id, account: FactoryGirl.attributes_for(:account)
          account = assigns(:account)
          expect(response).to be_redirect
          expect(response).to redirect_to(admin_account_path(account))
        end

        it 'sets a notice' do
          post :update, id: @account.id, account: FactoryGirl.attributes_for(:account)
          expect(request.flash[:notice]).to eq 'Account was successfully updated.'
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to accounts' do
          patch :update, id: @account.id, account: FactoryGirl.attributes_for(:account)
          expect(assigns(:nav_item)).to eq 'accounts'
        end

        it 'it renders the new template' do
          patch :update, id: @account.id, account: FactoryGirl.attributes_for(:account, company_name: '')
          expect(response).to render_template('edit')
          expect(response).to render_template('layouts/admin')
        end

        it 'it pass a new account' do
          patch :update, id: @account.id, account: FactoryGirl.attributes_for(:account, company_name: '')
          account = assigns(:account)
          expect(account).to_not be_nil
          expect(account).to_not be_new_record
        end
      end
    end
  end
end
