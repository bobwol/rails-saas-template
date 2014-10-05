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

# Tests for the admin plans controller
RSpec.describe Admin::PlansController, type: :controller do
  describe 'POST #create' do
    context 'as anonymous user' do
      it 'redirects to login page' do
        post :create, plan: FactoryGirl.attributes_for(:plan)
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not create a plan' do
        expect { post :create, plan: FactoryGirl.attributes_for(:plan) }.to change { Plan.count }.by(0)
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        post :create, plan: FactoryGirl.attributes_for(:plan)
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        post :create, plan: FactoryGirl.attributes_for(:plan)
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end

      it 'does not create a plan' do
        expect { post :create, plan: FactoryGirl.attributes_for(:plan) }.to change { Plan.count }.by(0)
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      context 'with valid attributes' do
        it 'sets the nav_item to plans' do
          post :create, plan: FactoryGirl.attributes_for(:plan)
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it redirects to plan' do
          post :create, plan: FactoryGirl.attributes_for(:plan)
          plan = assigns(:plan)
          expect(response).to be_redirect
          expect(response).to redirect_to(admin_plan_path(plan))
        end

        it 'sets a notice' do
          post :create, plan: FactoryGirl.attributes_for(:plan)
          expect(request.flash[:notice]).to eq 'Plan was successfully created.'
        end

        it 'creates a plan' do
          expect { post :create, plan: FactoryGirl.attributes_for(:plan) }.to change { Plan.count }.by(1)
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to plans' do
          post :create, plan: FactoryGirl.attributes_for(:plan, name: '')
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it renders the new template' do
          post :create, plan: FactoryGirl.attributes_for(:plan, name: '')
          expect(response).to render_template('new')
          expect(response).to render_template('layouts/admin')
        end

        it 'it pass a new plan' do
          post :create, plan: FactoryGirl.attributes_for(:plan, name: '')
          plan = assigns(:plan)
          expect(plan).to_not be_nil
          expect(plan).to be_new_record
        end

        it 'does not create a plan' do
          expect { post :create, plan: FactoryGirl.attributes_for(:plan, name: '') }.to change { Plan.count }.by(0)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @plan = FactoryGirl.create(:plan)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        delete :destroy, id: @plan.id
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not remove a plan' do
        expect { delete :destroy, id: @plan.id }.to change { Plan.count }.by(0)
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in :user, @user
      end

      it 'responds with forbidden' do
        delete :destroy, id: @plan.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        delete :destroy, id: @plan.id
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end

      it 'does not remove a plan' do
        expect { delete :destroy, id: @plan.id }.to change { Plan.count }.by(0)
      end
    end

    context 'as super admin user' do
      before(:each) do
        @admin = FactoryGirl.create(:admin)
        sign_in :user, @admin
      end

      it 'it redirects to users' do
        delete :destroy, id: @plan.id
        expect(response).to be_redirect
        expect(response).to redirect_to(admin_plans_path)
      end

      it 'sets a notice' do
        delete :destroy, id: @plan.id
        expect(request.flash[:notice]).to eq 'Plan was successfully removed.'
      end

      it 'removes a plan' do
        expect { delete :destroy, id: @plan.id }.to change { Plan.count }.by(-1)
      end
    end
  end

  describe 'GET #accounts' do
    before :each do
      @plan = FactoryGirl.create(:plan)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :accounts, plan_id: @plan.id
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
        get :accounts, plan_id: @plan.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :accounts, plan_id: @plan.id
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
        get :accounts, plan_id: @plan.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to plans' do
        get :accounts, plan_id: @plan.id
        expect(assigns(:nav_item)).to eq 'plans'
      end

      it 'renders the accounts template' do
        get :accounts, plan_id: @plan.id
        expect(response).to render_template('accounts')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns plans correctly' do
        account1 = FactoryGirl.create(:account, plan: @plan)
        account2 = FactoryGirl.create(:account, paused_plan: @plan)

        get :accounts, plan_id: @plan.id
        accounts = assigns(:accounts)
        expect(accounts).to_not be_nil
        expect(accounts.count).to eq 2
        expect(accounts).to include account1
        expect(accounts).to include account2
      end
    end
  end

  describe 'GET #edit' do
    before(:each) do
      @plan = FactoryGirl.create(:plan)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :edit, id: @plan.id
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
        get :edit, id: @plan.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :edit, id: @plan.id
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
        get :edit, id: @plan.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'sets the nav_item to plans' do
        get :edit, id: @plan.id
        expect(assigns(:nav_item)).to eq 'plans'
      end

      it 'renders the edit template' do
        get :edit, id: @plan.id
        expect(response).to render_template('edit')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a edit plan' do
        get :edit, id: @plan.id
        p = assigns(:plan)
        expect(p).to_not be_nil
        expect(p.id).to eq @plan.id
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

      it 'sets the nav_item to plans' do
        get :index
        expect(assigns(:nav_item)).to eq 'plans'
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template('index')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns plans correctly' do
        plan = FactoryGirl.create(:plan)
        plan2 = FactoryGirl.create(:plan, name: 'Plan2', stripe_id: 'plan_2')

        get :index
        plans = assigns(:plans)
        expect(plans).to_not be_nil
        expect(plans.count).to eq 2
        expect(plans).to include plan
        expect(plans).to include plan2
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

      it 'sets the nav_item to plans' do
        get :new
        expect(assigns(:nav_item)).to eq 'plans'
      end

      it 'renders the new template' do
        get :new
        expect(response).to render_template('new')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a new plan' do
        get :new
        plan = assigns(:plan)
        expect(plan).to_not be_nil
        expect(plan).to be_new_record
      end
    end
  end

  describe 'GET #show' do
    before(:each) do
      @plan = FactoryGirl.create(:plan)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :show, id: @plan.id
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
        get :show, id: @plan.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :show, id: @plan.id
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
        get :show, id: @plan.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to plans' do
        get :show, id: @plan.id
        expect(assigns(:nav_item)).to eq 'plans'
      end

      it 'renders the show template' do
        get :show, id: @plan.id
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a show plan' do
        get :show, id: @plan.id
        p = assigns(:plan)
        expect(p).to_not be_nil
        expect(p.id).to eq @plan.id
      end
    end
  end

  describe 'PATCH #update' do
    before(:each) do
      @plan = FactoryGirl.create(:plan)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        patch :update, id: @plan.id, plan: FactoryGirl.attributes_for(:plan)
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
        patch :update, id: @plan.id, plan: FactoryGirl.attributes_for(:plan)
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        patch :update, id: @plan.id, plan: FactoryGirl.attributes_for(:plan)
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
        it 'sets the nav_item to plans' do
          patch :update, id: @plan.id, plan: FactoryGirl.attributes_for(:plan)
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it redirects to plan' do
          patch :update, id: @plan.id, plan: FactoryGirl.attributes_for(:plan)
          plan = assigns(:plan)
          expect(response).to be_redirect
          expect(response).to redirect_to(admin_plan_path(plan))
        end

        it 'sets a notice' do
          post :update, id: @plan.id, plan: FactoryGirl.attributes_for(:plan)
          expect(request.flash[:notice]).to eq 'Plan was successfully updated.'
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to plans' do
          patch :update, id: @plan.id, plan: FactoryGirl.attributes_for(:plan)
          expect(assigns(:nav_item)).to eq 'plans'
        end

        it 'it renders the new template' do
          patch :update, id: @plan.id, plan: FactoryGirl.attributes_for(:plan, name: '')
          expect(response).to render_template('edit')
          expect(response).to render_template('layouts/admin')
        end

        it 'it pass a new plan' do
          patch :update, id: @plan.id, plan: FactoryGirl.attributes_for(:plan, name: '')
          plan = assigns(:plan)
          expect(plan).to_not be_nil
          expect(plan).to_not be_new_record
        end
      end
    end
  end
end
