---
layout: post
title: Notes on Debian package (dpkg) regarding system cleanups
date: '2017-02-27 13:14:00 +0100'
source: https://github.com/BastiTee/basti-space/blob/master/_posts/2017-02-27-dpkg-essentials.md
---

When working with Debian[^1] or Ubuntu[^2] systems, you will get in contact with Debians package manager `apt` (Advances packaging tool)[^3]. But `apt` itself is only a frontend of `dpkg` making available higher-level functions such as `autoremove` or `update`. While being the tool of choice for installing packages, `apt` tends to be rather restrictive if you want to cleanup your system, e.g., after you've tested a package temporarily. So here are some things you can do in that case with `dpkg` and `dpkg-query`.

# List, remove and purge installed packages

Using `dpkg-query` it is very easy to list all packages currently (semi-) installed on your system. Using `--showformat` we're able to control the information displayed effectively removing table headers and descriptions used by `dpkg-query` by default.

```bash
basti@home:~$ dpkg-query --show --showformat='${db:Status-Abbrev} ${binary:Package} ${Version}\n'
ii  a11y-profile-manager-indicator 0.1.10-0ubuntu3
ii  account-plugin-facebook 0.12+16.04.20160126-0ubuntu1
ii  account-plugin-flickr 0.12+16.04.20160126-0ubuntu1
ii  account-plugin-google 0.12+16.04.20160126-0ubuntu1
ii  accountsservice 0.6.40-2ubuntu11.3
rc  accountwizard 4:15.12.3-0ubuntu1
ii  acl 2.2.52-3
ii  acpi-support 0.142
ii  acpid 1:2.0.26-1ubuntu2
ii  activity-log-manager 0.9.7-0ubuntu23
```

Notice the first entry on each line. While many combinations are possible[^4], generally you will come across `ii` for installed packages, `rc` for packages that have been removed, but some (configuration) files remained and `un` for fully uninstalled packages. Even if you only use `apt`, consider the `--purge` option for `apt autoclean` and `apt remove` because most of the time you want to remove the package binaries **and** all configuration files when deleting it. Default is to remove the package binaries only. That's nice if you reinstall the package later, but maybe not what you want.

Building up on that, numerous cleanups are possible. So let's create an alias and have a look.

```bash
basti@home:~$ alias dql="dpkg-query --show --showformat='\${db:Status-Abbrev} \${binary:Package} \${Version}\n'"
```

**Count installed packages**

```bash
basti@home:~$ dql | grep -e "^ii" | wc -l
3118
```

**List all packages matching a pattern**

```bash
basti@home:~$ dql *xfce4*
un  xfce4
un  xfce4-power-manager
```

**Purge all semi-installed packages**

To remove all packages, that had been removed but not purged yet, combine the upper command with some basic linux pipes:

```bash
basti@home:~$ dql | grep -e "^rc" | awk '{print $2}' | sudo xargs dpkg -P
```

**Remove everything matching a pattern**

Be careful. This is highly automated. Make sure you set the right pattern.

```bash
basti@home:~$ dql *php*mysql* | grep -v -e "^un" | awk '{print $2}' | xargs sudo dpkg -P
```

# Show all files related to a packages

Often you want to know, where a package was installed and what files are package-relevant. That's a `dpkg-query` no-brainer.

```bash
basti@home:~$ dpkg-query -L account-plugin-facebook
/.
/usr
/usr/share
/usr/share/doc
...
/etc/signon-ui
/etc/signon-ui/webkit-options.d
/etc/signon-ui/webkit-options.d/www.facebook.com.conf
/usr/share/doc/account-plugin-facebook/changelog.Debian.gz
```

# Working with the log

As most linux tools, `dpkg` writes a log to `/var/log/dpkg.log` that can be utilized to gather some valuable information for system cleaup. For example you could list the timestamps and names of all package installations.

```bash
basti@home:~$ awk '$3~/^install$/ {print $1" "$2" "$4;}' /var/log/dpkg.log
...
2017-02-27 18:09:36 libevent-core-2.0-5:amd64
2017-02-27 18:09:36 mysql-server-5.7:amd64
2017-02-27 18:09:37 libhtml-template-perl:all
2017-02-27 18:09:37 mysql-server:all
2017-02-27 19:24:43 nano:amd64
```

This output can be piped through date parsing to find out, e.g., what packages had been installed within the last hour.

```bash
basti@home:~$ look_back_minutes=60; oldest=$( echo "$( date +%s ) - 60 * $look_back_minutes" | bc ); awk '$3~/^install$/ {print $1" "$2" "$4;}' /var/log/dpkg.log | tac | while read line; do ts=$( date --date="$( awk '{ print $1" "$2 }' <<< $line )" +%s); [ $ts -ge $oldest ] && echo $line || break; done

2017-02-27 19:24:43 nano:amd64
```

The code reads the log file reversed (`tac`) and breaks when the first entry was found, that does not suite the timing condition anymore. Disclaimer: The code above is pretty slow, so I'd be happily accept advice on optimization.

# References and further reading

[^1]: [Debian homepage](https://www.debian.org/)

[^2]: [Ubuntu homepage](https://www.ubuntu.com/)

[^4]: [dpkg-query manual](http://manpages.ubuntu.com/manpages/trusty/man1/dpkg-query.1.html)

[^3]: [apt in Wikipedia)](https://de.wikipedia.org/wiki/Advanced_Packaging_Tool)
