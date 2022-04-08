release: bin/rails hogemint:release:run
web: bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
nftworker: bundle exec sidekiq -c 5
