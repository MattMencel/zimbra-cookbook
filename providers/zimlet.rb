include Chef::Mixin::ShellOut

def action_install
  info_path = "#{Chef::Config[:file_cache_path]}/zimlets"
  ::Dir.mkdir(info_path) unless Dir.exist?(info_path)
  write_zimlet_info if !zimlet_info_exists? || zimlet_info_old?

  return unless read_zimlet_info == 'NO_SUCH_ZIMLET'
  shell_out_zmzimletctl! %W(deploy #{new_resource.path})
  shell_out_zmprov! %w(fc zimlet)
  new_resource.updated_by_last_action true
  write_zimlet_info
end

protected

def shell_out_zmzimletctl!(cmd, opts = {})
  ctl = '/opt/zimbra/bin/zmzimletctl'
  cmd.unshift ctl
  opts.update user: 'zimbra'
  shell_out!(cmd, opts)
end

def shell_out_zmprov!(cmd, opts = {})
  ctl = '/opt/zimbra/bin/zmprov'
  cmd.unshift ctl
  opts.update user: 'zimbra'
  shell_out!(cmd, opts)
end

# def installed?
#   if exists && old
#     inst = ::File.readlines(tmp_path).each { |l| l.chomp! }
#   else
#     read_zim_lines(inst)
#     write_zimlet
#   end
# end

def zimlet_info_exists?
  ex = ::File.exist?(tmp_path)
  return true if ex
end

def zimlet_info_old?
  return true unless ::File.mtime(tmp_path) < ::Time.now - 2_592_000
end

def tmp_path
  "#{Chef::Config[:file_cache_path]}/zimlets/#{new_resource.name}"
end

def read_zimlet_info
  ::File.open(tmp_path).each_line do |line|
    return 'NO_SUCH_ZIMLET' if line.include?('NO_SUCH_ZIMLET')
    return 'ENABLED' if line.include?('Enabled: true')
  end
  'UNKNOWN STATUS'
end

def write_zimlet_info
  ::File.open(tmp_path, 'w') do |f|
    f.write(shell_out_zmzimletctl! %W(info #{new_resource.name}))
  end
end
