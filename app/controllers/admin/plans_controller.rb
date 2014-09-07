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

# Provides plans administration in the admin section
class Admin::PlansController < Admin::ApplicationController
  before_action :find_plan, only: [:account,
                                   :destroy,
                                   :edit,
                                   :show,
                                   :update,
                                   :accounts,
                                   :paused_plans]

  authorize_resource

  def index
    @plans = Plan.page(params[:page])
  end

  def accounts
    @accounts = Account.where('plan_id = ? or paused_plan_id = ?', @plan.id, @plan.id).page(params[:page])
  end

  def create
    @plan = Plan.new(plans_create_params)
    if @plan.save
      # StripeGateway.delay.plan_create(@plan.id)
      AppEvent.success("Created plan #{@plan}", nil, current_user)
      redirect_to admin_plan_path(@plan),
                  notice: 'Plan was successfully created.'
    else
      render 'new'
    end
  end

  def edit
  end

  def new
    @plan = Plan.new
  end

  def show
  end

  def update
    if @plan.update_attributes(plans_update_params)
      # StripeGateway.delay.plan_update(@plan.id)
      AppEvent.success("Updated plan #{@plan}", nil, current_user)
      redirect_to admin_plan_path(@plan),
                  notice: 'Plan was successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    if @plan.destroy
      # StripeGateway.delay.plan_delete(@plan.stripe_id)
      AppEvent.info("Deleted plan #{@plan}", nil, current_user)
      redirect_to admin_plans_path,
                  notice: 'Plan was successfully removed.'
    else
      redirect_to admin_plan_path(@plan),
                  alert: 'Plan could not be removed.'
    end
  end

  private

  def find_plan
    if params[:plan_id]
      @plan = Plan.find(params[:plan_id])
    else
      @plan = Plan.find(params[:id])
    end
  end

  def plans_create_params
    params.require(:plan).permit(:active,
                                 :amount,
                                 :currency,
                                 :interval,
                                 :interval_count,
                                 :name,
                                 :paused_plan_id,
                                 :public,
                                 :max_users,
                                 :allow_hostname,
                                 :allow_subdomain,
                                 :statement_description,
                                 :trial_period_days)
  end

  def plans_update_params
    params.require(:plan).permit(:active,
                                 :name,
                                 :paused_plan_id,
                                 :public,
                                 :max_users,
                                 :allow_hostname,
                                 :allow_subdomain,
                                 :statement_description)
  end

  def set_nav_item
    @nav_item = 'plans'
  end
end
