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

# Base class for all application controllers
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Make sure the user is authenticated by default
  before_action :authenticate_user!

  # Lock down the controllers with cancancan
  check_authorization

  # Handle when access is denied by cancancan
  # TODO: Missing RSpec test
  rescue_from CanCan::AccessDenied do
    render 'errors/forbidden', layout: 'errors', status: :forbidden
  end

  # Handle when we can't find a record
  # TODO: Missing RSpec test
  rescue_from ActiveRecord::RecordNotFound do
    render 'errors/not_found', layout: 'errors', status: :not_found
  end

  # Handle every other errror
  # TODO: Missing RSpec test
  rescue_from RuntimeError do
    render 'errors/internal_error', layout: 'errors', status: :internal_server_error
  end

  # Return the ability model. It needs to know about the user and the account.
  def current_ability
    Ability.new(current_user, current_account, :none)
  end

  # This makes sure we retain the :path value for routes that require it
  def url_options
    if params[:path]
      { path: params[:path] }.merge(super)
    else
      super
    end
  end

  # Find the current account, returning it or nil if there is no current account
  def current_account
    @current_account ||= Account.find_account(params[:path], request.host, request.subdomain.last)
  end
end
