# Generic Legacy Ruby Docker Images

These images provide reusable Linux Ruby runtimes for compatibility testing against very old Ruby versions. They are generic Ruby images: Ruby is pre-installed during the image build, and project code is mounted only when running tests.

Build them from the repository root:

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

Run the unit suite:

```sh
docker run --rm --platform linux/amd64 -v "$PWD":/work -w /work ruby-legacy:1.8.7-p374 ruby -Itest -e 'ARGV.each { |file| load file }' test/**/*_test.rb
docker run --rm --platform linux/amd64 -v "$PWD":/work -w /work ruby-legacy:1.9.3-p551 ruby -Itest -e 'ARGV.each { |file| load file }' test/**/*_test.rb
```

Check common native standard-library extensions:

```sh
docker run --rm --platform linux/amd64 ruby-legacy:1.8.7-p374 ruby -e 'require "zlib"; require "openssl"; require "readline"; require "socket"; puts "ok"'
docker run --rm --platform linux/amd64 ruby-legacy:1.9.3-p551 ruby -e 'require "zlib"; require "openssl"; require "readline"; require "socket"; puts "ok"'
```
