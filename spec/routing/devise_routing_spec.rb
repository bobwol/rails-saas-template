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

# Tests for devise
RSpec.describe 'routing for the devise', type: :routing do
  it 'routes GET /users/login to devise/sessions#new' do
    expect(get: '/users/login').to route_to(
      controller: 'devise/sessions',
      action: 'new'
    )
  end

  it 'routes POST /users/login to devise/sessions#create' do
    expect(post: '/users/login').to route_to(
      controller: 'devise/sessions',
      action: 'create'
    )
  end

  it 'routes DELETE /users/logout to devise/sessions#destroy' do
    expect(delete: '/users/logout').to route_to(
      controller: 'devise/sessions',
      action: 'destroy'
    )
  end

  it 'routes POST /users/password to devise/passwords#create' do
    expect(post: '/users/password').to route_to(
      controller: 'devise/passwords',
      action: 'create'
    )
  end

  it 'routes GET /users/password/new to devise/passwords#new' do
    expect(get: '/users/password/new').to route_to(
      controller: 'devise/passwords',
      action: 'new'
    )
  end

  it 'routes GET /users/password/edit to devise/passwords#edit' do
    expect(get: '/users/password/edit').to route_to(
      controller: 'devise/passwords',
      action: 'edit'
    )
  end

  it 'routes PATCH /users/password to devise/passwords#update' do
    expect(patch: '/users/password').to route_to(
      controller: 'devise/passwords',
      action: 'update'
    )
  end

  it 'routes PUT /users/password to devise/passwords#update' do
    expect(put: '/users/password').to route_to(
      controller: 'devise/passwords',
      action: 'update'
    )
  end

  it 'routes GET /users/cancel to devise/registrations#cancel' do
    expect(get: '/users/cancel').to route_to(
      controller: 'devise/registrations',
      action: 'cancel'
    )
  end

  it 'routes POST /users to devise/registrations#create' do
    expect(post: '/users').to route_to(
      controller: 'devise/registrations',
      action: 'create'
    )
  end

  it 'routes GET /users/register to devise/registrations#new' do
    expect(get: '/users/register').to route_to(
      controller: 'devise/registrations',
      action: 'new'
    )
  end

  it 'routes GET /users/edit to devise/registrations#edit' do
    expect(get: '/users/edit').to route_to(
      controller: 'devise/registrations',
      action: 'edit'
    )
  end

  it 'routes PATCH /users to devise/registrations#update' do
    expect(patch: '/users').to route_to(
      controller: 'devise/registrations',
      action: 'update'
    )
  end

  it 'routes PUT /users to devise/registrations#update' do
    expect(put: '/users').to route_to(
      controller: 'devise/registrations',
      action: 'update'
    )
  end

  it 'routes DELETE /users to devise/registrations#destroy' do
    expect(delete: '/users').to route_to(
      controller: 'devise/registrations',
      action: 'destroy'
    )
  end

  it 'routes POST /users/unlock to devise/unlocks#create' do
    expect(post: '/users/unlock').to route_to(
      controller: 'devise/unlocks',
      action: 'create'
    )
  end

  it 'routes GET /users/unlock/new to devise/unlocks#new' do
    expect(get: '/users/unlock/new').to route_to(
      controller: 'devise/unlocks',
      action: 'new'
    )
  end

  it 'routes GET /users/unlock to devise/unlocks#show' do
    expect(get: '/users/unlock').to route_to(
      controller: 'devise/unlocks',
      action: 'show'
    )
  end
end
