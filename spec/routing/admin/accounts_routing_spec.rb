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

# Tests for admin/accounts routing
RSpec.describe 'routing for the admin accounts', type: :routing do
  it 'routes GET /admin/accounts to admin/accounts#index' do
    expect(get: '/admin/accounts').to route_to(
      controller: 'admin/accounts',
      action: 'index'
    )
  end

  it 'routes GET /admin/accounts/1 to admin/accounts#show' do
    expect(get: '/admin/accounts/1').to route_to(
      controller: 'admin/accounts',
      action: 'show',
      id: '1'
    )
  end

  it 'routes GET /admin/accounts/1/cancel to admin/accounts#confirm_cancel' do
    expect(get: '/admin/accounts/1/cancel').to route_to(
      controller: 'admin/accounts',
      action: 'confirm_cancel',
      account_id: '1'
    )
  end

  it 'routes GET /admin/accounts/1/edit to admin/accounts#edit' do
    expect(get: '/admin/accounts/1/edit').to route_to(
      controller: 'admin/accounts',
      action: 'edit',
      id: '1'
    )
  end

  it 'routes GET /admin/accounts/1/restore to admin/accounts#confirm_restore' do
    expect(get: '/admin/accounts/1/restore').to route_to(
      controller: 'admin/accounts',
      action: 'confirm_restore',
      account_id: '1'
    )
  end

  it 'routes GET /admin/accounts/1/users to admin/accounts#users' do
    expect(get: '/admin/accounts/1/users').to route_to(
      controller: 'admin/accounts',
      action: 'users',
      account_id: '1'
    )
  end

  it 'routes GET /admin/accounts/new to admin/accounts#new' do
    expect(get: '/admin/accounts/new').to route_to(
      controller: 'admin/accounts',
      action: 'new'
    )
  end

  it 'routes PATCH /admin/accounts/1 to admin/accounts#update' do
    expect(patch: '/admin/accounts/1').to route_to(
      controller: 'admin/accounts',
      action: 'update',
      id: '1'
    )
  end

  it 'routes PATCH /admin/accounts/1/cancel to admin/accounts#cancel' do
    expect(patch: '/admin/accounts/1/cancel').to route_to(
      controller: 'admin/accounts',
      action: 'cancel',
      account_id: '1'
    )
  end

  it 'routes PATCH /admin/accounts/1/restore to admin/accounts#restore' do
    expect(patch: '/admin/accounts/1/restore').to route_to(
      controller: 'admin/accounts',
      action: 'restore',
      account_id: '1'
    )
  end

  it 'routes POST /admin/accounts to admin/accounts#create' do
    expect(post: '/admin/accounts').to route_to(
      controller: 'admin/accounts',
      action: 'create'
    )
  end
end
