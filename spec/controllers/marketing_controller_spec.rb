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

# Tests for the marketing controller
RSpec.describe MarketingController, type: :controller do
  # Requesting http://www.[your-domain]/ should show the marketing homepage
  describe 'GET #index' do
    it 'responds successfully with an HTTP 200 status code' do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET #pricing' do
    before :each do
      @usd_plan0 = FactoryGirl.create(:plan, currency: 'USD')
      @usd_plan1 = FactoryGirl.create(:plan, currency: 'USD')
      @usd_plan2 = FactoryGirl.create(:plan, currency: 'USD')
      @aud_plan0 = FactoryGirl.create(:plan, currency: 'AUD')
      @aud_plan1 = FactoryGirl.create(:plan, currency: 'AUD')
      @aud_plan2 = FactoryGirl.create(:plan, currency: 'AUD')
    end

    it 'responds successfully with an HTTP 200 status code' do
      get :pricing
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the pricing template' do
      get :pricing
      expect(response).to render_template('marketing')
      expect(response).to render_template('pricing')
    end

    context 'without a currency' do
      it 'returns USD plans' do
        get :pricing
        plans = assigns(:plans)
        expect(plans).to_not be_nil
        expect(plans.count).to eq 3
        expect(plans).to include @usd_plan0
        expect(plans).to include @usd_plan1
        expect(plans).to include @usd_plan2
      end
    end

    context 'with a currency' do
      it 'returns AUD plans' do
        get :pricing, currency: 'AUD'
        plans = assigns(:plans)
        expect(plans).to_not be_nil
        expect(plans.count).to eq 3
        expect(plans).to include @aud_plan0
        expect(plans).to include @aud_plan1
        expect(plans).to include @aud_plan2
      end
    end
  end

  describe 'GET #signup' do
    context 'valid plan_id' do
      before :each do
        plan = FactoryGirl.create(:plan, currency: 'USD')
        get :signup, plan_id: plan.id
      end

      it 'responds successfully with an HTTP 200 status code' do
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'renders the signup template' do
        expect(response).to render_template('marketing')
        expect(response).to render_template('signup')
      end

      it 'assigns an account' do
        account = assigns(:account)
        expect(account).to_not be_nil
        expect(account).to be_new_record
      end
    end

    context 'without a valid plan_id' do
      before :each do
        get :signup, plan_id: 0
      end

      it 'to redirect to the pricing page' do
        expect(response).to be_redirect
        expect(response).to redirect_to(pricing_path)
      end

      it 'sets a alert' do
        expect(request.flash[:alert]).to eq 'Invalid plan.'
      end
    end
  end

  describe 'POST #register' do
    context 'without a valid plan_id' do
      it 'to redirect to the pricing page' do
        post :register, account: FactoryGirl.attributes_for(:account, plan_id: 0)
        expect(response).to be_redirect
        expect(response).to redirect_to(pricing_path)
      end

      it 'sets a alert' do
        post :register, account: FactoryGirl.attributes_for(:account, plan_id: 0)
        expect(request.flash[:alert]).to eq 'Invalid plan.'
      end

      it 'does not create an account' do
        expect{
          post :register, account: FactoryGirl.attributes_for(:account, plan_id: 0)
        }.to change{Account.count}.by(0)
      end
    end

    context 'there is an error' do
      before :each do
        @plan = FactoryGirl.create(:plan)
      end

      it 'responds successfully with an HTTP 200 status code' do
        post :register, account: FactoryGirl.attributes_for(:account, plan_id: @plan.id)
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'renders the signup form' do
        post :register, account: FactoryGirl.attributes_for(:account, plan_id: @plan.id)
        expect(response).to render_template('marketing')
        expect(response).to render_template('signup')
      end

      it 'assigns an account' do
        post :register, account: FactoryGirl.attributes_for(:account, plan_id: @plan.id)
        expect(assigns(:account)).to_not be_nil
      end

      it 'does not create an account' do
        expect{
          post :register, account: FactoryGirl.attributes_for(:account, plan_id: @plan.id)
        }.to change{Account.count}.by(0)
      end
    end

    context 'with a logged in user' do
      before :each do
        @user = FactoryGirl.create(:user)
        sign_in :user, @user
        @plan = FactoryGirl.create(:plan)
      end

      it 'to redirect to the pricing page' do
        post :register, account: { address_city: 'address_city',
                                   address_country: 'AU',
                                   address_line1: 'address_line1',
                                   address_line2: 'address_line2',
                                   address_state: 'address_state',
                                   address_zip: 'zipcode',
                                   company_name: 'company_name',
                                   plan_id: @plan.id,
                                   card_token: 'tok_abc' }
        expect(response).to be_redirect
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'sets a notice' do
        post :register, account: { address_city: 'address_city',
                                   address_country: 'AU',
                                   address_line1: 'address_line1',
                                   address_line2: 'address_line2',
                                   address_state: 'address_state',
                                   address_zip: 'zipcode',
                                   company_name: 'company_name',
                                   plan_id: @plan.id,
                                   card_token: 'tok_abc' }
        expect(request.flash[:notice]).to eq 'Success. Please log in to continue.'
      end

      it 'creates an account' do
        expect{
          post :register, account: { address_city: 'address_city',
                                     address_country: 'AU',
                                     address_line1: 'address_line1',
                                     address_line2: 'address_line2',
                                     address_state: 'address_state',
                                     address_zip: 'zipcode',
                                     company_name: 'company_name',
                                     plan_id: @plan.id,
                                     card_token: 'tok_abc' }
        }.to change{Account.count}.by(1)
      end

      it 'it does not create a new user' do
        expect{
          post :register, account: { address_city: 'address_city',
                                     address_country: 'AU',
                                     address_line1: 'address_line1',
                                     address_line2: 'address_line2',
                                     address_state: 'address_state',
                                     address_zip: 'zipcode',
                                     company_name: 'company_name',
                                     plan_id: @plan.id,
                                     card_token: 'tok_abc' }
        }.to change{User.count}.by(0)
      end

      it 'makes the user an account admin' do
        post :register, account: { address_city: 'address_city',
                                   address_country: 'AU',
                                   address_line1: 'address_line1',
                                   address_line2: 'address_line2',
                                   address_state: 'address_state',
                                   address_zip: 'zipcode',
                                   company_name: 'company_name',
                                   plan_id: @plan.id,
                                   card_token: 'tok_abc' }
        account = assigns(:account)
        expect(account).to_not be_nil
        expect(account.user_permissions[0]).to_not be_nil
        expect(account.user_permissions[0].user).to eq @user
      end
    end

    context 'without a logged in user' do
      context 'and no user provided ' do
        before :each do
          @plan = FactoryGirl.create(:plan)
          @user_count = User.count
        end

        it 'responds successfully with an HTTP 200 status code' do
          post :register, account: { address_city: 'address_city',
                                     address_country: 'AU',
                                     address_line1: 'address_line1',
                                     address_line2: 'address_line2',
                                     address_state: 'address_state',
                                     address_zip: 'zipcode',
                                     company_name: 'company_name',
                                     plan_id: @plan.id,
                                     card_token: 'tok_abc' }
          expect(response).to be_success
          expect(response).to have_http_status(200)
        end

        it 'renders the signup form' do
          post :register, account: { address_city: 'address_city',
                                     address_country: 'AU',
                                     address_line1: 'address_line1',
                                     address_line2: 'address_line2',
                                     address_state: 'address_state',
                                     address_zip: 'zipcode',
                                     company_name: 'company_name',
                                     plan_id: @plan.id,
                                     card_token: 'tok_abc' }
          expect(response).to render_template('marketing')
          expect(response).to render_template('signup')
        end

        it 'assigns an account' do
          post :register, account: { address_city: 'address_city',
                                     address_country: 'AU',
                                     address_line1: 'address_line1',
                                     address_line2: 'address_line2',
                                     address_state: 'address_state',
                                     address_zip: 'zipcode',
                                     company_name: 'company_name',
                                     plan_id: @plan.id,
                                     card_token: 'tok_abc' }
          expect(assigns(:account)).to_not be_nil
        end
      end

      context 'and invalid user provided ' do
        before :each do
          @plan = FactoryGirl.create(:plan)
        end

        it 'responds successfully with an HTTP 200 status code' do
          post :register, account: { address_city: 'address_city',
                                     address_country: 'AU',
                                     address_line1: 'address_line1',
                                     address_line2: 'address_line2',
                                     address_state: 'address_state',
                                     address_zip: 'zipcode',
                                     company_name: 'company_name',
                                     plan_id: @plan.id,
                                     card_token: 'tok_abc',
                                     user_attributes: [{
                                       first_name: '',
                                       last_name: '',
                                       email: '',
                                       password: '',
                                       password_confirmation: '' }]
                                   }
          expect(response).to be_success
          expect(response).to have_http_status(200)
        end

        it 'renders the signup form' do
          post :register, account: { address_city: 'address_city',
                                     address_country: 'AU',
                                     address_line1: 'address_line1',
                                     address_line2: 'address_line2',
                                     address_state: 'address_state',
                                     address_zip: 'zipcode',
                                     company_name: 'company_name',
                                     plan_id: @plan.id,
                                     card_token: 'tok_abc',
                                     user_attributes: [{
                                       first_name: '',
                                       last_name: '',
                                       email: '',
                                       password: '',
                                       password_confirmation: '' }]
                                   }
          expect(response).to render_template('marketing')
          expect(response).to render_template('signup')
        end

        it 'assigns an account' do
          post :register, account: { address_city: 'address_city',
                                     address_country: 'AU',
                                     address_line1: 'address_line1',
                                     address_line2: 'address_line2',
                                     address_state: 'address_state',
                                     address_zip: 'zipcode',
                                     company_name: 'company_name',
                                     plan_id: @plan.id,
                                     card_token: 'tok_abc',
                                     user_attributes: [{
                                       first_name: '',
                                       last_name: '',
                                       email: '',
                                       password: '',
                                       password_confirmation: '' }]
                                   }
          expect(assigns(:account)).to_not be_nil
        end
      end

      context 'and a valid user provided ' do
        before :each do
          @plan = FactoryGirl.create(:plan)
        end

        it 'to redirect to the pricing page' do
          post :register, account: { address_city: 'address_city',
                                     address_country: 'AU',
                                     address_line1: 'address_line1',
                                     address_line2: 'address_line2',
                                     address_state: 'address_state',
                                     address_zip: 'zipcode',
                                     company_name: 'company_name',
                                     plan_id: @plan.id,
                                     card_token: 'tok_abc',
                                     users_attributes: [{
                                       first_name: 'John',
                                       last_name: 'Smith',
                                       email: 'john@example.com',
                                       password: 'abcd1234',
                                       password_confirmation: 'abcd1234'
                                     }]
                                   }
          expect(response).to be_redirect
          expect(response).to redirect_to(new_user_session_path)
        end

        it 'sets a notice' do
          post :register, account: { address_city: 'address_city',
                                     address_country: 'AU',
                                     address_line1: 'address_line1',
                                     address_line2: 'address_line2',
                                     address_state: 'address_state',
                                     address_zip: 'zipcode',
                                     company_name: 'company_name',
                                     plan_id: @plan.id,
                                     card_token: 'tok_abc',
                                     users_attributes: [{
                                       first_name: 'John',
                                       last_name: 'Smith',
                                       email: 'john@example.com',
                                       password: 'abcd1234',
                                       password_confirmation: 'abcd1234'
                                     }]
                                   }
          expect(request.flash[:notice]).to eq 'Success. Please log in to continue.'
        end

        it 'creates an account' do
          expect{
            post :register, account: { address_city: 'address_city',
                                       address_country: 'AU',
                                       address_line1: 'address_line1',
                                       address_line2: 'address_line2',
                                       address_state: 'address_state',
                                       address_zip: 'zipcode',
                                       company_name: 'company_name',
                                       plan_id: @plan.id,
                                       card_token: 'tok_abc',
                                       users_attributes: [{
                                         first_name: 'John',
                                         last_name: 'Smith',
                                         email: 'john@example.com',
                                         password: 'abcd1234',
                                         password_confirmation: 'abcd1234'
                                       }]
                                     }
          }.to change{Account.count}.by(1)
        end

        it 'it does not create a new user' do
          expect{
            post :register, account: { address_city: 'address_city',
                                       address_country: 'AU',
                                       address_line1: 'address_line1',
                                       address_line2: 'address_line2',
                                       address_state: 'address_state',
                                       address_zip: 'zipcode',
                                       company_name: 'company_name',
                                       plan_id: @plan.id,
                                       card_token: 'tok_abc',
                                       users_attributes: [{
                                         first_name: 'John',
                                         last_name: 'Smith',
                                         email: 'john@example.com',
                                         password: 'abcd1234',
                                         password_confirmation: 'abcd1234'
                                       }]
                                     }
          }.to change{User.count}.by(1)
        end

        it 'makes the user an account admin' do
          post :register, account: { address_city: 'address_city',
                                     address_country: 'AU',
                                     address_line1: 'address_line1',
                                     address_line2: 'address_line2',
                                     address_state: 'address_state',
                                     address_zip: 'zipcode',
                                     company_name: 'company_name',
                                     plan_id: @plan.id,
                                     card_token: 'tok_abc',
                                     users_attributes: [{
                                       first_name: 'John',
                                       last_name: 'Smith',
                                       email: 'john@example.com',
                                       password: 'abcd1234',
                                       password_confirmation: 'abcd1234'
                                     }]
                                   }
          account = Account.find(assigns(:account).id)
          expect(account.user_permissions.count).to be >= 1
          account.user_permissions.each do |up|
            expect(up.account_admin).to eq true
          end
        end
      end
    end
  end
end
