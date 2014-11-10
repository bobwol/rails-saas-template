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

# Gateway class for Stripe so that it can be abstracted and handled via delayed
# jobs
class StripeGateway
  class << self
    def account_create(id)
      account = Account.find(id)

      data = {
        description: account.company_name,
        email: account.email,
        metadata: {
          account_id: account.id
        }
      }
      data[:card] = account.card_token if account.card_token? && account.card_token != 'dummy'
      data[:plan] = account.plan_stripe_id
      data[:plan] = account.paused_plan_stripe_id unless account.paused_plan_stripe_id.nil?
      customer = Stripe::Customer.create(data)

      subscription = customer.subscriptions.data[0]

      account.card_token = 'dummy'
      account.expires_at = Time.at(subscription.current_period_end)
      account.stripe_customer_id = customer.id
      account.stripe_subscription_id = subscription.id
      account.save!

      card = customer.cards.retrieve(customer.default_card)
      account.card_brand = card.brand
      account.card_last4 = card.last4
      account.card_exp = "#{card.exp_month}/#{card.exp_year}"
      account.save!
    end
    handle_asynchronously :account_create, priority: 50, queue: 'stripe'

    def account_update(id)
      account = Account.find(id)

      customer = Stripe::Customer.retrieve(account.stripe_customer_id)
      customer.card = account.card_token if account.card_token? && account.card_token != 'dummy'
      customer.description = account.company_name
      customer.email = account.email
      customer.save

      subscription = customer.subscriptions.retrieve(account.stripe_subscription_id)
      current_plan = account.plan_stripe_id
      current_plan = account.paused_plan_stripe_id unless account.paused_plan_stripe_id.nil?
      if subscription.plan.id != current_plan
        subscription.plan = current_plan
        subscription.save
      end

      account.card_token = 'dummy'
      account.expires_at = Time.at(subscription.current_period_end)
      account.save

      card = customer.cards.retrieve(customer.default_card)
      account.card_brand = card.brand
      account.card_last4 = card.last4
      account.card_exp = "#{card.exp_month}/#{card.exp_year}"
      account.save!
    end
    handle_asynchronously :account_update, priority: 55, queue: 'stripe'

    def account_cancel(id)
      account = Account.find(id)

      customer = Stripe::Customer.retrieve(account.stripe_customer_id)
      subscription = customer.subscriptions.retrieve(account.stripe_subscription_id)
      subscription.delete

      account.card_token = 'dummy'
      account.card_brand = nil
      account.card_last4 = nil
      account.card_exp = nil
      account.expires_at = Time.at(subscription.canceled_at)
      account.stripe_subscription_id = nil
      account.save
    end
    handle_asynchronously :account_cancel, priority: 60, queue: 'stripe'

    def account_restore(id)
      account = Account.find(id)

      customer = Stripe::Customer.retrieve(account.stripe_customer_id)
      customer.card = account.card_token if account.card_token? && account.card_token != 'dummy'
      customer.description = account.company_name
      customer.email = account.email
      customer.save

      current_plan = account.plan_stripe_id
      current_plan = account.paused_plan_stripe_id unless account.paused_plan_stripe_id.nil?
      subscription = customer.subscriptions.create(plan: current_plan)

      account.card_token = 'dummy'
      account.expires_at = Time.at(subscription.current_period_end)
      account.stripe_subscription_id = subscription.id
      account.save
    end
    handle_asynchronously :account_restore, priority: 65, queue: 'stripe'

    def plan_create(id)
      plan = Plan.find(id)
      plan.stripe_id = "plan_#{plan.id}"
      data = {
        id: plan.stripe_id,
        amount: plan.amount,
        currency: plan.currency,
        interval: plan.interval,
        interval_count: plan.interval_count,
        name: plan.name,
        trial_period_days: plan.trial_period_days
      }

      data[:statement_description] = plan.statement_description if plan.statement_description?

      Stripe::Plan.create(data)

      plan.save!
    end
    handle_asynchronously :plan_create, priority: 0, queue: 'stripe'

    def plan_delete(plan_id)
      p = Stripe::Plan.retrieve(plan_id)
      p.delete
    end
    handle_asynchronously :plan_delete, priority: 10, queue: 'stripe'

    def plan_update(id)
      plan = Plan.find(id)
      p = Stripe::Plan.retrieve(plan.stripe_id)
      p.name = plan.name
      if plan.statement_description?
        p.statement_description = plan.statement_description
      else
        p.statement_description = nil
      end
      p.save
    end
    handle_asynchronously :plan_update, priority: 5, queue: 'stripe'
  end
end
