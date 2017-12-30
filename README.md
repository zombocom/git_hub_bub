# GitHubBub

[![Build Status](https://travis-ci.org/schneems/git_hub_bub.svg?branch=master)](https://travis-ci.org/schneems/git_hub_bub)
[![Help Contribute to Open Source](https://www.codetriage.com/schneems/git_hub_bub/badges/users.svg)](https://www.codetriage.com/schneems/git_hub_bub)

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

## Upgrading to v1

Version 0.x of this library would raise an exception on any non-200 response. The current version does not do this, it instead provides a method

```ruby
response = GitHubBub.get("repoZ/railZ/railZ/issueZ")
response.success?
# => false
```

> Note this only checks for 2.x status, it does not acount for any other status codes, best practice is to manually manage yourself

To preserve previous behavior of raising an error on non-200 status. You can set the `GIT_HUB_BUB_RAISE_ON_FAIL` environment variable to any value.

In v1 the ability to sleep to add a rate limit was added:

```
response = GitHubBub.get('repos/rails/rails/issues')
response.rate_limit_sleep!
```

As the number of available requests gets smaller and smaller this will sleep for longer and longer.

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
response.rate_limit_remaining # => 60
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

## Rate limiting

GitHub requests are rate limited. With every request they send back information with the number of requests left and when the time window resets.

Instead of worrying about either of those direct measurements you can instead use this helper method:

```
response = GitHubBub.get('repos/rails/rails/issues')
response.rate_limit_sleep!
```

If you are repetitively calling the API you should use this method in each loop to prevent going over your bucket.

As your remaining request limit gets lower this method will sleep for incrementally longer time periods until your limit bucket is refilled. Since this behavior comes __after__ a request it is possible that this request was rate limited. GitHub will return a 403 when you are over your limit.

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
