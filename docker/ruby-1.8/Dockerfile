FROM gcc:4.9 AS builder

ARG RUBY_VERSION=1.8.7-p374
ARG RUBY_MAJOR=1.8

RUN set -eux; \
  curl -fsSL "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_VERSION}.tar.gz" -o /tmp/ruby.tar.gz; \
  mkdir -p /tmp/ruby-src; \
  tar -xzf /tmp/ruby.tar.gz -C /tmp/ruby-src --strip-components=1; \
  cd /tmp/ruby-src; \
  ./configure --disable-install-doc --prefix=/usr/local; \
  make -j"$(nproc)"; \
  make install; \
  find /usr/local -type f \( -name "*.a" -o -name "*.la" \) -delete; \
  rm -rf /usr/local/share/ri /usr/local/share/doc /usr/local/lib/ruby/gems/*/cache; \
  cd /; \
  rm -rf /tmp/ruby-src /tmp/ruby.tar.gz; \
  ruby -v

FROM debian:jessie-slim

COPY --from=builder /usr/local /usr/local

WORKDIR /work

RUN ruby -v

CMD ["ruby", "-v"]
