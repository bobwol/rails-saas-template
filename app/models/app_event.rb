# Encoding: utf-8

# The MIT License (MIT)
#
# Copyright (c) 2014 Richard Buggy <rich@buggy.id.au>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# App Event model
class AppEvent < ActiveRecord::Base
  belongs_to :account
  belongs_to :user

  validates :account_id, numericality: { integer_only: true }, allow_nil: true
  validates :level, inclusion: { in: %w( success info warning alert ) }, presence: true
  validates :message, length: { maximum: 255 }, presence: true
  validates :user_id, numericality: { integer_only: true }, allow_nil: true

  def self.success(message, account = nil, user = nil)
    AppEvent.create(level: 'success', message: message, account: account, user: user)
  end

  def self.info(message, account = nil, user = nil)
    AppEvent.create(level: 'info', message: message, account: account, user: user)
  end

  def self.warning(message, account = nil, user = nil)
    AppEvent.create(level: 'warning', message: message, account: account, user: user)
  end

  def self.alert(message, account = nil, user = nil)
    AppEvent.create(level: 'alert', message: message, account: account, user: user)
  end
end
