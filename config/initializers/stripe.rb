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

Stripe.api_key = ENV['STRIPE_API_KEY']

# StripeEvent.configure do |events|
#
#   events.subscribe 'account.application.deauthorized' do |event|
#     # I don't really care about this object but I do want to log it as an alert
#     LogEvent.create(level: 'alert',
#                     message: "Account application deauthorized [STRIPE: #{event.id}]")
#   end
#
#   events.subscribe 'charge.succeeded' do |event|
#     StripeGateway.delay.charge_event(event.id)
#   end
#
#   events.subscribe 'charge.failed' do |event|
#     StripeGateway.delay.charge_event(event.id)
#   end
#
#   events.subscribe 'charge.refunded' do |event|
#     StripeGateway.delay.charge_event(event.id)
#   end
#
#   events.subscribe 'charge.captured' do |event|
#     StripeGateway.delay.charge_event(event.id)
#   end
#
#   events.subscribe 'charge.updated' do |event|
#     StripeGateway.delay.charge_event(event.id)
#   end
#
#   events.subscribe 'charge.dispute.created' do |event|
#     StripeGateway.delay.dispute_event(event.id)
#   end
#
#   events.subscribe 'charge.dispute.updated' do |event|
#     StripeGateway.delay.dispute_event(event.id)
#   end
#
#   events.subscribe 'charge.dispute.closed' do |event|
#     StripeGateway.delay.dispute_event(event.id)
#   end
#
#   # Are we really handling a surprise delete correctly?
#   events.subscribe 'customer.deleted' do |event|
#     StripeGateway.delay.customer_event(event.id)
#   end
#
#   # Should I have code here to cancel an account?
#   events.subscribe 'customer.subscription.deleted' do |event|
#     StripeGateway.delay.subscription_event(event.id)
#   end
#
#   # This should really trigger a trial ending email?
#   events.subscribe 'customer.subscription.trial_will_end' do |event|
#     StripeGateway.delay.subscription_event(event.id)
#   end
#
#   events.subscribe 'invoice.created' do |event|
#     StripeGateway.delay.invoice_event(event.id)
#   end
#
#   events.subscribe 'invoice.updated' do |event|
#     StripeGateway.delay.invoice_event(event.id)
#   end
#
#   events.subscribe 'invoice.payment_succeeded' do |event|
#     StripeGateway.delay.invoice_event(event.id)
#   end
#
#   events.subscribe 'invoice.payment_failed' do |event|
#     StripeGateway.delay.invoice_event(event.id)
#   end
#
#   events.subscribe 'invoiceitem.created' do |event|
#     StripeGateway.delay.invoiceitem_event(event.id)
#   end
#
#   events.subscribe 'invoiceitem.updated' do |event|
#     StripeGateway.delay.invoiceitem_event(event.id)
#   end
#
#   events.subscribe 'invoiceitem.deleted' do |event|
#     StripeGateway.delay.invoiceitem_event(event.id)
#   end
#
#   events.all do |event|
#     LogEvent.create(level: 'success',
#                     message: "Stripe event #{event.type} [STRIPE: ##{event.id}]")
#   end
# end
