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

# The users controller implements users view and editing their own profiles
class UsersController < ApplicationController
  before_action :find_user, except: [:index]

  authorize_resource

  def index
    redirect_to user_path(current_user)
  end

  def show
  end

  def edit
  end

  def update
    p = users_params
    if p[:password].blank? && p[:password_confirmation].blank?
      p.delete(:password)
      p.delete(:password_confirmation)
    end
    if @user.update_attributes(p)
      AppEvent.success("Updated user #{@user}", nil, current_user)
      redirect_to user_path(@user),
                  notice: 'User was successfully updated.'
    else
      render 'edit'
    end
  end

  def accounts
    authorize! :accounts, @user
    @user_permissions = @user.user_permissions.includes(:account).page(params[:page])
  end

  def user_invitations
    authorize! :user_invitations, @user
    @user_invitations = UserInvitation.where(email: @user.email).page(params[:page])
  end

  private

  def find_user
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      @user = User.find(params[:id])
    end
  end

  def users_params
    params.require(:user).permit(:email,
                                 :first_name,
                                 :last_name,
                                 :password,
                                 :password_confirmation)
  end
end
