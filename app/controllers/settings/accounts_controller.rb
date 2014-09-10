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

# Allows the account admin to manage account details in the settings
class Settings::AccountsController < Settings::ApplicationController
  authorize_resource

  def edit
  end

  def show
  end

  def update
    if @account.update_attributes(accounts_params)
      # StripeGateway.delay.customer_update(@account.id)
      AppEvent.success('Updated account details', current_account, current_user)
      redirect_to settings_account_path, notice: 'Account was successfully updated.'
    else
      render 'edit'
    end
  end

  private

  def set_nav_item
    @nav_item = 'accounts'
  end

  def accounts_params
    params.require(:account).permit(:address_city,
                                    :address_country,
                                    :address_line1,
                                    :address_line2,
                                    :address_state,
                                    :address_zip,
                                    :company_name,
                                    :email,
                                    :hostname,
                                    :subdomain)
  end
end
