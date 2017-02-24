---
layout: post
title:  "An XMPP CLI environment with ejabberd & profanity"
date:   2017-02-20 22:34:49 +0100
twitter: https://twitter.com/basti_tee/status/834104983842852865
source:  https://github.com/BastiTee/localhost/blob/master/_posts/2017-02-20-setup-xmpp-on-cmdline.md
---

Over the past week I spend some time on investigating and learning how to setup an XMPP[^1] (or "Jabber") environment for secure messaging via command-line. Word on the street was, it'll be a pain and frustrating and, yes, partly I have to agree, but given that one is working with a more or less recent and commonly used system the frustration is manageable :)

# Prerequisite

For my setup and the descriptions below I used

- an Ubuntu-Linux based system, specifically Ubuntu Server 16.04.2 LTS (Xenial)
- a FQDN[^2] (`my.fqdn` in this tutorial) so we don't have to mess around with IPs (optional)

# Server-side with ejabberd

For the server-side I used ejabberd[^3], mainly because it's widly-used, open-source and used by the Jabber foundation[^4]. Installing ejabberd is pretty straight-forward and requires close to no configuration at all.

```bash
basti@home:~$ sudo apt-get install ejabberd -y
basti@home:~$ sudo dpkg-reconfigure ejabberd
```

The latter will setup ejabberd with a pretty solid default configuration. Make sure to use your FQDN during installation and to select a good password for your admin account. Now we should setup two users to test if the server works according to our expectations. ejabberd provides a powerful CLI `ejabberdctl` that can be used to configure the server while it's running.

```bash
basti@home:~$ sudo service ejabberd restart
basti@home:~$ sudo ejabberdctl register alice my.fqdn !strongPass123
basti@home:~$ sudo ejabberdctl register bob my.fqdn 123strongPass!
```

This will give us two users alice@my.fqdn and bob@my.fqdn. For the server to work from another machine, you need to make sure that the following ports are open for TCP and UDP connections.

- `5222` Client inbound
- `5269` Server in-/outbound

You can inspect the server's current state using systemd control.

```bash
basti@home:~$ sudo service ejabberd status
● ejabberd.service - A distributed, fault-tolerant Jabber/XMPP serve
   Loaded: loaded (/lib/systemd/system/ejabberd.service; enabled; vendor preset: enabled)
   Active: active (running) since So 2017-02-19 20:50:52 CET; 1 day 20h ago
  Process: 1299 ExecStart=/usr/sbin/ejabberdctl start (code=exited, status=0/SUCCESS)
 Main PID: 1356 (beam.smp)
...
```

By default, ejabberd will be started with an user of the same name, that has privilege to access the shell.

```bash
basti@home:~$ cat /etc/passwd
ejabberd:x:117:125::/var/lib/ejabberd:/bin/sh
```

So regarding security it does not hurt to take away that privileges.

```bash
basti@home:~$ sudo usermod -s /usr/sbin/nologin ejabberd
```

This can be reverted by running..

```bash
basti@home:~$ sudo usermod -s /bin/sh ejabberd
```

# Client-side with profanity

My tool of choice here has to be profanity[^5]. It's a clean, fully-featured and very usable (as in "usable for CLI-friends").

```bash
basti@home:~$ sudo apt-get install profanity -y
```

## Basic messaging

After starting profanity both users can login using the `connect`-command.

```bash
$ /connect alice@my.fqdn
19:11:00 - Connecting as alice@my.fqdn
19:11:00 - alice@my.fqdn logged in successfully, online (priority 0).
```

By default Alice and Bob are not able to see each other, but can still exchange messages. To start a chat Alice could execute..

```bash
$ /msg bob@my.fqdn
```

Both users will see a display indicating an unencrypted session with an offline user.

```bash
alice@my.fqdn/profanity [offline] [unencrypted]
```

To see if the other contact is online, one has to add the contact to the roster and then request a subscription.

```bash
$ /roster add bob@my.fqdn
19:16:24 - Roster item added: bob@my.fqdn
$ /sub request bob@my.fqdn
19:16:55 - Sent subscription request to alice@my.fqdn.
```

In this case Alice requested the subscription and Bob must reply..

```bash
19:18:05 - Received authorization request from alice@my.fqdn
19:18:05 - *alice@my.fqdn Authorization request, type '/sub allow' to accept or '/sub deny' to reject
$ /sub allow
```

Finally for the sake of simplicity Alice sets a nickname for Bob's full Jabber ID.

```bash
$ /roster nick bob@my.fqdn bob
19:21:10 - Nickname for bob@my.fqdn set to: bob.
```

## Off-the-Record messaging

Off-the-record messaging[^6] (OTR) is an easy-to-use encryption mechanism supported by most XMPP clients. In contrast to PGP OTR messaging is designed to provide

- Deniable authentication[^7] between participants, i.e., participants can be confident about message authenticity, but not to third parties after the conversation is over.
- Forward secrecy[^8], i.e., a random secret key is generated per session preventing long-term key compromisation.

To initiate an OTR-based chat, both parties need to generate their private key first.

```bash
$ /otr gen
19:46:01 - Generating private key, this may take some time.
19:46:01 - Moving the mouse randomly around the screen may speed up the process!
19:46:01 - Private key generation complete.
```

Now either Alice or Bob can start the OTR-session.

```bash
$ /otr start
19:47:52 ! OTR session started (untrusted).
```

Notice that the chat header now indicates an OTR session, but in an untrusted state. Alice and Bob need to authenticate each other. This can be achieved by testing a common secret. Alice could ask..

```bash
$ /otr question "where did we first met?" "concert"  
19:50:32 ! Awaiting authentication from bob@my.fqdn...
```

..and Bob needs to answer..

```bash
19:50:33 ! alice@my.fqdn wants to authenticate your identity with the following question:
19:50:33 !   where did we first met?
19:50:33 ! use '/otr answer <answer>'.
$ /otr answer "concert"  
19:51:30 ! alice@my.fqdn successfully authenticated you.
```

The same process needs to be repeated from Bob to Alice and afterwards both parties will see an indication like this..

```bash
$ bob@my.fqdn/profanity [online] [OTR] [trusted]
```

## PGP encryption

Well... everytime I got in contact with PGP it ended up with headaches and hours of frustration. Not even speaking about principle issues with PGP[^12] here. That applies to PGP for profanity as well. Profanity utilizes a preinstalled GnuPG[^14] agent and libgpgme11 to access private and public keys from the agent. As of today you'd receive profanity 0.4.7 utilizing libgpgme 1.6.0 from the package sources when installing profanity in a system described below.

In theory one should be able to list preinstalled keys by running..

```bash
$ /pgp keys
20:09:43 - PGP keys:
20:09:43 -   Basti Tee <basti.tee@worldwide.net>
20:09:43 -     ID          : E5687E2D5801ABCA
20:09:43 -     Fingerprint : 74DB ZV0A E807 DA3C F421 5335 E0EB 5E2D 5801 CE7A
20:09:43 -     Type        : PUBLIC, PRIVATE
```

Long story short: I never managed to consistently setup PGP for profanity. I somehow managed to temporarily access the keys by working with newer GnuPG versions and profanity build from scratch, but nothing to base a tutorial on. The whole story is documented in a GitHub issue[^9], involving other developers failing similarly and might or might not be solved in the future.

# Conclusion

With a recent linux-based distribution, it turned out to be quite simple to setup an XMPP-based communication on the command line including encryption. I would highly recommend to go for OTR-encryption, since it is not only easier to set up, but also supports forward secrecy and is supported in most clients - including non-linux clients. An interesting project for further investigation is the omemo encryption[^10] by Daniel Gultsch[^11] beside further hardening of the involved systems[^13].

# References and further reading

Special thanks to [bascht](https://twitter.com/bascht) for helping me out with debugging the PGP issues.

[^1]: [XMPP protocol](https://de.wikipedia.org/wiki/Extensible_Messaging_and_Presence_Protocol)

[^2]: [Fully qualified domain name](https://en.wikipedia.org/wiki/Fully_qualified_domain_name)

[^3]: [ejabberd homepage](https://www.ejabberd.im)

[^4]: [Jabber foundation homepage](http://www.jabber.org/)

[^5]: [profanity homepage](http://www.profanity.im)

[^6]: [Off-the-Record messaging](https://en.wikipedia.org/wiki/Off-the-Record_Messaging)

[^7]: [Deniable authentication](https://en.wikipedia.org/wiki/Deniable_authentication)

[^8]: [Forward secrecy](https://en.wikipedia.org/wiki/Forward_secrecy)

[^9]: [»Can't use PGP« GitHub issue](https://github.com/boothj5/profanity/issues/796)

[^10]: [Omemo encryption](https://conversations.im/omemo)

[^11]: [Homepage of Daniel Gultsch](https://gultsch.de/)

[^12]: [Matthew Green - »What's the matter with PGP?«](https://blog.cryptographyengineering.com/2014/08/13/whats-matter-with-pgp)

[^13]: [Hannes Mehnert - »Secure Instant Messaging - am Beispiel XMPP«](https://berlin.ccc.de/~hannes/secure-instant-messaging.pdf)

[^14]: [The GNU Privacy Handbook](https://www.gnupg.org/gph/en/manual.html)
