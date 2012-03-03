package.path = package.path .. ";../src/?.lua;src/?.lua"

require "luarocks.require"
require "redis"
local Nest = require "nest"

print("Creating namespaces")

local n1 = Nest:new("foo")
-- return the namespace
assert("foo" == tostring(n1))
-- prepend the namespace
assert("foo:bar" == tostring(n1["bar"]))

local n2 = Nest:new(n1["bar"])
-- work in more than one level
assert("foo:bar:baz" == tostring(n2["baz"]))
-- be chainable
assert("foo:bar:baz" == tostring(n1["bar"]["baz"]))
-- accept dot notation
assert("foo:bar" == tostring(n1.bar))
-- accept numbers
assert("foo:3" == tostring(n1[3]))

print("Operating with redis.")

local settings = {
  host = "127.0.0.1",
  port = 6379,
  db = 15
}

local redis = Redis.connect(settings.host, settings.port)
redis:select(settings.db)
redis:flushdb()

n1 = Nest:new("foo")
n1:set("s1")
-- work if no redis instance was passed
assert("s1" == n1:get())

n1 = Nest:new("foo", redis)
n1:set("s1")
-- work if a redis instance is supplied
assert("s1" == n1:get())
-- pass the redis instance to new keys
assert(redis == n1["bar"].redis)
