This is the repo for the nmrML official website. You can find the site online at [nmrml.org](http://nmrml.org). It is hosted on GitHub pages.

# Editing Instructions

[See the instructions in the wiki](https://github.com/nmrML/nmrML/wiki/nmrML.org-website-editing)

For super-simple teeny-weeny tiny changes,
you can even use the github web-editor:

Go to the nmrML github repository, change to the gh-pages branch,
and navigate to the page you want to change,

e.g. to add news:

[/gh-pages/news/index.html](https://github.com/nmrML/nmrML/blob/gh-pages/news/index.html)

If you are logged in, hit the "Edit" button,
and when done add a "Commit summary" below the edit area
and hit the green "Commit Changes" button. Done!

# Serving site locally for development

Prerequisites:

Install ruby, and bundler. For example to install with rbenv on Mac OS X:
```bash
brew update
brew install rbenv ruby-build
rbenv install 2.1.0
gem install bundler
```

Now go to the directory for the site, or checkout with, to just checkout
the gh-pages branch:
```bash
git clone -b gh-pages --single-branch git@github.com:nmrML/nmrML.git
```

Now in that directory install the github pages libraries, and start the
server with:
```bash
bundle install
bundle exec jekyll serve 
```

You should now be able to access the site in a browser at
http://localhost:4000 


# Github Pages Resources

For more info on creating websites with GitHub pages

- [https://help.github.com/categories/20/articles](GitHub pages guide)
- [http://daringfireball.net/projects/markdown/syntax](Markdown Syntax Guide)
- [https://help.github.com/articles/github-flavored-markdown](Github Flavored Markdown)

