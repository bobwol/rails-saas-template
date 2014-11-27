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

# Tests for the admin cancellation categories controller
RSpec.describe Admin::CancellationCategoriesController, type: :controller do
  describe 'POST #create' do
    context 'as anonymous user' do
      it 'redirects to login page' do
        post :create, cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not create a cancellation_category' do
        # rubocop:disable Style/Blocks
        expect {
          post :create, cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
        }.to change { CancellationCategory.count }.by(0)
        # rubocop:enable Style/Blocks
      end
    end

    context 'as unauthorized users' do
      before(:each) do
        user = FactoryGirl.create(:user)
        sign_in :user, user
      end

      it 'responds with forbidden' do
        post :create, cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        post :create, cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
        expect(response).to render_template('errors/forbidden')
        expect(response).to render_template('layouts/errors')
      end

      it 'does not create a cancellation_category' do
        # rubocop:disable Style/Blocks
        expect {
          post :create, cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
        }.to change { CancellationCategory.count }.by(0)
        # rubocop:enable Style/Blocks
      end
    end

    context 'as super admin user' do
      before(:each) do
        admin = FactoryGirl.create(:admin)
        sign_in :user, admin
      end

      context 'with valid attributes' do
        it 'sets the nav_item to cancellation_categories' do
          post :create, cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
          expect(assigns(:nav_item)).to eq 'cancellation_categories'
        end

        it 'it redirects to cancellation_category' do
          post :create, cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
          cancellation_category = assigns(:cancellation_category)
          expect(response).to be_redirect
          expect(response).to redirect_to(admin_cancellation_category_path(cancellation_category))
        end

        it 'sets a notice' do
          post :create, cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
          expect(request.flash[:notice]).to eq 'Cancellation category was successfully created.'
        end

        it 'creates a cancellation_category' do
          # rubocop:disable Style/Blocks
          expect {
            post :create, cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
          }.to change { CancellationCategory.count }.by(1)
          # rubocop:enable Style/Blocks
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to cancellation_categories' do
          post :create, cancellation_category: FactoryGirl.attributes_for(:cancellation_category, name: '')
          expect(assigns(:nav_item)).to eq 'cancellation_categories'
        end

        it 'it renders the new template' do
          post :create, cancellation_category: FactoryGirl.attributes_for(:cancellation_category, name: '')
          expect(response).to render_template('new')
          expect(response).to render_template('layouts/admin')
        end

        it 'it pass a new cancellation_category' do
          post :create, cancellation_category: FactoryGirl.attributes_for(:cancellation_category, name: '')
          cancellation_category = assigns(:cancellation_category)
          expect(cancellation_category).to_not be_nil
          expect(cancellation_category).to be_new_record
        end

        it 'does not create a cancellation_category' do
          # rubocop:disable Style/Blocks
          expect {
            post :create, cancellation_category: FactoryGirl.attributes_for(:cancellation_category, name: '')
          }.to change { CancellationCategory.count }.by(0)
          # rubocop:enable Style/Blocks
        end
      end
    end
  end

  describe 'GET #edit' do
    before(:each) do
      @cancellation_category = FactoryGirl.create(:cancellation_category)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :edit, id: @cancellation_category.id
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
        get :edit, id: @cancellation_category.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :edit, id: @cancellation_category.id
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
        get :edit, id: @cancellation_category.id
        expect(response).to be_success
        expect(response).to have_http_status(:success)
      end

      it 'sets the nav_item to cancellation_categories' do
        get :edit, id: @cancellation_category.id
        expect(assigns(:nav_item)).to eq 'cancellation_categories'
      end

      it 'renders the edit template' do
        get :edit, id: @cancellation_category.id
        expect(response).to render_template('edit')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a edit cancellation_category' do
        get :edit, id: @cancellation_category.id
        p = assigns(:cancellation_category)
        expect(p).to_not be_nil
        expect(p.id).to eq @cancellation_category.id
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

      it 'sets the nav_item to cancellation_categories' do
        get :index
        expect(assigns(:nav_item)).to eq 'cancellation_categories'
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template('index')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns cancellation_categories correctly' do
        cancellation_category = FactoryGirl.create(:cancellation_category)
        cancellation_category2 = FactoryGirl.create(:cancellation_category)

        get :index
        cancellation_categories = assigns(:cancellation_categories)
        expect(cancellation_categories).to_not be_nil
        expect(cancellation_categories.count).to eq 2
        expect(cancellation_categories).to include cancellation_category
        expect(cancellation_categories).to include cancellation_category2
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

      it 'sets the nav_item to cancellation_categories' do
        get :new
        expect(assigns(:nav_item)).to eq 'cancellation_categories'
      end

      it 'renders the new template' do
        get :new
        expect(response).to render_template('new')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a new cancellation_category' do
        get :new
        cancellation_category = assigns(:cancellation_category)
        expect(cancellation_category).to_not be_nil
        expect(cancellation_category).to be_new_record
      end
    end
  end

  describe 'GET #show' do
    before(:each) do
      @cancellation_category = FactoryGirl.create(:cancellation_category)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        get :show, id: @cancellation_category.id
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
        get :show, id: @cancellation_category.id
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        get :show, id: @cancellation_category.id
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
        get :show, id: @cancellation_category.id
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets the nav_item to cancellation_categories' do
        get :show, id: @cancellation_category.id
        expect(assigns(:nav_item)).to eq 'cancellation_categories'
      end

      it 'renders the show template' do
        get :show, id: @cancellation_category.id
        expect(response).to render_template('show')
        expect(response).to render_template('layouts/admin')
      end

      it 'assigns a show cancellation_category' do
        get :show, id: @cancellation_category.id
        p = assigns(:cancellation_category)
        expect(p).to_not be_nil
        expect(p.id).to eq @cancellation_category.id
      end
    end
  end

  describe 'PATCH #update' do
    before(:each) do
      @cancellation_category = FactoryGirl.create(:cancellation_category)
    end

    context 'as anonymous user' do
      it 'redirects to login page' do
        patch :update,
              id: @cancellation_category.id,
              cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
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
              id: @cancellation_category.id,
              cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
        expect(response).to be_forbidden
      end

      it 'renders the forbidden' do
        patch :update,
              id: @cancellation_category.id,
              cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
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
        it 'sets the nav_item to cancellation_categories' do
          patch :update,
                id: @cancellation_category.id,
                cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
          expect(assigns(:nav_item)).to eq 'cancellation_categories'
        end

        it 'it redirects to cancellation_category' do
          patch :update,
                id: @cancellation_category.id,
                cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
          cancellation_category = assigns(:cancellation_category)
          expect(response).to be_redirect
          expect(response).to redirect_to(admin_cancellation_category_path(cancellation_category))
        end

        it 'sets a notice' do
          post :update,
               id: @cancellation_category.id,
               cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
          expect(request.flash[:notice]).to eq 'Cancellation category was successfully updated.'
        end
      end

      context 'with invalid attributes' do
        it 'sets the nav_item to cancellation_categories' do
          patch :update,
                id: @cancellation_category.id,
                cancellation_category: FactoryGirl.attributes_for(:cancellation_category)
          expect(assigns(:nav_item)).to eq 'cancellation_categories'
        end

        it 'it renders the new template' do
          patch :update,
                id: @cancellation_category.id,
                cancellation_category: FactoryGirl.attributes_for(:cancellation_category, name: '')
          expect(response).to render_template('edit')
          expect(response).to render_template('layouts/admin')
        end

        it 'it pass a new cancellation_category' do
          patch :update,
                id: @cancellation_category.id,
                cancellation_category: FactoryGirl.attributes_for(:cancellation_category, name: '')
          cancellation_category = assigns(:cancellation_category)
          expect(cancellation_category).to_not be_nil
          expect(cancellation_category).to_not be_new_record
        end
      end
    end
  end
end
