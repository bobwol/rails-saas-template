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

# Account model
class Account < ActiveRecord::Base
  # before_validation(on: create) do |account|
  #   account.expires_at = Time.now + account.plan.trial_period_days.days if account.expires_at.nil?
  # end
  #
  # before_update do |account|
  #   if account.plan_id == account.paused_plan_id
  #     account.errors.add :paused_plan_id, 'cannot be the same as the main plan'
  #   end
  #
  #   if account.plan_id_changed?
  #     old_plan = Plan.find(account.plan_id_was)
  #     if old_plan.currency != account.plan.currency
  #       account.errors.add :plan_id, 'cannot be changed to a plan with a different currency'
  #     end
  #   end
  #
  #   account.errors.add :base, 'Too many users for that plan' if account.users.count > account.plan.max_users
  #
  #   false if account.errors.count > 0
  # end

  belongs_to :plan
  belongs_to :paused_plan, class_name: 'Plan'

  default_scope { order('company_name ASC') }

  has_many :app_events
  has_many :users, through: :user_permissions
  has_many :user_permissions

  validates :address_city, length: { maximum: 120 }
  validates :address_country, length: { maximum: 2 }
  validates :address_line1, length: { maximum: 120 }
  validates :address_line2, length: { maximum: 120 }
  validates :address_state, length: { maximum: 60 }
  validates :address_zip, length: { maximum: 20 }
  validates :cancellation_category, length: { maximum: 255 }
  validates :cancellation_category, presence: true, if: '!cancelled_at.nil?'
  validates :cancellation_message, length: { maximum: 255 }
  validates :cancellation_message, presence: true, if: '!cancelled_at.nil?'
  validates :cancellation_reason, length: { maximum: 255 }
  validates :cancellation_reason, presence: true, if: '!cancelled_at.nil?'
  validates :card_token, length: { maximum: 60 }, presence: true
  validates :company_name, length: { maximum: 255 }, presence: true
  validates :email, length: { maximum: 255 }, presence: true
  validates :expires_at, presence: true
  validates :hostname, length: { maximum: 255 }, presence: false
  validates :hostname,
            format: { with: /\A([a-z0-9]+[a-z0-9\-]*)((\.([a-z0-9]+[a-z0-9\-]*))+)\Z/i },
            uniqueness: true,
            unless: 'hostname.nil?'
  validates :paused_plan_id, numericality: { integer_only: true }, allow_nil: true
  validates :plan_id, numericality: { integer_only: true }, presence: true
  validates :stripe_customer_id, length: { maximum: 60 }
  validates :stripe_subscription_id, length: { maximum: 60 }
  validates :subdomain, length: { maximum: 64 }, presence: false
  validates :subdomain, format: { with: /\A([a-z0-9]+[a-z0-9\-]*)\Z/i }, uniqueness: true, unless: 'subdomain.nil?'

  def to_s
    company_name
  end

  def address_country_name
    c = Country[address_country]
    if c.nil?
      address_country
    else
      c.name
    end
  end

  def cancel(params)
    time = Time.new
    params[:cancelled_at] = time.strftime('%Y-%m-%d %H:%M:%S')
    params[:active] = false
    update_attributes(params)
  end

  def self.find_by_hostname(hostname)
    Account.joins(:plan).where(plans: { allow_hostname: true }, active: true, hostname: hostname).first
  end

  def self.find_by_path(path)
    Account.where(active: true, id: path).first
  end

  def self.find_by_subdomain(subdomain)
    Account.joins(:plan).where(plans: { allow_subdomain: true }, active: true, subdomain: subdomain).first
  end

  # def pause
  #   ppid = plan.paused_plan_id
  #   if ppid.nil?
  #     false
  #   else
  #     update_attributes(paused_plan_id: ppid)
  #   end
  # end

  def restore
    params = { cancellation_reason: nil,
               cancellation_message: nil,
               cancelled_at: nil,
               active: true }
    update_attributes(params)
  end

  def status
    s = :active
    s = :paused unless paused_plan_id.nil?
    s = :expired if !expires_at.nil? && expires_at < Date.today
    s = :cancel_pending unless cancelled_at.nil?
    s = :cancelled unless active
    s
  end
end
