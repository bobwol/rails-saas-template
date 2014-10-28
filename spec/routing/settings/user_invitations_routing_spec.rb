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

# Tests for settings/user_invitations routing
RSpec.describe 'routing for the admin user invitations', type: :routing do
  it 'routes GET /path/settings/user_invitations to settings/user_invitations#index' do
    expect(get: '/path/settings/user_invitations').to route_to(
      controller: 'settings/user_invitations',
      action: 'index',
      path: 'path'
    )
  end

  it 'routes GET /path/settings/user_invitations/1 to settings/user_invitations#show' do
    expect(get: '/path/settings/user_invitations/1').to route_to(
      controller: 'settings/user_invitations',
      action: 'show',
      id: '1',
      path: 'path'
    )
  end

  it 'routes GET /path/settings/user_invitations/1/edit to settings/user_invitations#edit' do
    expect(get: '/path/settings/user_invitations/1/edit').to route_to(
      controller: 'settings/user_invitations',
      action: 'edit',
      id: '1',
      path: 'path'
    )
  end

  it 'routes GET /path/settings/user_invitations/new to settings/user_invitations#new' do
    expect(get: '/path/settings/user_invitations/new').to route_to(
      controller: 'settings/user_invitations',
      action: 'new',
      path: 'path'
    )
  end

  it 'routes PATCH /path/settings/user_invitations/1 to admin/user_invitations#update' do
    expect(patch: '/path/settings/user_invitations/1').to route_to(
      controller: 'settings/user_invitations',
      action: 'update',
      id: '1',
      path: 'path'
    )
  end

  it 'routes POST /path/settings/user_invitations to admin/user_invitations#create' do
    expect(post: '/path/settings/user_invitations').to route_to(
      controller: 'settings/user_invitations',
      action: 'create',
      path: 'path'
    )
  end
end
