FROM ruby:2.5-buster
# docker build -t puma .
# docker run -p 80:3000 -e  SECRET_KEY_BASE=4dcaf302f09d26f44f0916f02de97e1fe7d61c0b9b1238ed480212f6aee785f963cdabed57699f395920f9467b863289ac24467ab3bcd0561e137411b56c0bd4 puma:latest
RUN gem install bundler
# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

ENV RAILS_ENV='production'
ENV RACK_ENV='production' 

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test'
RUN bundle install

# RUN apt-get install nodejs

COPY . .
# RUN bundle exec rake assets:precompile SECRET_KEY_BASE=4dcaf302f09d26f44f0916f02de97e1fe7d61c0b9b1238ed480212f6aee785f963cdabed57699f395920f9467b863289ac24467ab3bcd0561e137411b56c0bd4
RUN mkdir -p shared/pids shared/log shared/sockets
# CMD ["ruby", "-run", "-ehttpd", ".", "-p3000"]
# CMD ["bundle", "exec", "unicorn",  "-c", "config/unicorn.rb", "-E", "production"]
# unicorn worker[1] -c config/unicorn.rb -E production -D
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
# CMD ["bundle", "exec", "rails", "server"]



#  2027  asdf local nodejs 14.2.0
#  2028*
#  2029  bundle install
#  2030  brew install postgresql
#  2031  bundle install
#  2032  gst
#  2033  bundle install
#  2034  history
#  2035  bundle install
#  2036  which -a ruby
#  2037  ruby --version
#  2038  rbenv uninstall 2.5.1
#  2039  rbenv install 2.5.1
#  2040  rbenv use 2.5.1
#  2041  rbenv local 2.5.1
#  2042  bundle install
#  2043  gem install bundler
#  2044  bundle install
#  2045  gst
#  2046  bundle update --bundler
#  2047  rake assets:precompile RAILS_ENV=production
#  2048  bundle exec rake assets:precompile
#  2049  docker build -t unicorn .