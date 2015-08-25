#!/usr/bin/env ruby
#
# A simple webserver to respond to github api calls for integration tests
# of the github authentication endpoint

require 'webrick'
require 'json'

# process the /user endpoint
def proc_user(req, res)
  res.status            = 200
  res['Content-Type']   = 'application/json'
  res['status']         = "200 OK"
  res["x-oauth-scopes"] = "read:org"

   user = { "login"=>"hashicorp",
    "id"=>111,
    "avatar_url"=>"https://avatars.githubusercontent.com/u/428?v=3",
    "gravatar_id"=>"",
    "url"=>"https://api.github.com/users/hashicorp",
    "html_url"=>"https://github.com/hashicorp",
    "followers_url"=>"https://api.github.com/users/hashicorp/followers",
    "following_url"=>"https://api.github.com/users/hashicorp/following{/other_user}",
    "gists_url"=>"https://api.github.com/users/hashicorp/gists{/gist_id}",
    "starred_url"=>"https://api.github.com/users/hashicorp/starred{/owner}{/repo}",
    "subscriptions_url"=>"https://api.github.com/users/hashicorp/subscriptions",
    "organizations_url"=>"https://api.github.com/users/hashicorp/orgs",
    "repos_url"=>"https://api.github.com/users/hashicorp/repos",
    "events_url"=>"https://api.github.com/users/hashicorp/events{/privacy}",
    "received_events_url"=>"https://api.github.com/users/hashicorp/received_events",
    "type"=>"User",
    "site_admin"=>false,
    "name"=>"Vault Test",
    "company"=>"Vault Testing",
    "blog"=>nil,
    "location"=>nil,
    "email"=>nil,
    "hireable"=>nil,
    "bio"=>nil,
    "public_repos"=>56,
    "public_gists"=>23,
    "followers"=>25,
    "following"=>28,
    "created_at"=>"2008-02-19T18:08:27Z",
    "updated_at"=>"2015-08-28T20:59:10Z" }
  res.body = JSON.dump user
  return res
end

# process /user/orgs endpoint
def proc_orgs(req, res)
  res.status            = 200
  res['Content-Type']   = 'application/json'
  res['status']         = "200 OK"
  res["x-oauth-scopes"] = "read:org"

  orgs = [{"login"=>"vault-intgration-tests",
    "id"=>123456,
    "url"=>"https://api.github.com/orgs/vault-intgration-tests",
    "repos_url"=>"https://api.github.com/orgs/vault-intgration-tests/repos",
    "events_url"=>"https://api.github.com/orgs/vault-intgration-tests/events",
    "members_url"=>"https://api.github.com/orgs/vault-intgration-tests/members{/member}",
    "public_members_url"=>"https://api.github.com/orgs/vault-intgration-tests/public_members{/member}",
    "avatar_url"=>"https://avatars0.githubusercontent.com/u/761456?v=3&s=200",
    "description"=>""}]
  res.body = JSON.dump orgs
  return res
end

# process /user/teams endpoing
def proc_teams(req, res)
  res.status            = 200
  res['Content-Type']   = 'application/json'
  res['status']         = "200 OK"
  res["x-oauth-scopes"] = "read:org"
  teams = [{"name"=>"Owners",
    "id"=>123456,
    "slug"=>"owners",
    "description"=>nil,
    "permission"=>"admin",
    "url"=>"https://api.github.com/teams/123456",
    "members_url"=>"https://api.github.com/teams/12345/members{/member}",
    "repositories_url"=>"https://api.github.com/teams/12345/repos",
    "members_count"=>2,
    "repos_count"=>7,
    "organization"=>
     {"login"=>"vault-intgration-tests",
      "id"=>1111,
      "url"=>"https://api.github.com/orgs/vault-intgration-tests",
      "repos_url"=>"https://api.github.com/orgs/vault-intgration-tests/repos",
      "events_url"=>"https://api.github.com/orgs/vault-intgration-tests/events",
      "members_url"=>"https://api.github.com/orgs/vault-intgration-tests/members{/member}",
      "public_members_url"=>"https://api.github.com/orgs/vault-intgration-tests/public_members{/member}",
      "avatar_url"=>"https://avatars0.githubusercontent.com/u/761456?v=3&s=200",
      "description"=>nil,
      "name"=>"vault",
      "company"=>nil,
      "blog"=>nil,
      "location"=>nil,
      "email"=>nil,
      "public_repos"=>7,
      "public_gists"=>0,
      "followers"=>0,
      "following"=>0,
      "html_url"=>"",
      "created_at"=>"2013-04-18T04:16:19Z",
      "updated_at"=>"2014-09-17T02:46:28Z",
      "type"=>"Organization"}}]
  res.body = JSON.dump teams
  return res
end

# Start a webrick server and listen for /user requests
server = WEBrick::HTTPServer.new :Port => 8201
server.mount_proc '/user' do |req, res|

  # By default we'll just return a 403
  res.status = 403
  res.body   = 'unauthorized'

  # if the token looks good, process the requests
  if req.header['authorization'].first == "Bearer 10ad4cf71757f49c4859187ca73e918fdca59719"
    case req.path
    when "/user"
      res = proc_user(req, res)
    when "/user/orgs"
      res = proc_orgs(req, res)
    when "/user/teams"
      res = proc_teams(req, res)
    end
  end
end

trap 'INT' do server.shutdown end
server.start
