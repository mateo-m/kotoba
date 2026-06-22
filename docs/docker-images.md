# Legacy Ruby Docker Images

> Reusable Linux Ruby images for compatibility testing against Ruby 1.8 and 1.9.

These images are generic Ruby runtimes. Ruby is installed during the image build, and project code is mounted only when you run tests.

## Requirements

- Docker
- The repository checked out locally

## Installing

Build the images from the repository root:

```sh
docker build --platform linux/amd64 \
  --build-arg RUBY_MAJOR=1.8 \
  --build-arg RUBY_VERSION=1.8.7-p374 \
  -t ruby-legacy:1.8.7-p374 \
  -f docker/ruby-legacy/Dockerfile .

docker build --platform linux/amd64 \
  --build-arg RUBY_MAJOR=1.9 \
  --build-arg RUBY_VERSION=1.9.3-p551 \
  -t ruby-legacy:1.9.3-p551 \
  -f docker/ruby-legacy/Dockerfile .
```

## Usage

Run the unit suite in Ruby 1.8:

```sh
docker run --rm --platform linux/amd64 -v "$PWD":/work -w /work ruby-legacy:1.8.7-p374 \
  ruby -Itest -e 'ARGV.each { |file| load file }' test/**/*_test.rb
```

Run the unit suite in Ruby 1.9:

```sh
docker run --rm --platform linux/amd64 -v "$PWD":/work -w /work ruby-legacy:1.9.3-p551 \
  ruby -Itest -e 'ARGV.each { |file| load file }' test/**/*_test.rb
```

Verify common native standard-library extensions:

```sh
docker run --rm --platform linux/amd64 ruby-legacy:1.8.7-p374 \
  ruby -e 'require "zlib"; require "openssl"; require "readline"; require "socket"; puts "ok"'

docker run --rm --platform linux/amd64 ruby-legacy:1.9.3-p551 \
  ruby -e 'require "zlib"; require "openssl"; require "readline"; require "socket"; puts "ok"'
```

## Related Docs

- [Compatibility](/compatibility)
- [CI](/ci)
