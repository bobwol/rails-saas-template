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

# Tests for customized Devise
RSpec.describe 'routing for the customize Devise controllers', type: :routing do
  it 'routes GET /users/login to users/sessions#new' do
    expect(get: '/users/login').to route_to(
      controller: 'users/sessions',
      action: 'new'
    )
  end

  it 'routes POST /users/login to users/sessions#create' do
    expect(post: '/users/login').to route_to(
      controller: 'users/sessions',
      action: 'create'
    )
  end

  it 'routes DELETE /users/logout to users/sessions#destroy' do
    expect(delete: '/users/logout').to route_to(
      controller: 'users/sessions',
      action: 'destroy'
    )
  end

  it 'routes POST /users/password to users/passwords#create' do
    expect(post: '/users/password').to route_to(
      controller: 'users/passwords',
      action: 'create'
    )
  end

  it 'routes GET /users/password/new to users/passwords#new' do
    expect(get: '/users/password/new').to route_to(
      controller: 'users/passwords',
      action: 'new'
    )
  end

  it 'routes GET /users/password/edit to users/passwords#edit' do
    expect(get: '/users/password/edit').to route_to(
      controller: 'users/passwords',
      action: 'edit'
    )
  end

  it 'routes PATCH /users/password to users/passwords#update' do
    expect(patch: '/users/password').to route_to(
      controller: 'users/passwords',
      action: 'update'
    )
  end

  it 'routes PUT /users/password to users/passwords#update' do
    expect(put: '/users/password').to route_to(
      controller: 'users/passwords',
      action: 'update'
    )
  end

  it 'routes GET /users/cancel to users/registrations#cancel' do
    expect(get: '/users/cancel').to route_to(
      controller: 'users/registrations',
      action: 'cancel'
    )
  end

  it 'routes POST /users to users/registrations#create' do
    expect(post: '/users').to route_to(
      controller: 'users/registrations',
      action: 'create'
    )
  end

  it 'routes GET /users/register to users/registrations#new' do
    expect(get: '/users/register').to route_to(
      controller: 'users/registrations',
      action: 'new'
    )
  end

  it 'routes GET /users/edit to users/registrations#edit' do
    expect(get: '/users/edit').to route_to(
      controller: 'users/registrations',
      action: 'edit'
    )
  end

  it 'routes PATCH /users to users/registrations#update' do
    expect(patch: '/users').to route_to(
      controller: 'users/registrations',
      action: 'update'
    )
  end

  it 'routes PUT /users to users/registrations#update' do
    expect(put: '/users').to route_to(
      controller: 'users/registrations',
      action: 'update'
    )
  end

  it 'routes DELETE /users to users/registrations#destroy' do
    expect(delete: '/users').to route_to(
      controller: 'users/registrations',
      action: 'destroy'
    )
  end

  it 'routes POST /users/unlock to users/unlocks#create' do
    expect(post: '/users/unlock').to route_to(
      controller: 'users/unlocks',
      action: 'create'
    )
  end

  it 'routes GET /users/unlock/new to users/unlocks#new' do
    expect(get: '/users/unlock/new').to route_to(
      controller: 'users/unlocks',
      action: 'new'
    )
  end

  it 'routes GET /users/unlock to users/unlocks#show' do
    expect(get: '/users/unlock').to route_to(
      controller: 'users/unlocks',
      action: 'show'
    )
  end
end
