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

# Customize the Devise registrations controller
class Users::RegistrationsController < Devise::RegistrationsController
  # Don't require authorization for Devise controllers
  skip_authorization_check

  before_action :find_invitation

  def create
    if @user_invitation
      super do |resource|
        if resource.errors.count == 0
          UserMailer.welcome(resource).deliver
          user_permission = @user_invitation.account.user_permissions.build(user: resource)
          if user_permission.save
            AppEvent.success("New user #{resource} for #{@account}", @account, nil)
          else
            AppEvent.alert("New user #{resource} for #{@account} but permission not created", @account, nil)
          end
          @user_invitation.destroy
        end
      end
    else
      resource = User.new(sign_up_params)
      resource.errors.add(:base, 'Missing invite code') unless params[:invite_code]
    end
  end

  def new
    @user = User.new

    return unless @user_invitation

    @user.first_name = @user_invitation.first_name
    @user.last_name = @user_invitation.last_name
    @user.email = @user_invitation.email
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation, :current_password)
  end

  def find_invitation
    @user_invitation = nil
    @invite_code = ''

    return unless params[:invite_code]

    @invite_code = params[:invite_code]
    @user_invitation = UserInvitation.where(invite_code: @invite_code).first
    @user.errors.add(:base, 'Invalid invite code') unless @user_invitation
  end
end
