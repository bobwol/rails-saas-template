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

# The Marketing controller implements all of the marketing pages
class MarketingController < ApplicationController
  # Skip authentication and authorization for the marketing controller.
  # We want anonymous users to be able to access it.
  skip_before_action :authenticate_user!
  skip_authorization_check

  layout 'marketing'

  def index
    render layout: false
  end

  def pricing
    currency = params[:currency] || 'USD'
    @plans = Plan.available_for_currency(currency)
  end

  # rubocop:disable Metrics/CyclomaticComplexity, PerceivedComplexity
  def register
    @plan = Plan.available.where(id: params[:account][:plan_id]).first

    return redirect_to pricing_path, alert: 'Invalid plan.' if @plan.nil?

    @account = Account.new(accounts_params, active: true)

    # Set the email from the current_user or the first user
    if user_signed_in? && (@account.users.count == 0)
      @account.email = current_user.email
    else
      @account.email = @account.users[0].email unless @account.users[0].nil?
    end

    if @account.save
      # Add the current_user as an account admin or set all users as an account admin
      if user_signed_in? && (@account.user_permissions.count == 0)
        @account.user_permissions.build(user: current_user, account_admin: true)
      else
        @account.admin_all_users
      end

      StripeGateway.account_create(@account.id)
      AppEvent.success("Created account #{@account}", @account, nil)
      redirect_to new_user_session_path,
                  notice: 'Success. Please log in to continue.'
    else
      render 'signup'
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, PerceivedComplexity

  def signup
    @plan = Plan.available.where(id: params[:plan_id]).first
    if @plan.nil?
      redirect_to pricing_path, alert: 'Invalid plan.'
    else
      @account = Account.new(plan: @plan,
                             address_country: 'us')
      @account.users.build
    end
  end

  private

  def accounts_params
    params.require(:account).permit(:address_city,
                                    :address_country,
                                    :address_line1,
                                    :address_line2,
                                    :address_state,
                                    :address_zip,
                                    :company_name,
                                    :plan_id,
                                    :card_token,
                                    users_attributes: [:first_name,
                                                       :last_name,
                                                       :email,
                                                       :password,
                                                       :password_confirmation])
  end
end
