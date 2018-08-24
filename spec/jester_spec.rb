require 'spec_helper'

describe Jester do

  it 'has a version number' do
    expect(Jester::VERSION).not_to be nil
  end

  it 'has a "help" command' do
    expect { Jester::Cli.start(ARGV) }.to output(/help/).to_stdout
  end

  it 'has a "test" command' do
    expect { Jester::Cli.start(ARGV) }.to output(/test/).to_stdout
  end

  it 'has a "new" command' do
    expect { Jester::Cli.start(ARGV) }.to output(/new/).to_stdout
  end

  it 'has a "build" command' do
    expect { Jester::Cli.start(ARGV) }.to output(/build/).to_stdout
  end

  it 'has a "version" command' do
    expect { Jester::Cli.start(ARGV) }.to output(/version/).to_stdout
  end

end
