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

# Plan model
class Plan < ActiveRecord::Base
  has_many :accounts
  has_many :paused_accounts, class_name: 'Account', foreign_key: :paused_plan_id
  has_many :paused_plans, class_name: 'Plan', foreign_key: :paused_plan_id

  before_update do |plan|
    plan.errors.add :paused_plan_id, 'cannot use a plan as its own paused plan' if plan.id == plan.paused_plan_id
    plan.errors.add :currency, 'cannot change the currency' if plan.currency_changed?
    plan.errors.add :interval_count, 'cannot change the interval count' if plan.interval_count_changed?
    plan.errors.add :interval, 'cannot change the interval' if plan.interval_changed?
    plan.errors.add :amount, 'cannot change the amount' if plan.amount_changed?
    plan.errors.add :trial_period_days, 'cannot change the trial period days' if plan.trial_period_days_changed?

    false if plan.errors.count > 0
  end

  # before_destroy do |plan|
  #   # It should be self evident why deleting a plan with accounts using it is a
  #   # bad thing
  #   if plan.accounts.count > 0 || plan.paused_accounts.count > 0 || plan.paused_plans.count > 0
  #     plan.errors.add :base, 'You cannot remove a plan that is in use'
  #   end
  #
  #   false if plan.errors.count > 0
  # end

  belongs_to :paused_plan, class_name: 'Plan'

  # default_scope { order('name ASC, amount ASC') }
  scope :available,
        lambda {
          where('active = ? AND public = ? AND stripe_id IS NOT NULL', true, true)
            .order('amount DESC, name ASC')
        }
  # scope :available_for_currency,
  #       lambda { |for_currency|
  #         where('active = ? AND public = ? AND currency = ? AND stripe_id IS NOT NULL',
  #               true,
  #               true,
  #               for_currency).order('amount DESC, name ASC')
  #       }

  validates :amount,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, integer_only: true }
  validates :currency,
            inclusion: { in: %w( AUD CAD EUR GBP NZD USD ) },
            presence: true
  validates :interval,
            inclusion: { in: %w( day week month year ) },
            presence: true
  validates :interval_count,
            presence: true,
            numericality: { greater_than_or_equal_to: 1, integer_only: true }
  validates :max_users,
            presence: true,
            numericality: { greater_than_or_equal_to: 1, integer_only: true }
  validates :name, length: { maximum: 150 }, presence: true
  validates :statement_description, length: { maximum: 150 }
  validates :stripe_id, length: { maximum: 80 }
  validates :trial_period_days,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, integer_only: true }

  def to_s
    name
  end
end
