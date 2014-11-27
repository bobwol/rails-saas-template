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

# Provides cancellation categories administration in the admin section
class Admin::CancellationCategoriesController < Admin::ApplicationController
  before_action :find_cancellation_category, only: [:edit, :show, :update]

  authorize_resource

  def index
    @cancellation_categories = CancellationCategory.page(params[:page])
  end

  def create
    @cancellation_category = CancellationCategory.new(cancellation_category_params)
    if @cancellation_category.save
      AppEvent.success("Created cancellation category #{@cancellation_category}", nil, current_user)
      redirect_to admin_cancellation_category_path(@cancellation_category),
                  notice: 'Cancellation category was successfully created.'
    else
      render 'new'
    end
  end

  def edit
  end

  def new
    @cancellation_category = CancellationCategory.new
  end

  def show
  end

  def update
    if @cancellation_category.update_attributes(cancellation_category_params)
      AppEvent.success("Updated cancellation category #{@cancellation_category}", nil, current_user)
      redirect_to admin_cancellation_category_path(@cancellation_category),
                  notice: 'Cancellation category was successfully updated.'
    else
      render 'edit'
    end
  end

  private

  def find_cancellation_category
    @cancellation_category = CancellationCategory.find(params[:id])
  end

  def cancellation_category_params
    params.require(:cancellation_category).permit(:active,
                                                  :allow_message,
                                                  :name,
                                                  :require_message)
  end

  def set_nav_item
    @nav_item = 'cancellation_categories'
  end
end
