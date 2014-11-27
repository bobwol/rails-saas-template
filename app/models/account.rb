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
  belongs_to :plan
  belongs_to :paused_plan, class_name: 'Plan'
  belongs_to :cancellation_category
  belongs_to :cancellation_reason

  has_many :app_events, dependent: :destroy
  has_many :users, through: :user_permissions
  has_many :user_invitations, dependent: :destroy
  has_many :user_permissions, dependent: :destroy

  delegate :currency, :allow_custom_path, :allow_hostname, :allow_subdomain, :stripe_id, to: :plan, prefix: true
  delegate :stripe_id, to: :paused_plan, prefix: true, allow_nil: true

  accepts_nested_attributes_for :users

  default_scope { order('company_name ASC') }

  before_validation do |account|
    unless account.plan.nil?
      account.custom_path = nil unless account.plan_allow_custom_path
      account.hostname = nil unless account.plan_allow_hostname
      account.subdomain = nil unless account.plan_allow_subdomain
    end
  end

  validates :active, inclusion: { in: [true, false] }, presence: false, allow_blank: false
  validates :address_city, length: { maximum: 120 }
  validates :address_country, length: { maximum: 2 }
  validates :address_line1, length: { maximum: 120 }
  validates :address_line2, length: { maximum: 120 }
  validates :address_state, length: { maximum: 60 }
  validates :address_zip, length: { maximum: 20 }
  validates :cancellation_category_id, presence: true, if: '!cancelled_at.nil?'
  validates :cancellation_message, length: { maximum: 255 }
  validates :cancellation_message, presence: true, if: :require_cancellation_message
  validates :cancellation_reason_id, presence: true, if: :require_cancellation_reason_id
  validates :card_token, length: { maximum: 60 }
  validates :card_token, presence: true, if: 'plan_id? && plan.require_card_upfront'
  validates :company_name, length: { maximum: 255 }, presence: true
  validates :custom_path, length: { in: 2..60 }, allow_nil: true
  validates :custom_path, uniqueness: true, unless: 'custom_path.nil?'
  validates :custom_path,
            format: { with: /\A[a-z0-9]+\Z/i, message: 'can only contain letters and numbers' },
            unless: 'custom_path.nil?'
  validates :custom_path,
            format: { with: /\A.*[a-z].*\Z/i, message: 'must contain at least one letter' },
            unless: 'custom_path.nil?'
  validates :email, length: { maximum: 255 }, presence: true
  validates :hostname, length: { maximum: 255 }
  validates :hostname,
            format: { with: /\A([a-z0-9]+[a-z0-9\-]*)((\.([a-z0-9]+[a-z0-9\-]*))+)\Z/i },
            uniqueness: true,
            unless: 'hostname.nil?'
  validates :paused_plan_id, numericality: { integer_only: true }, allow_nil: true
  validates :plan_id, numericality: { integer_only: true }, presence: true
  validates :stripe_customer_id, length: { maximum: 60 }
  validates :stripe_subscription_id, length: { maximum: 60 }
  validates :subdomain, length: { maximum: 64 }
  validates :subdomain,
            format: { with: /\A([a-z0-9]+[a-z0-9\-]*)\Z/i },
            uniqueness: true,
            unless: 'subdomain.nil?'
  validates_associated :users, on: :create

  def require_cancellation_reason_id
    return false if cancelled_at.nil?
    return false if cancellation_category.nil?
    return true if cancellation_category.cancellation_reasons.available.count > 0
    false
  end

  def require_cancellation_message
    return false if cancelled_at.nil?
    return true if cancellation_category_id? && cancellation_category.require_message
    return true if cancellation_reason_id? && cancellation_reason.require_message
    false
  end

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

  def self.find_account(path, host, subdomain)
    if path
      # Assume that they're using http://www.example.com/ACCOUNT
      @current_account = Account.find_by_path!(path)
    else
      # Try http://ACCOUNT/ then http://ACCOUNT.example.com/
      @current_account = Account.find_by_hostname(host)
      @current_account = Account.find_by_subdomain(subdomain) if @current_account.nil?
    end

    @current_account
  end

  def self.find_by_hostname(hostname)
    Account.joins(:plan).where(plans: { allow_hostname: true }, active: true, hostname: hostname).first
  end

  def self.find_by_path(path)
    if path.to_i.to_s == path.to_s
      Account.where(active: true, id: path).first
    else
      Account.joins(:plan).where(plans: { allow_custom_path: true }, active: true, custom_path: path).first
    end
  end

  def self.find_by_path!(path)
    account = Account.find_by_path(path)
    fail ActiveRecord::RecordNotFound if account.nil?
    account
  end

  def self.find_by_subdomain(subdomain)
    Account.joins(:plan).where(plans: { allow_subdomain: true }, active: true, subdomain: subdomain).first
  end

  def pause
    return false if plan.paused_plan_id.nil?

    update_attributes(paused_plan_id: plan.paused_plan_id)
  end

  def restore
    params = { cancellation_category: nil,
               cancellation_reason: nil,
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

  def admin_all_users
    user_permissions.each do |up|
      up.account_admin = true
      up.save
    end
  end
end
