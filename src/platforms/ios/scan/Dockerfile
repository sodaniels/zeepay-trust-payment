FROM ruby:3.0-alpine

WORKDIR /app

COPY Gemfile Gemfile.lock /app/

RUN bundle && apk add --update bash

COPY . . 

CMD ./wait-for-it.sh mobsf:8000 -- ruby scan.rb
