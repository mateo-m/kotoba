# check=skip=InvalidBaseImagePlatform
FROM gcc:4.9 AS builder

ARG RUBY_VERSION
ARG RUBY_MAJOR

RUN set -eux; \
  test -n "${RUBY_VERSION}"; \
  test -n "${RUBY_MAJOR}"; \
  curl -fsSL "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_VERSION}.tar.gz" -o /tmp/ruby.tar.gz; \
  mkdir -p /tmp/ruby-src /tmp/runtime-libs; \
  tar -xzf /tmp/ruby.tar.gz -C /tmp/ruby-src --strip-components=1; \
  cd /tmp/ruby-src; \
  ./configure --disable-install-doc --prefix=/usr/local; \
  make -j"$(nproc)"; \
  make install; \
  find /usr/local -type f \( -name "*.a" -o -name "*.la" \) -delete; \
  rm -rf /usr/local/share/ri /usr/local/share/doc /usr/local/lib/ruby/gems/*/cache; \
  find /usr/local -type f \( -perm -111 -o -name "*.so" \) -exec ldd {} \; 2>/dev/null \
    | awk '/=> \// {print $3} /^\// {print $1}' \
    | sort -u > /tmp/runtime-libs.txt; \
  xargs -r -a /tmp/runtime-libs.txt cp --parents -t /tmp/runtime-libs; \
  cd /; \
  rm -rf /tmp/ruby-src /tmp/ruby.tar.gz; \
  ruby -v

FROM debian:jessie-slim

COPY --from=builder /usr/local /usr/local
COPY --from=builder /tmp/runtime-libs /

WORKDIR /work

RUN ruby -v

CMD ["ruby", "-v"]
