# Manga Downloadr

I just bought a new Kindle Paperwhite and so happens it's the perfect form factor
to read good old, black and white, mangas.

So I decided to automate the process of fetching manga images from MangaReader.net,
optimize and compile them into PDF files that fit the Kindle resolution.

## Installation

Just install with:

```
gem install manga-downloadr
```

## Usage

And then execute:

    $ manga-downloadr -n berserk -u http://www.mangareader.net/96/berserk.html -d /MyDocuments/MyMangas

If there's any interruption (bad network) you can run the same command line again and it will resume from
where it was interrupted before.

If you want to restart from scratch, delete the "/tmp/[your manga].yml" that saves the current workflow state.

## Contributing

1. Fork it ( https://github.com/akitaonrails/manga-downloadr/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## TODO

* Move MangaReader specifics to a different class
* Add support for MangaFox and other manga sites
