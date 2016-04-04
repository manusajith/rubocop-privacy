# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::Debugger do
  subject(:cop) { described_class.new }

  include_examples 'debugger', 'debugger', 'debugger'
  include_examples 'debugger', 'byebug', 'byebug'
  include_examples 'debugger', 'pry binding', %w(binding.pry binding.remote_pry
                                                 binding.pry_remote)
  include_examples 'debugger',
                   'capybara debug method', %w(save_and_open_page
                                               save_and_open_screenshot
                                               save_screenshot)
  include_examples 'debugger', 'debugger with an argument', 'debugger foo'
  include_examples 'debugger', 'byebug with an argument', 'byebug foo'
  include_examples 'debugger',
                   'pry binding with an argument', ['binding.pry foo',
                                                    'binding.remote_pry foo',
                                                    'binding.pry_remote foo']
  include_examples 'debugger',
                   'capybara debug method with an argument',
                   ['save_and_open_page foo',
                    'save_and_open_screenshot foo',
                    'save_screenshot foo']
  include_examples 'non-debugger', 'a non-pry binding', 'binding.pirate'

  ALL_COMMANDS = %w(debugger byebug pry remote_pry pry_remote
                    save_and_open_page save_and_open_screenshot
                    save_screenshot).freeze

  ALL_COMMANDS.each do |src|
    include_examples 'non-debugger', "a #{src} in comments", "# #{src}"
    include_examples 'non-debugger', "a #{src} method", "code.#{src}"
  end

  it 'reports an offense for a Pry.rescue call' do
    inspect_source(cop, ['def method',
                         '  Pry.rescue { puts 1 }',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Remove debugger entry point `Pry.rescue`.'])
  end

  it 'can autocorrect Pry.rescue' do
    new_source = autocorrect_source(cop, ['def method',
                                          '  Pry.rescue { puts 1 }',
                                          'end'])
    expect(new_source).to eq(['def method',
                              '  puts 1',
                              'end'].join("\n"))
  end
end
