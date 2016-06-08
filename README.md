# Manga Downloadr

[![Build Status](https://travis-ci.org/akitaonrails/manga-downloadr.svg)](https://travis-ci.org/akitaonrails/manga-downloadr)
[![Code Climate](https://codeclimate.com/repos/54ac0c066956802e06000ffb/badges/441f1f6af106cc32b2b5/gpa.svg)](https://codeclimate.com/repos/54ac0c066956802e06000ffb/feed)
[![Test Coverage](https://codeclimate.com/repos/54ac0c066956802e06000ffb/badges/441f1f6af106cc32b2b5/coverage.svg)](https://codeclimate.com/repos/54ac0c066956802e06000ffb/feed)

I just bought a new Kindle Paperwhite and so happens it's the perfect form factor to read good old, black and white, mangas.

So I decided to automate the process of fetching manga images from MangaReader.net, optimize and compile them into PDF files that fit the Kindle resolution.

## Installation

Setup your environment with:

    sudo apt-get install imagemagick
    sudo gem install bundler

And install manga-downloadr with:

    gem install manga-downloadr

## Usage

And then execute:

    $ manga-downloadr -u http://www.mangareader.net/onepunch-man -d /tmp/onepunch-man

In this example, all the pages of the "One Punch Man" will be downloaded to the directory "/tmp/onepunch-man" and they will have the following filename format:

    /tmp/onepunch-man/Onepunch-Man-Chap-00038-Pg-00011.jpg

You can turn on HTTP cache to be able to resume an interrupted process later if you want:

    $ manga-downloadr -u http://www.mangareader.net/onepunch-man -d /tmp/onepunch-man --cache

## Development

Tests are in Rspec:

    bundle exec rspec

Version 2.0 is a complete rewrite, following what was learned writing my [Elixir version](https://github.com/akitaonrails/ex_manga_downloadr).

This is basically a port of the [Crystal version](https://github.com/akitaonrails/cr_manga_downloadr).

Elixir has superb parallelism and concurrency through Erlang's OTP architecture so it's easy to process hundreds of parallel requests, limited only to what MangaReader can respond.

Crystal is also super fast (because its compiled to native code) and has very good concurrency (through the use of Go-like CSP channels).

This Ruby version uses native Threads. Because this is I/O intensive, we assume we can run several HTTP requests concurrently. But because Threads have significantly more overhead than Elixir or Crystal architectures, we will be limited by Ruby's MRI interpreter.

There is not a test mode you can use for benchmark purposes:

    time bin/manga-downloadr --test
    # or in JRuby:
    # time jruby --dev -S bin/manga-downloadr --test

This will use One-Punch Man as a test sample and you can also turn on the cache to not have external I/O interference

    time bin/manga-downloadr --test --cache

## Contributing

1. Fork it ( https://github.com/akitaonrails/manga-downloadr/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## TODO

* Version 2.0 removes the crash-recovery (saving state) from Version 1.0 - could be reimplemented
* Move MangaReader specifics to a different class
* Add support for MangaFox and other manga sites
