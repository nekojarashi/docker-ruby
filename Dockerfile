FROM centos:centos6.9
LABEL maintainer="y-okubo"

ENV LANG=ja_JP.UTF-8
ENV RUBY_MAJOR 2.3
ENV RUBY_VERSION 2.3.3
ENV RUBY_DOWNLOAD_SHA256 1a4fa8c2885734ba37b97ffdb4a19b8fba0e8982606db02d936e65bac07419dc
ENV RUBYGEMS_VERSION 2.7.7
ENV BUNDLER_VERSION 1.16.4

# language & timezone
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 \
	&&  cp -p /usr/share/zoneinfo/Japan /etc/localtime \
	&&  echo 'ZONE="Asia/Tokyo"' > /etc/sysconfig/clock

# install development tools
RUN sed -ri 's/^verbose=0/verbose=1/' /etc/yum/pluginconf.d/fastestmirror.conf \
	&& echo include_only=.jp >> /etc/yum/pluginconf.d/fastestmirror.conf \
	&& yum groupinstall "Development Tools" -y \
	&& yum install -y curl openssl-devel readline-devel vim wget zlib-devel \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all \
	\
# update autoconf
	&& curl -L -O http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz \
	&& tar xf autoconf-2.69.tar.gz -C /usr/src \
	&& cd /usr/src/autoconf-2.69 \
	&& ./configure \
	&& make && make install \
	&& cd / \
	&& rm -fr /usr/src/autoconf-2.69 \
	\
# skip installing gem documentation
	&& mkdir -p /usr/local/etc \
	&& { \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /usr/local/etc/gemrc \
	\
# ref: https://github.com/docker-library/ruby/blob/4fa4c114e81bf8bdb653262c033da1d3fafa9141/2.3/stretch/Dockerfile
	&& wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz" \
	&& echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c - \
	\
	&& mkdir -p /usr/src/ruby \
	&& tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1 \
	&& rm ruby.tar.xz \
	\
	&& cd /usr/src/ruby \
	\
# hack in "ENABLE_PATH_CHECK" disabling to suppress:
#   warning: Insecure world writable dir
	&& { \
		echo '#define ENABLE_PATH_CHECK 0'; \
		echo; \
		cat file.c; \
	} > file.c.new \
	&& mv file.c.new file.c \
	\
	&& autoconf \
	&& gnuArch="x86_64-linux-gnu" \
	&& ./configure \
		--build="$gnuArch" \
		--disable-install-doc \
		--enable-shared \
	&& make -j "$(nproc)" \
	&& make install \
	\
	&& cd / \
	&& rm -r /usr/src/ruby \
	\
	&& gem update --system "$RUBYGEMS_VERSION" \
	&& gem install bundler --version "$BUNDLER_VERSION" --force \
	&& rm -r /root/.gem/

# install things globally, for great justice
# and don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
	BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
# path recommendation: https://github.com/bundler/bundler/pull/6469#issuecomment-383235438
ENV PATH $GEM_HOME/bin:$BUNDLE_PATH/gems/bin:$PATH
# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"
# (BUNDLE_PATH = GEM_HOME, no need to mkdir/chown both)