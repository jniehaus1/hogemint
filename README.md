# README

* Install rbenv and ruby first
* Ruby version is 2.7.2
* Install bundler
* Install Postgres 11 or greater, later versions should be non-breaking
* Install Redis & Sidekiq

# hogemint

# Docker setup:
Run the following Commands:

    git clone https://github.com/HogeFinance/hogemint.git
    cd hogemint
    cp .env.example .env

Update .env with the values you need for your development environment. You can also uncomment the lines around pgadmin and geth in docker-compose.yml to run those services in additional containers.

To launch the hogemint app run:

    docker-compose build
    docker-compose up

hogemint should now be present on localhost:3000