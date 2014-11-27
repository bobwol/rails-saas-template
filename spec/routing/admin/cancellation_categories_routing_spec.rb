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
  it 'routes GET /admin/cancellation_categories to admin/cancellation_categories#index' do
    expect(get: '/admin/cancellation_categories').to route_to(
      controller: 'admin/cancellation_categories',
      action: 'index'
    )
  end

  it 'routes GET /admin/cancellation_categories/1 to admin/cancellation_categories#show' do
    expect(get: '/admin/cancellation_categories/1').to route_to(
      controller: 'admin/cancellation_categories',
      action: 'show',
      id: '1'
    )
  end

  it 'routes GET /admin/cancellation_categories/1/edit to admin/cancellation_categories#edit' do
    expect(get: '/admin/cancellation_categories/1/edit').to route_to(
      controller: 'admin/cancellation_categories',
      action: 'edit',
      id: '1'
    )
  end

  it 'routes GET /admin/cancellation_categories/new to admin/cancellation_categories#new' do
    expect(get: '/admin/cancellation_categories/new').to route_to(
      controller: 'admin/cancellation_categories',
      action: 'new'
    )
  end

  it 'routes PATCH /admin/cancellation_categories/1 to admin/cancellation_categories#update' do
    expect(patch: '/admin/cancellation_categories/1').to route_to(
      controller: 'admin/cancellation_categories',
      action: 'update',
      id: '1'
    )
  end

  it 'routes POST /admin/cancellation_categories to admin/cancellation_categories#create' do
    expect(post: '/admin/cancellation_categories').to route_to(
      controller: 'admin/cancellation_categories',
      action: 'create'
    )
  end
end
