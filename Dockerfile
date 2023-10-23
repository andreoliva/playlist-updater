FROM ruby:3.2.2-slim

RUN apt-get update \
  && apt-get install -y build-essential \
  && apt autoremove -y

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler \
  && bundle install

COPY . ./

CMD ["irb"]
