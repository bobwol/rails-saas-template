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

# Tests for the settings plans
RSpec.describe Settings::PlansController, type: :controller do
  describe 'GET #edit' do
    before(:each) do
      @plan = FactoryGirl.create(:plan, currency: 'USD')
      @plan1 = FactoryGirl.create(:plan, currency: 'USD')
      @account = FactoryGirl.create(:account, plan: @plan)
      @controller.instance_variable_set(:@current_account, @account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :edit, id: @plan1.id
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
        get :edit, id: @plan1.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :edit, id: @plan1.id
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
        get :edit, id: @plan1.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'sets the nav_item to plans' do
        get :edit, id: @plan1.id
        expect(assigns(:nav_item)).to eq 'plans'
      end

      it 'renders the edit template' do
        get :edit, id: @plan1.id
        expect(response).to render_template('edit')
        expect(response).to render_template('layouts/settings')
      end

      it 'assigns a edit account' do
        get :edit, id: @plan1.id
        a = assigns(:account)
        expect(a).to_not be_nil
        expect(a.id).to eq @account.id
        expect(a.plan_id).to eq @plan1.id
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :edit, id: @plan1.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'sets the nav_item to plans' do
        get :edit, id: @plan1.id
        expect(assigns(:nav_item)).to eq 'plans'
      end

      it 'renders the edit template' do
        get :edit, id: @plan1.id
        expect(response).to render_template('edit')
        expect(response).to render_template('layouts/settings')
      end

      it 'assigns a edit account' do
        get :edit, id: @plan1.id
        a = assigns(:account)
        expect(a).to_not be_nil
        expect(a.id).to eq @account.id
        expect(a.plan_id).to eq @plan1.id
      end
    end
  end

  describe 'GET #show' do
    before(:each) do
      @plan = FactoryGirl.create(:plan, currency: 'USD')
      @account = FactoryGirl.create(:account, plan: @plan)
      @controller.instance_variable_set(:@current_account, @account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :show
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
        get :show
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :show
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end
    end

    context 'as account admin user' do
      before(:each) do
        @plan1 = FactoryGirl.create(:plan, currency: 'USD')
        @plan2 = FactoryGirl.create(:plan, currency: 'USD')
        @plan3 = FactoryGirl.create(:plan, currency: 'AUD')
        user = FactoryGirl.create(:user)
        FactoryGirl.create(:user_permission, account: @account, user: user, account_admin: true)
        sign_in :user, user
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :show
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to plans' do
        get :show
        expect(assigns(:nav_item)).to eq 'plans'
      end

      it 'renders the show template' do
        get :show
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/settings')
      end

      it 'assigns the plans' do
        get :show
        plans = assigns(:plans)
        expect(plans).to_not be_nil
        expect(plans.count).to eq 3
        expect(plans).to include @plan
        expect(plans).to include @plan1
        expect(plans).to include @plan2
      end
    end

    context 'as super admin user' do
      before(:each) do
        @plan1 = FactoryGirl.create(:plan, currency: 'USD')
        @plan2 = FactoryGirl.create(:plan, currency: 'USD')
        @plan3 = FactoryGirl.create(:plan, currency: 'AUD')
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :show
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to plans' do
        get :show
        expect(assigns(:nav_item)).to eq 'plans'
      end

      it 'renders the show template' do
        get :show
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/settings')
      end

      it 'assigns the plans' do
        get :show
        plans = assigns(:plans)
        expect(plans).to_not be_nil
        expect(plans.count).to eq 3
        expect(plans).to include @plan
        expect(plans).to include @plan1
        expect(plans).to include @plan2
      end
    end
  end

  describe 'PATCH #update' do
    before(:each) do
      @plan = FactoryGirl.create(:plan, currency: 'USD')
      @plan1 = FactoryGirl.create(:plan, currency: 'USD')
      @account = FactoryGirl.create(:account, plan: @plan)
      @controller.instance_variable_set(:@current_account, @account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        patch :update, account: FactoryGirl.attributes_for(:account, plan_id: @plan1.id)
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
        patch :update, account: FactoryGirl.attributes_for(:account, plan_id: @plan1.id)
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        patch :update, account: FactoryGirl.attributes_for(:account, plan_id: @plan1.id)
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
        it 'sets the nav_item to plans' do
          patch :update, account: FactoryGirl.attributes_for(:account, plan_id: @plan1.id)
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it redirects to plans' do
          patch :update, account: FactoryGirl.attributes_for(:account, plan_id: @plan1.id)
          expect(response).to be_redirect
          expect(response).to redirect_to(settings_plan_path)
        end

        it 'sets a notice' do
          patch :update, account: FactoryGirl.attributes_for(:account, plan_id: @plan1.id)
          expect(request.flash[:notice]).to eq 'Plan was successfully updated.'
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to plans' do
          patch :update, account: FactoryGirl.attributes_for(:account, plan_id: nil)
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it renders the errors/not_found template' do
          patch :update, account: FactoryGirl.attributes_for(:account, plan_id: nil)
          expect(response).to render_template('errors/not_found')
          expect(response).to render_template('layouts/errors')
        end

        it 'it pass an existing account' do
          patch :update, account: FactoryGirl.attributes_for(:account, plan_id: nil)
          account = assigns(:account)
          expect(account).to_not be_nil
          expect(account).to_not be_new_record
        end
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      context 'with valid attributes' do
        it 'sets the nav_item to plans' do
          patch :update, account: FactoryGirl.attributes_for(:account, plan_id: @plan1.id)
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it redirects to plans' do
          patch :update, account: FactoryGirl.attributes_for(:account, plan_id: @plan1.id)
          expect(response).to be_redirect
          expect(response).to redirect_to(settings_plan_path)
        end

        it 'sets a notice' do
          patch :update, account: FactoryGirl.attributes_for(:account, plan_id: @plan1.id)
          expect(request.flash[:notice]).to eq 'Plan was successfully updated.'
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to plans' do
          patch :update, account: FactoryGirl.attributes_for(:account, plan_id: nil)
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it renders the errors/not_found template' do
          patch :update, account: FactoryGirl.attributes_for(:account, plan_id: nil)
          expect(response).to render_template('errors/not_found')
          expect(response).to render_template('layouts/errors')
        end

        it 'it pass an existing account' do
          patch :update, account: FactoryGirl.attributes_for(:account, plan_id: nil)
          account = assigns(:account)
          expect(account).to_not be_nil
          expect(account).to_not be_new_record
        end
      end
    end
  end

  describe 'GET #cancel' do
    before(:each) do
      @plan = FactoryGirl.create(:plan, currency: 'USD')
      @account = FactoryGirl.create(:account, plan: @plan)
      @controller.instance_variable_set(:@current_account, @account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :cancel
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
        get :cancel
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :cancel
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
        get :cancel
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to plans' do
        get :cancel
        expect(assigns(:nav_item)).to eq 'plans'
      end

      it 'renders the cancel template' do
        get :cancel
        expect(response).to render_template('cancel')
        expect(response).to render_template('layouts/settings')
      end

      it 'assigns the account' do
        get :cancel
        account = assigns(:account)
        expect(account).to_not be_nil
        expect(account).to eq @account
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      it 'responds successfully with an HTTP 200 status code' do
        get :cancel
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to plans' do
        get :cancel
        expect(assigns(:nav_item)).to eq 'plans'
      end

      it 'renders the cancel template' do
        get :cancel
        expect(response).to render_template('cancel')
        expect(response).to render_template('layouts/settings')
      end

      it 'assigns the account' do
        get :cancel
        account = assigns(:account)
        expect(account).to_not be_nil
        expect(account).to eq @account
      end
    end
  end

  describe 'PATCH #pause' do
    before(:each) do
      @paused_plan = FactoryGirl.create(:plan, currency: 'USD')
      @plan = FactoryGirl.create(:plan, currency: 'USD', paused_plan: @paused_plan)
      @account = FactoryGirl.create(:account, plan: @plan)
      @controller.instance_variable_set(:@current_account, @account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        patch :pause
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
        patch :pause
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        patch :pause
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

      context 'is pausable' do
        it 'sets the nav_item to plans' do
          patch :pause
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it redirects to the root path' do
          patch :pause
          expect(response).to be_redirect
          expect(response).to redirect_to(root_path)
        end

        it 'sets a notice' do
          patch :pause
          expect(request.flash[:notice]).to eq 'Account paused.'
        end
      end

      context 'is not pausable' do
        before :each do
          @plan.update_attributes(paused_plan: nil)
        end

        it 'sets the nav_item to plans' do
          patch :pause
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it renders the errors/cancel template' do
          patch :pause
          expect(response).to render_template('cancel')
          expect(response).to render_template('layouts/settings')
        end

        it 'sets a notice' do
          patch :pause
          expect(request.flash[:alert]).to eq 'Unable to pause the account.'
        end

        it 'it pass an existing account' do
          patch :pause
          account = assigns(:account)
          expect(account).to_not be_nil
          expect(account).to_not be_new_record
        end
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      context 'is pausable' do
        it 'sets the nav_item to plans' do
          patch :pause
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it redirects to the root path' do
          patch :pause
          expect(response).to be_redirect
          expect(response).to redirect_to(root_path)
        end

        it 'sets a notice' do
          patch :pause
          expect(request.flash[:notice]).to eq 'Account paused.'
        end
      end

      context 'is not pausable' do
        before :each do
          @plan.update_attributes(paused_plan: nil)
        end

        it 'sets the nav_item to plans' do
          patch :pause
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it renders the errors/cancel template' do
          patch :pause
          expect(response).to render_template('cancel')
          expect(response).to render_template('layouts/settings')
        end

        it 'sets a notice' do
          patch :pause
          expect(request.flash[:alert]).to eq 'Unable to pause the account.'
        end

        it 'it pass an existing account' do
          patch :pause
          account = assigns(:account)
          expect(account).to_not be_nil
          expect(account).to_not be_new_record
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @account = FactoryGirl.create(:account)
      @controller.instance_variable_set(:@current_account, @account)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        delete :destroy, account: {cancellation_category: 'xxx',
                                   cancellation_message: 'xxx',
                                   cancellation_reason: 'xxx'}
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
        delete :destroy, account: {cancellation_category: 'xxx',
                                   cancellation_message: 'xxx',
                                   cancellation_reason: 'xxx'}
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        delete :destroy, account: {cancellation_category: 'xxx',
                                   cancellation_message: 'xxx',
                                   cancellation_reason: 'xxx'}
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
        it 'sets the nav_item to plans' do
          delete :destroy, account: {cancellation_category: 'xxx',
                                     cancellation_message: 'xxx',
                                     cancellation_reason: 'xxx'}
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it redirects to plans' do
          delete :destroy, account: {cancellation_category: 'xxx',
                                     cancellation_message: 'xxx',
                                     cancellation_reason: 'xxx'}
          expect(response).to be_redirect
          expect(response).to redirect_to(root_path)
        end

        it 'sets a notice' do
          delete :destroy, account: {cancellation_category: 'xxx',
                                     cancellation_message: 'xxx',
                                     cancellation_reason: 'xxx'}
          expect(request.flash[:notice]).to eq 'Account cancelled.'
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to plans' do
          delete :destroy, account: {cancellation_category: '', cancellation_message: '', cancellation_reason: ''}
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it renders the cancel template' do
          delete :destroy, account: {cancellation_category: '', cancellation_message: '', cancellation_reason: ''}
          expect(response).to render_template('cancel')
          expect(response).to render_template('layouts/settings')
        end

        it 'sets an alert' do
          delete :destroy, account: {cancellation_category: '', cancellation_message: '', cancellation_reason: ''}
          expect(request.flash[:alert]).to eq 'Unable to cancel the account.'
        end

        it 'it pass an existing account' do
          delete :destroy, account: {cancellation_category: '', cancellation_message: '', cancellation_reason: ''}
          account = assigns(:account)
          expect(account).to eq @account
        end
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      context 'with valid attributes' do
        it 'sets the nav_item to plans' do
          delete :destroy, account: {cancellation_category: 'xxx',
                                     cancellation_message: 'xxx',
                                     cancellation_reason: 'xxx'}
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it redirects to plans' do
          delete :destroy, account: {cancellation_category: 'xxx',
                                     cancellation_message: 'xxx',
                                     cancellation_reason: 'xxx'}
          expect(response).to be_redirect
          expect(response).to redirect_to(root_path)
        end

        it 'sets a notice' do
          delete :destroy, account: {cancellation_category: 'xxx',
                                     cancellation_message: 'xxx',
                                     cancellation_reason: 'xxx'}
          expect(request.flash[:notice]).to eq 'Account cancelled.'
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to plans' do
          delete :destroy, account: {cancellation_category: '', cancellation_message: '', cancellation_reason: ''}
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it renders the cancel template' do
          delete :destroy, account: {cancellation_category: '', cancellation_message: '', cancellation_reason: ''}
          expect(response).to render_template('cancel')
          expect(response).to render_template('layouts/settings')
        end

        it 'sets an alert' do
          delete :destroy, account: {cancellation_category: '', cancellation_message: '', cancellation_reason: ''}
          expect(request.flash[:alert]).to eq 'Unable to cancel the account.'
        end

        it 'it pass an existing account' do
          delete :destroy, account: {cancellation_category: '', cancellation_message: '', cancellation_reason: ''}
          account = assigns(:account)
          expect(account).to eq @account
        end
      end
    end
  end
end
