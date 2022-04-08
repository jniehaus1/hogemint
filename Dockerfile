# Set base node environment, which includes yarn
FROM ruby:2.7.2

RUN apt-get update -qq && apt-get -y install nodejs postgresql-client npm

# Set working directory to /app
WORKDIR /app
COPY . /app

RUN bundle update && bundle install
RUN npm install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]