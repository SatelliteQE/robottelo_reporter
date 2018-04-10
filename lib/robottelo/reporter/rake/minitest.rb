# frozen_string_literal: true

namespace :robottelo do
  namespace :setup do
    task :minitest do
      ENV['TESTOPTS'] = "#{ENV['TESTOPTS']} --robottelo-reporter"
    end
  end
end
