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

# Migration to add plans model to database
class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :stripe_id, limit: 80
      t.string :name, limit: 80, null: false
      t.string :statement_description, limit: 150
      t.boolean :active, default: true, null: false
      t.boolean :public, default: true, null: false
      t.integer :paused_plan_id
      t.string :currency, limit: 3, default: 'USD', null: false
      t.integer :interval_count, default: 1, null: false
      t.string :interval, limit: 5, default: 'month', null: false
      t.integer :amount, default: 0, null: false
      t.integer :trial_period_days, default: 30, null: false
      t.integer :max_users, default: 1, null: false

      t.timestamps
    end

    add_index :plans, [:paused_plan_id], unique: false
    add_index :plans, [:stripe_id], unique: true
  end
end
