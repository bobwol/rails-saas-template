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

# Specs in this file have access to a helper object that includes
# the ApplicationHelper. For example:
#
# describe ApplicationHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ApplicationHelper, type: :helper do
  describe '#render_heading' do
    before(:each) do
      @title = nil
      @heading = nil
      @subheading = nil
    end

    context 'when there is no heading, subheading or title' do
      it 'uses the default' do
        expect(helper.render_heading).to eq '<h1 class="page-header">Rails-SaaS-Template</h1>'
      end
    end

    context 'when there is a title but no heading or subheading' do
      it 'uses the title' do
        @title = '>Title'
        expect(helper.render_heading).to eq '<h1 class="page-header">&gt;Title</h1>'
      end
    end

    context 'when there is a heading but no subheading or title' do
      it 'uses the heading' do
        @heading = '>Heading'
        expect(helper.render_heading).to eq '<h1 class="page-header">&gt;Heading</h1>'
      end
    end

    context 'when there is a title and heading but no subheading' do
      it 'uses the heading' do
        @title = '>Title'
        @heading = '>Heading'
        expect(helper.render_heading).to eq '<h1 class="page-header">&gt;Heading</h1>'
      end
    end

    context 'when there is a subheading but no heading or title' do
      it 'uses the default' do
        @subheading = '>Subheading'
        expect(helper.render_heading).to eq '<h1 class="page-header">Rails-SaaS-Template <small>&gt;Subheading</small></h1>'
      end
    end

    context 'when there is a title and subheading but no heading' do
      it 'uses the title' do
        @title = '>Title'
        @subheading = '>Subheading'
        expect(helper.render_heading).to eq '<h1 class="page-header">&gt;Title <small>&gt;Subheading</small></h1>'
      end
    end

    context 'when there is a heading and subheading but no title' do
      it 'uses the heading' do
        @heading = '>Heading'
        @subheading = '>Subheading'
        expect(helper.render_heading).to eq '<h1 class="page-header">&gt;Heading <small>&gt;Subheading</small></h1>'
      end
    end

    context 'when there is a title, heading and subheading' do
      it 'uses the heading' do
        @title = '>Title'
        @heading = '>Heading'
        @subheading = '>Subheading'
        expect(helper.render_heading).to eq '<h1 class="page-header">&gt;Heading <small>&gt;Subheading</small></h1>'
      end
    end
  end

  describe '#render_title' do
    before(:each) do
      @title = nil
      @heading = nil
      @subheading = nil
    end

    context 'when there is no heading, subheading or title' do
      it 'uses the default' do
        expect(helper.render_title).to eq 'Rails-SaaS-Template'
      end
    end

    context 'when there is a title but no heading or subheading' do
      it 'uses the title' do
        @title = '>Title'
        expect(helper.render_title).to eq '&gt;Title | Rails-SaaS-Template'
      end
    end

    context 'when there is a heading but no subheading or title' do
      it 'uses the heading' do
        @heading = '>Heading'
        expect(helper.render_title).to eq '&gt;Heading | Rails-SaaS-Template'
      end
    end

    context 'when there is a title and heading but no subheading' do
      it 'uses the title' do
        @title = '>Title'
        @heading = '>Heading'
        expect(helper.render_title).to eq '&gt;Title | Rails-SaaS-Template'
      end
    end
  end

  describe '#render_errors' do
    before(:each) do
      @user = User.new
    end

    context "no errors" do
      it 'displays nothing' do
        expect(helper.render_errors(@user)).to eq ''
      end
    end

    context "one error" do
      it 'displays one error' do
        @user.errors.add :base, '>Something'
        expect(helper.render_errors(@user)).to eq '<div class="alert alert-danger">&gt;Something</div>'
      end
    end

    context "multiple errors" do
      it 'displays multiple errors' do
        @user.errors.add :base, '>Something'
        @user.errors.add :base, '>Something else'
        expect(helper.render_errors(@user)).to eq '<div class="alert alert-danger">&gt;Something</div><div class="alert alert-danger">&gt;Something else</div>'
      end
    end
  end
end
