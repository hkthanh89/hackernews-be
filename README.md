# README

![main](https://github.com/hkthanh89/hackernews-be/actions/workflows/test.yml/badge.svg)

### RUBY VERSION
Ruby: 2.7.0

### Install dependencies
```
$ bundle install
```

### Start server
```
$ rails s -p 3000
```

### Running Test
```
$ bundle exec rspec spec -f d
```

### API Endpoint

##### Get All News
```
http://localhost:3000/news
```

##### Get All News by page
```
http://localhost:3000/news?page=2
```

##### Get a News detail
```
http://localhost:3000/news?url=<url>
```

### Use Docker
```
$ docker build -t hackernews-be .

# run test
$ docker run -e RUBYOPT=-W0 -it --rm hackernews-be bundle exec rspec

# start server
$ docker run -it --rm -p 3000:3000 hackernews-be bundle exec rails s -b 0.0.0.0
```
