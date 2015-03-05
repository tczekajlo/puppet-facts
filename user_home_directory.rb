#A facter fact to determine the user home directory.
#Usage: ex. $::home_root

require 'etc'

Etc.passwd { |user|
	Facter.add("home_#{user.name}") do
		setcode do
			user.dir
		end
	end
}
# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
