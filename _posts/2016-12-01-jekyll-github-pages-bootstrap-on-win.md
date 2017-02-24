---
layout: post
title:  "GitHub pages & Jekyll bootstrapped on Windows 10"
date:   2016-12-01 11:34:49 +0100
twitter: https://twitter.com/basti_tee/status/833599194246107137
source:  https://github.com/BastiTee/localhost/blob/master/_posts/2016-12-01-jekyll-github-pages-bootstrap-on-win.md
---
These are the steps I did in order to setup Jekyll/Ruby on Windows 10 and to create the first iteration of this blog.

First I followed most of the steps on [jekyll-windows](http://jekyll-windows.juthilo.com/).

* Downloaded [Ruby](http://rubyinstaller.org/downloads/) and installed it with "Add to path" option.
* Downloaded [Ruby DevKit](http://rubyinstaller.org/downloads/) and unpacked.
* Setup Ruby DevKit

```shell
cd <RubyDevKit>
ruby dk.rb init
ruby dk.rb install
```

* Installed Jekyll and rouge for code formatting

```shell
gem install jekyll
gem install rouge
```

* Created a [new github repository](https://github.com/new) for GitHub pages (i.e. \<username\>.github.io)
* Checked out the thing locally

```shell
cd <your-place-for-repos>
git clone https://github.com/^
UserName/username.github.io
```


Then I basically followed the steps in [Get Started with GitHub pages](https://24ways.org/2013/get-started-with-github-pages/).

* Created a basic jekyll site (folder must be empty, otherwise you'll get a Conflict-error)

```shell
jekyll new username.github.io
```

* Ran Jekyll and viewed the result on my [localhost](http://localhost:8000).

```shell
jekyll serve --watch --host localhost --port 8000
```

* Pushed the stuff back to GitHub after I set up the repository with credentials etc.

```shell
echo "# Readme" > README.md
git add .
git commit -m "Init."
git push -u origin master
```

* Viewed the result on [GitHub](https://UserName.github.io)
* Obsessed over the CSS for some hours...
