# frozen_string_literal: true

require 'spec_helper'

describe Ptimelog::Command::Base do
  it 'does not enforce the need for timelog-entries by default' do
    expect(subject.needs_entries?).to be false
  end

  it 'does not allocate an unneeded hash by default' do
    expect(subject.instance_variable_get('@entries')).to be_nil
  end

  it 'pulls the general configuration' do
    expect(subject.instance_variable_get('@config')).to be_a Ptimelog::Configuration
  end

  it 'demands #run' do
    sut = Class.new(described_class).new

    expect { sut.run }.to raise_error(RuntimeError)
  end

  context 'if subclasses need entries, it' do
    let(:subject_class) do
      Class.new(described_class) do
        def needs_entries?
          true
        end
      end
    end

    it 'demands #entries=' do
      expect { subject_class.new }.to raise_error(RuntimeError)
    end

    it 'prepares an entries hash' do
      subject_class.class_eval do
        attr_writer :entries
      end

      expect(subject_class.new.instance_variable_get('@entries')).to be_a Hash
    end
  end
end
