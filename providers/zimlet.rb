include Chef::Mixin::ShellOut

def action_install
  installed

  installed.include?(new_resource.name) && return

  shell_out_zmzimletctl! %W(deploy #{new_resource.path})
  shell_out_zmprov! %w(fc zimlet)
  new_resource.updated_by_last_action true
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

def installed
  inst = []
  if exists_and_old
    inst = ::File.readlines(tmp_path).each { |l| l.chomp! }
  else
    read_zim_lines(inst)
    write_zimlet
  end
end

def exists_and_old
  ex = ::File.exist?(tmp_path)
  recent = ::File.mtime(tmp_path) < ::Time.now - 60
  return true if ex && !recent
end

def tmp_path
  "#{Chef::Config[:file_cache_path]}/zimlets/#{new_resource.name}"
end

def read_zim_lines(inst)
  installed_res = shell_out_zmzimletctl!(%w(listZimlets)).stdout
  installed_res.each_line do |line|
    next if line.include?('this host')
    break if line.include?('LDAP')
    inst << line.chomp.gsub!(/\t/, '')
  end
end

def write_zimlet
  ::File.open(tmp_path, 'w') do |f|
    f.write(installed.join("\n"))
  end
end
