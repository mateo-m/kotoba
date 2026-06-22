# Generic Legacy Ruby Docker Images

These images provide reusable Linux Ruby runtimes for compatibility testing against very old Ruby versions. They are generic Ruby images: Ruby is pre-installed during the image build, and project code is mounted only when running tests.

Build them from the repository root:

```sh
docker build --platform linux/amd64 -t ruby-legacy:1.8.7-p374 -f docker/ruby-1.8/Dockerfile .
docker build --platform linux/amd64 -t ruby-legacy:1.9.3-p551 -f docker/ruby-1.9/Dockerfile .
```

Run the unit suite:

```sh
docker run --rm --platform linux/amd64 -v "$PWD":/work -w /work ruby-legacy:1.8.7-p374 ruby -Itest -e 'ARGV.each { |file| load file }' test/core_test.rb test/json_parser_test.rb test/message_eval_test.rb
docker run --rm --platform linux/amd64 -v "$PWD":/work -w /work ruby-legacy:1.9.3-p551 ruby -Itest -e 'ARGV.each { |file| load file }' test/core_test.rb test/json_parser_test.rb test/message_eval_test.rb
```
