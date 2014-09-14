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

# Allows the account admin to manage plans in the settings
class Settings::PlansController < Settings::ApplicationController
  before_action do
    authorize!(params[:action], @account || Account)
  end

  def edit
    @plan = Plan.available.find(params[:id])
    @account.plan_id = @plan.id
  end

  def show
    if params[:currency]
      currency = params[:currency]
    else
      currency = @account.plan_currency
    end

    @plans = Plan.available_for_currency(currency)
  end

  def update
    @plan = Plan.available.find(params[:account][:plan_id])
    if @account.update_attributes(plan_id: @plan.id)
      # StripeGateway.delay.subscription_update(@account.id)
      AppEvent.success('Change to plan ' + @plan.to_s, current_account, current_user)
      redirect_to settings_plan_path, notice: 'Plan was successfully updated.'
    else
      render 'edit'
    end
  end

  def cancel
  end

  def pause
    if @account.pause
      # StripeGateway.delay.subscription_update(@account.id)
      AppEvent.warning('Paused the account', current_account, current_user)
      redirect_to root_path, notice: 'Account paused.'
    else
      flash[:alert] = 'Unable to pause the account.'
      render 'cancel'
    end
  end

  def destroy
    if @account.cancel(cancel_params)
      # StripeGateway.delay.customer_cancel(@account.id)
      AppEvent.alert('Cancelled the account', current_account, current_user)
      redirect_to root_path, notice: 'Account cancelled.'
    else
      flash[:alert] = 'Unable to cancel the account.'
      render 'cancel'
    end
  end

  private

  def set_nav_item
    @nav_item = 'plans'
  end

  def cancel_params
    params.require(:account).permit(:cancellation_category, :cancellation_message, :cancellation_reason)
  end

  def plans_params
    params.require(:account).permit(:plan_id)
  end
end
