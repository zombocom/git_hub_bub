# GitHubBub

[![Build Status](https://travis-ci.org/schneems/git_hub_bub.svg?branch=master)](https://travis-ci.org/schneems/git_hub_bub)

A low level GitHub client that makes the disgusting issue of header based url pagination simple.

## What

Seriously? I just told you, see above.

## Why

I'm using this in a few places such as http://www.codetriage.com/. Need low level control, without sacrificing usability.

## Install

In your `Gemfile`

```
gem 'git_hub_bub'
```

Then run `$ bundle install`

## GET Whatever you Want:

To make requests to a `GET` endpoint use `GitHubBub.get`

```ruby
response = GitHubBub.get('repos/rails/rails/issues')
```

Now you can do stuff like grab the json-ified body:

```ruby
response.json_body # => { foo: "bar" ...}
```

And get pagination (if there is any):

```ruby
response.next_url   # => "https://api.github.com/repositories/8514/issues?page=2"
response.last_url?  # => false
response.pagination # => {"next_url"=>"https://api.github.com/repositories/8514/issues?page=2", "last_url"=>"https://api.github.com/repositories/8514/issues?page=18"}
```

## Passing Params

To pass parameters such as page number, or sorting or whatever, input a hash as the second argument.

```ruby
GitHubBub.get('repositories/8514/issues', page: 1, sort: 'comments', direction:'desc')
```

## Passing Anything Else

Anything else you pass in the third argument will be given to [Excon](https://github.com/geemus/excon) which powers GitHubBub. So if you want to set headers you can do it like this:

```ruby
GitHubBub.get('repositories/8514/issues', {page: 1}, {headers: { "Content-Type" => "application/x-www-form-urlencoded" }})
```

or

```ruby
GitHubBub.get('repositories/8514/issues', {}, {headers: { "Content-Type" => "application/x-www-form-urlencoded" }})
```

See [Excon](https://github.com/geemus/excon) for documentation on more available options.

## Default Headers

Default headers are set in `GitHubBub::Request`

```ruby
BASE_HEADERS   = {'Accept' => "application/#{GITHUB_VERSION}", "User-Agent" => USER_AGENT}
```

You can change `GitHubBub::Request::GITHUB_VERSION` and `GitHubBub::Request::USER_AGENT`.

If you want any other default headers you can set them in `EXTRA_HEADERS` like so:

```ruby
GitHubBub::Request::EXTRA_HEADERS = { "Content-Type" => "application/x-www-form-urlencoded" }
```

Keep in mind this will change them for _every_ request. If you need logic behind your default headers, consider adding a `before_send_callback` to conditionally modify headers


## Authenticated Requests

Some GitHub endpoints require a user's authorization you can do that by passing in `token`:

```ruby
GitHubBub.get('/user', token: 'a38ck38ckgoldfishtoken')
```

Or you can manually set a header like so:

```ruby
GitHubBub.get('/user', {} {headers: {"Authorization" => "token a38ck38ckgoldfishtoken"}})
```

You will need to use one of these every time the GitHub api says "as an authenticated user".

## Callbacks

If you want to mess with the url or options before sending a request you can set a callback globally

```ruby
GitHubBub::Request.set_before_callback do |request|
  request.url     = "http://schneems.com"
  request.options = {do: "anything you want to _all_ the requests" }
end
```

## Endpoints

Check [GitHub Developer Docs](http://developer.github.com/). When you see something like

```
GET /users/:user/repos
```

It means you need to use the `GitHubBub.get` method and pass in a string like `'/users/schneems/repos'` the full request might look like this:


```ruby
GitHubBub.get('/users/schneems/repos')
```

## Other HTTP Methods

Supports everything GitHub currently supports http://developer.github.com/v3/#http-verbs :

```
HEAD   # => GitHubBub.head
GET    # => GitHubBub.get
POST   # => GitHubBub.post
PATCH  # => GitHubBub.patch
PUT    # => GitHubBub.put
DELETE # => GitHubBub.delete
```


## Configuration

You can use callbacks and there are some constants you can set, look in `GitHubBub::Request`. You will definetly want to set `GitHubBub::Request::USER_AGENT` It needs to be unique to your app: (http://developer.github.com/v3/#user-agent-required).

```ruby
GitHubBub::Request::USER_AGENT = 'a-unique-and-permanent-agent-to-my-app'
```

## Testing

This gem is tested using the super cool request recording/stubbing framework [VCR](https://github.com/vcr/vcr). This does mean at one point and time all tests ran successfully against GitHub's servers. This also means if you want to write any tests any that are not already recorded will need to hit GitHub servers. So make sure the tests you write don't do anything really bad.

You'll also need a valid `.env` file

```sh
$ cp .sample.env .env
```

Anything you put in this file will be sourced into your environment for tests. Here is an example `.env` file.

```sh
GITHUB_API_KEY=asdfe92fakeKey43ad638e35asdfd98167847248a26
OWNER=schneems
REPO=wicked
USER_NAME="Richard Schneeman"
WATCH_OWNER=emberjs
WATCH_REPO=ember.js
```

You will need to change most of these values

```
GITHUB_API_KEY=asdfe92fakeKey43ad638e35asdfd98167847248a26
```

Your github API key, you can get one from https://github.com/settings/applications.

```
OWNER=schneems
```

Your public github username

```
REPO=wicked
```

A repo that you have commit access too.

```
USER_NAME="Richard Schneeman"
```

Your real name

```
WATCH_OWNER=emberjs
```

The `:owner` of a repo you might watch or want to watch, needs to be combined with WATCH_REPO. This should be different from `OWNER`

```
WATCH_REPO=ember.js
```

A repo that the `WATCH_OWNER` owns. Should be different from `REPO`


## License

MIT
