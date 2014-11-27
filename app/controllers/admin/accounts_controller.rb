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

# Provides acounts administration in the admin section
class Admin::AccountsController < Admin::ApplicationController
  before_action :find_account, only: [:edit,
                                      :show,
                                      :update,
                                      :cancel,
                                      :confirm_cancel,
                                      :confirm_restore,
                                      :events,
                                      :restore,
                                      :users]

  authorize_resource

  def index
    @accounts = Account.includes(:plan).page(params[:page])
  end

  def create
    @account = Account.new(accounts_params)
    @account.card_token = 'dummy'
    if @account.save
      StripeGateway.account_create(@account.id)
      AppEvent.success("Created account #{@account}", @account, current_user)
      redirect_to admin_account_path(@account),
                  notice: 'Account was successfully created.'
    else
      render 'new'
    end
  end

  def edit
  end

  def new
    @account = Account.new
  end

  def show
  end

  def update
    if @account.update_attributes(accounts_params)
      StripeGateway.account_update(@account.id)
      AppEvent.success("Updated account #{@account}", @account, current_user)
      redirect_to admin_account_path(@account),
                  notice: 'Account was successfully updated.'
    else
      render 'edit'
    end
  end

  def events
    @app_events = @account.app_events.includes(:user).page(params[:page])
  end

  def cancel
    if @account.cancel(cancel_params)
      StripeGateway.account_cancel(@account.id)
      AppEvent.info("Cancelled account #{@account}", @account, current_user)
      redirect_to admin_account_path(@account), notice: 'Account was successfully cancelled.'
    else
      @cancellation_categories = CancellationCategory.available_with_reasons
      render 'confirm_cancel', notice: 'Unable to cancel the account.'
    end
  end

  def confirm_cancel
  end

  def confirm_restore
  end

  def restore
    if @account.restore
      StripeGateway.account_restore(@account.id)
      AppEvent.success("Restored account #{@account}", @account, current_user)
      redirect_to admin_account_path(@account), notice: 'Account was successfully restored.'
    else
      render 'confirm_restore', notice: 'Unable to restore the account.'
    end
  end

  def users
    @user_permissions = @account.user_permissions.includes(:user).page(params[:page])
  end

  private

  def find_account
    if params[:account_id]
      @account = Account.find(params[:account_id])
    else
      @account = Account.find(params[:id])
    end
  end

  def cancel_params
    params.require(:account).permit(:cancellation_category_id, :cancellation_message, :cancellation_reason_id)
  end

  def accounts_params
    params.require(:account).permit(:active,
                                    :address_city,
                                    :address_country,
                                    :address_line1,
                                    :address_line2,
                                    :address_state,
                                    :address_zip,
                                    :company_name,
                                    :custom_path,
                                    :email,
                                    :expires_at,
                                    :hostname,
                                    :plan_id,
                                    :paused_plan_id,
                                    :subdomain)
  end

  def set_nav_item
    @nav_item = 'accounts'
  end
end
