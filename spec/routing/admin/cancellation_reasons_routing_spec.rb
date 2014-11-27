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

require 'rails_helper'

# Tests for admin/cancellation_categories routing
RSpec.describe 'routing for the admin accounts', type: :routing do
  it 'routes GET /admin/cancellation_categories/1/cancellation_reasons to admin/cancellation_reasons#index' do
    expect(get: '/admin/cancellation_categories/1/cancellation_reasons').to route_to(
      controller: 'admin/cancellation_reasons',
      action: 'index',
      cancellation_category_id: '1'
    )
  end

  it 'routes GET /admin/cancellation_categories/1/cancellation_reasons/2 to admin/cancellation_reasons#show' do
    expect(get: '/admin/cancellation_categories/1/cancellation_reasons/2').to route_to(
      controller: 'admin/cancellation_reasons',
      action: 'show',
      cancellation_category_id: '1',
      id: '2'
    )
  end

  it 'routes GET /admin/cancellation_categories/1/cancellation_reasons/2/edit to admin/cancellation_reasons#edit' do
    expect(get: '/admin/cancellation_categories/1/cancellation_reasons/2/edit').to route_to(
      controller: 'admin/cancellation_reasons',
      action: 'edit',
      cancellation_category_id: '1',
      id: '2'
    )
  end

  it 'routes GET /admin/cancellation_categories/1/cancellation_reasons/new to admin/cancellation_reasons#new' do
    expect(get: '/admin/cancellation_categories/1/cancellation_reasons/new').to route_to(
      controller: 'admin/cancellation_reasons',
      action: 'new',
      cancellation_category_id: '1'
    )
  end

  it 'routes PATCH /admin/cancellation_categories/1/cancellation_reasons/2 to admin/cancellation_reasons#update' do
    expect(patch: '/admin/cancellation_categories/1/cancellation_reasons/2').to route_to(
      controller: 'admin/cancellation_reasons',
      action: 'update',
      cancellation_category_id: '1',
      id: '2'
    )
  end

  it 'routes POST /admin/cancellation_categories/1/cancellation_reasons to admin/cancellation_reasons#create' do
    expect(post: '/admin/cancellation_categories/1/cancellation_reasons').to route_to(
      controller: 'admin/cancellation_reasons',
      action: 'create',
      cancellation_category_id: '1'
    )
  end
end
