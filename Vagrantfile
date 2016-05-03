# -*- mode: ruby -*-
# vi: set ft=ruby :

# Variables
vm = {
    :hostname       => 'ubuntu-trusty-vm',
    :ip             => '192.168.33.11',
    :path_self      => '/vagrant',
}

# Functions

def which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable? exe
        }
    end
    return nil
end

def os_type
    case RbConfig::CONFIG['host_os']
        when /mac|darwin/i
            :osx
        when /linux/i
            :linux
        when /mswin|mingw|cygwin/i
            :windows
        else
            :unknown
    end
end

def os_bits
    case os_type
        when :osx
            "64"
        when :linux
            `getconf LONG_BIT`
        when :windows
            (ENV.has_key?('ProgramFiles(x86)') && File.exist?(ENV['ProgramFiles(x86)']) && File.directory?(ENV['ProgramFiles(x86)'])) ? "64" : "32"
        else
            "32"
    end
end

def cpu_total
    cores =
        case os_type
            when :osx
                `sysctl -n hw.ncpu`.to_i
            when :linux
                `nproc`.to_i
            when :windows
                require 'win32ole'
                wmi = WIN32OLE.connect('winmgmts://')
                q = wmi.ExecQuery('select NumberOfCores from Win32_Processor')
                q.to_enum.reduce(0) { |cores, processor| cores + processor.NumberOfCores }
            else
                1
        end
    [1, cores].max
end

def memory_total
    memory =
        case os_type
            when :osx
                `sysctl -n hw.memsize`.to_i / 1024 / 1024
            when :linux
                `awk '$1 == "MemTotal:" { print $2 }' /proc/meminfo`.to_i / 1024
            when :windows
                `wmic OS get TotalVisibleMemorySize | more +1`.to_i / 1024
            else
                2048
        end
    [8192, memory].min
end

def terminal
    case os_type
        when :windows
            "cygwin"
        else
            "xterm-256color"
    end
end

# Run

Vagrant.configure(2) do |config|

    # Disable setting hostname in Windows as this errors
    #config.vm.hostname = vm[:hostname]

    config.vm.define vm[:hostname] do |v|
    end

    config.vm.provider :virtualbox do |v|
        v.customize [
            "modifyvm", :id,
            #"--name", vm[:hostname],
            "--cpus", cpu_total,
            "--ioapic", "on",
            "--memory", [memory_total / 4, 512].min,
            "--natdnshostresolver1", "on",
            '--natdnsproxy1', "on",
        ]
        v.customize [
            "setextradata", :id,
            "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1",
        ]
    end

    config.vm.box = "ubuntu/trusty"+os_bits

    config.vm.network :private_network, ip: vm[:ip]

    #config.ssh.username = vm[:username]
    config.ssh.forward_agent = true
    config.ssh.insert_key = false
    
    # Provisioning
    if which('ansible-playbook')
        config.vm.provision "ansible" do |ansible|
            ansible.playbook = "ansible/playbook.yml"
            ansible.inventory_path = "ansible/inventories/dev"
            ansible.limit = 'all'
            ansible.hostname = vm[:hostname]
            ansible.extra_vars = {
                private_interface: vm[:ip],
                term: 'xterm-256color',
            }
        end
    else
        config.vm.provision :shell, path: "ansible/bin/init.sh", args: [vm[:path_self], vm[:hostname], vm[:ip], terminal], privileged: false
    end
    config.vm.provision :shell, path: "ansible/bin/all.sh", run: "always", privileged: false

    # Synced folders
    config.vm.synced_folder "./", "/vagrant", disabled: true
    config.vm.synced_folder "./", vm[:path_self], type: "nfs", mount_options: ['nolock,vers=3,udp,noatime,actimeo=1']
    
end
