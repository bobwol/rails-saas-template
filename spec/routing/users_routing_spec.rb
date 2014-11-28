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

# Tests for users routing
RSpec.describe 'routing for the users', type: :routing do
  it 'routes GET /users to users#index' do
    expect(get: '/users').to route_to(
      controller: 'users',
      action: 'index'
    )
  end

  it 'routes GET /users/1 to users#show' do
    expect(get: '/users/1').to route_to(
      controller: 'users',
      action: 'show',
      id: '1'
    )
  end

  it 'routes GET /users/1/accounts to users#accounts' do
    expect(get: '/users/1/accounts').to route_to(
      controller: 'users',
      action: 'accounts',
      user_id: '1'
    )
  end

  it 'routes GET /users/1/edit to users#edit' do
    expect(get: '/users/1/edit').to route_to(
      controller: 'users',
      action: 'edit',
      id: '1'
    )
  end

  it 'routes PATCH /users/1 to users#update' do
    expect(patch: '/users/1').to route_to(
      controller: 'users',
      action: 'update',
      id: '1'
    )
  end

  it 'routes GET /users/1/user_invitations to users#user_invitations' do
    expect(get: '/users/1/user_invitations').to route_to(
      controller: 'users',
      action: 'user_invitations',
      user_id: '1'
    )
  end
end
