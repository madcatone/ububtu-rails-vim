FROM ubuntu:16.10 
# 如果下载的很慢，这里可以改成 Daocloud 的镜像：daocloud.io/library/ubuntu:trusty-XXXXXXX
MAINTAINER Tairy <tairyguo@gmail.com> 
# 改成你自己的

# Run update
# 为了加快 update 的速度，修改 ubuntu 源为阿里云（目前尝试的最快的，也可以自行选择其他国内的镜像）
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && apt-get update --fix-missing \
    && apt-get -y upgrade

# Install dependencies
RUN apt-get install -y git \
    curl zlib1g-dev build-essential \
    libssl-dev libreadline-dev
RUN apt-get update --fix-missing   
RUN apt-get install -y libyaml-dev \
    libsqlite3-dev sqlite3 libxml2-dev \
    libxslt1-dev libcurl4-openssl-dev \
    python-software-properties libffi-dev

# Install rbenv
# 这里 clone 的时候可能会有点慢，可以先 clone 到本地，把下面的 clone 操作改成 ADD rbenv /root/.rbenv 操作即可。
RUN git clone git://github.com/sstephenson/rbenv.git /root/.rbenv \
    && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /root/.bashrc \
    && echo 'eval "$(rbenv init -)"' >> /root/.bashrc \
    && git clone git://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build \
    && echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> /root/.bashrc

# 为了加速 rbenv 使用 ruby china 的加速插件
RUN git clone https://github.com/andorchen/rbenv-china-mirror.git /root/.rbenv/plugins/rbenv-china-mirror

# Install ruby
RUN /root/.rbenv/bin/rbenv install -v 2.3.1 \
    && /root/.rbenv/bin/rbenv global 2.3.1 \
    && echo "gem: --no-document" > /root/.gemrc \
    && /root/.rbenv/shims/gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/ \
    && /root/.rbenv/shims/gem install bundler \
    && /root/.rbenv/shims/gem install rails \
    && /root/.rbenv/bin/rbenv rehash
RUN apt-get install -y software-properties-common python-software-properties
# Install nodejs
RUN apt-get -y install nodejs

RUN /root/.rbenv/shims/bundle config --global frozen 1
RUN /root/.rbenv/shims/bundle config --global silence_root_warning 1

# Run project
RUN mkdir -p /working
WORKDIR /working
ONBUILD COPY Gemfile /working
ONBUILD COPY Gemfile.lock /working
ONBUILD RUN /root/.rbenv/shims/bundle install --no-deployment
ONBUILD COPY . /working

# Some tools
RUN apt-get install -y vim inetutils-ping
