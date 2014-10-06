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

# Tests for admin/user_invitations routing
RSpec.describe 'routing for the admin user invitations', type: :routing do
  it 'routes GET /admin/user_invitations to admin/user_invitations#index' do
    expect(get: '/admin/user_invitations').to route_to(
      controller: 'admin/user_invitations',
      action: 'index'
    )
  end

  it 'routes GET /admin/accounts/2/user_invitations to admin/user_invitations#index' do
    expect(get: '/admin/accounts/2/user_invitations').to route_to(
      controller: 'admin/user_invitations',
      action: 'index',
      account_id: '2'
    )
  end

  it 'routes GET /admin/accounts/2/user_invitations/1 to admin/user_invitations#show' do
    expect(get: '/admin/accounts/2/user_invitations/1').to route_to(
      controller: 'admin/user_invitations',
      action: 'show',
      id: '1',
      account_id: '2'
    )
  end

  it 'routes GET /admin/accounts/2/user_invitations/1/edit to admin/user_invitations#edit' do
    expect(get: '/admin/accounts/2/user_invitations/1/edit').to route_to(
      controller: 'admin/user_invitations',
      action: 'edit',
      id: '1',
      account_id: '2'
    )
  end

  it 'routes GET /admin/accounts/2/user_invitations/new to admin/user_invitations#new' do
    expect(get: '/admin/accounts/2/user_invitations/new').to route_to(
      controller: 'admin/user_invitations',
      action: 'new',
      account_id: '2'
    )
  end

  it 'routes PATCH /admin/accounts/2/user_invitations/1 to admin/user_invitations#update' do
    expect(patch: '/admin/accounts/2/user_invitations/1').to route_to(
      controller: 'admin/user_invitations',
      action: 'update',
      id: '1',
      account_id: '2'
    )
  end

  it 'routes POST /admin/accounts/2/user_invitations to admin/user_invitations#create' do
    expect(post: '/admin/accounts/2/user_invitations').to route_to(
      controller: 'admin/user_invitations',
      action: 'create',
      account_id: '2'
    )
  end
end
