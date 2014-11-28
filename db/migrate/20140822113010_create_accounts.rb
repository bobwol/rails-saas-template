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

# Migration to add accounts model to database
class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :company_name, limit: 255, null: false
      t.string :email, limit: 255, null: false
      t.references :plan, null: false
      t.references :paused_plan
      t.boolean :active, default: true, null: false
      t.string :address_line1, limit: 120
      t.string :address_line2, limit: 120
      t.string :address_city, limit: 120
      t.string :address_zip, limit: 20
      t.string :address_state, limit: 60
      t.string :address_country, limit: 2
      t.string :card_token, limit: 60
      t.string :stripe_customer_id, limit: 60
      t.string :stripe_subscription_id, limit: 60
      t.string :cancellation_category
      t.string :cancellation_reason
      t.string :cancellation_message
      t.datetime :cancelled_at
      t.datetime :expires_at
      t.timestamps
    end

    add_index :accounts, [:email], unique: false
    add_index :accounts, [:paused_plan_id], unique: false
    add_index :accounts, [:plan_id], unique: false
    add_index :accounts, [:stripe_customer_id], unique: true
    add_index :accounts, [:stripe_subscription_id], unique: true
  end
end
