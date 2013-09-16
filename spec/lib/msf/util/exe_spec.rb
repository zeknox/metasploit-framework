# -*- coding:binary -*-

require 'msf/core'
require 'msf/base/simple'
require 'spec_helper'

require 'support/shared/contexts/msf/util/exe'

describe Msf::Util::EXE do

  subject do
    described_class
  end

  $framework = Msf::Simple::Framework.create(
    :module_types => [ Msf::MODULE_NOP ],
    'DisableDatabase' => true
  )

  describe '.win32_rwx_exec' do
    it "should contain the shellcode" do
      bin = subject.win32_rwx_exec("asdfjklASDFJKL")
      bin.should include("asdfjklASDFJKL")
    end
  end

  describe '.to_executable_fmt' do
    it "should output nil when given a bogus format" do
      bin = subject.to_executable_fmt($framework, "", "", "", "does not exist", {})

      bin.should == nil
    end

    include_context 'Msf::Util::Exe'

    @platform_format_map.each do |plat, formats|
      context "with platform=#{plat}" do
        let(:platform) do
          Msf::Module::PlatformList.transform(plat)
        end

        it "should output nil when given bogus format" do
          bin = subject.to_executable_fmt($framework, formats.first[:arch], platform, "\xcc", "asdf", {})
          bin.should == nil
        end
        it "should output nil when given bogus arch" do
          bin = subject.to_executable_fmt($framework, "asdf", platform, "\xcc", formats.first[:format], {})
          bin.should == nil
        end
        [ ARCH_X86, ARCH_X64, ARCH_X86_64, ARCH_PPC, ARCH_MIPSLE, ARCH_MIPSBE, ARCH_ARMLE ].each do |arch|
          it "returns nil when given bogus format for arch=#{arch}" do
            bin = subject.to_executable_fmt($framework, arch, platform, "\xcc", "asdf", {})
          end
        end

        formats.each do |format_hash|
          fmt   = format_hash[:format]
          arch  = format_hash[:arch]

          if format_hash[:pending]
            pending "returns an executable when given arch=#{arch}, fmt=#{fmt}"
            next
          end

          it "returns an executable when given arch=#{arch}, fmt=#{fmt}" do
            bin = subject.to_executable_fmt($framework, arch, platform, "\xcc", fmt, {})
            bin.should be_a String

            verify_bin_fingerprint(format_hash, bin)
          end

        end

      end
    end

  end

end

