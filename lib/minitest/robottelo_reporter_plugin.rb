# frozen_string_literal: true

module Minitest
  def self.plugin_robottelo_reporter_options(opts, options)
    opts.on '-p', '--robottelo-reporter', 'Create Robottelo xml report file' do
      options[:robottelo_reporter] = true
    end
  end

  def self.plugin_robottelo_reporter_init(options)
    return unless options[:robottelo_reporter]
    require 'robottelo/reporter'
    self.reporter << Robottelo::Reporter::Runner.new
    puts 'init robottelo reporter'
  end
end
