# Encoding: utf-8

# The MIT License (MIT)
#
# Copyright (c) 2014 Richard Buggy <rich@buggy.id.au>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'rubocop/rake_task'

namespace :saas do
  namespace :dev do
    desc 'Rails Best Practices'
    task :rails_best_practices => :environment do
      path = File.expand_path('../../..', __FILE__)
      sh "rails_best_practices #{path}"
    end

    desc 'Brakeman'
    task :brakeman => :environment do
      sh "brakeman -q -z"
    end

	desc 'RuboCop'
	RuboCop::RakeTask.new

	desc 'Run all saas:dev tasks'
    task :all => [:rubocop, :brakeman, :rails_best_practices ] do
	end
  end
end