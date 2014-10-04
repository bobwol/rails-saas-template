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

# Tests for settings/accounts routing
RSpec.describe 'routing for the settings accounts', type: :routing do
  it 'routes GET /path/settings to settings/accounts#home' do
    expect(get: '/path/settings').to route_to(
      controller: 'settings/accounts',
      action: 'home',
      path: 'path'
    )
  end

  it 'routes GET /path/settings/account to settings/accounts#show' do
    expect(get: '/path/settings/account').to route_to(
      controller: 'settings/accounts',
      action: 'show',
      path: 'path'
    )
  end

  it 'routes GET /path/settings/account/edit to settings/accounts#edit' do
    expect(get: '/path/settings/account/edit').to route_to(
      controller: 'settings/accounts',
      action: 'edit',
      path: 'path'
    )
  end

  it 'routes PATCH /path/settings/account to settings/accounts#update' do
    expect(patch: '/path/settings/account').to route_to(
      controller: 'settings/accounts',
      action: 'update',
      path: 'path'
    )
  end
end
