package.path = package.path .. ";../src/?.lua;src/?.lua"

require "redis"

context("Nest", function()
  before(function()
    Nest = require "nest"
  end)

  context("Creating namespaces", function()
    before(function()
      n1 = Nest:new("foo")
    end)
    
    test("return the namespace", function()
      assert_equal("foo", tostring(n1))
    end)

    test("prepend the namespace", function()
      assert_equal("foo:bar", tostring(n1["bar"]))
    end)

    test("work in more than one level", function()
      local n2 = Nest:new(n1["bar"])
      assert_equal("foo:bar:baz", tostring(n2["baz"]))
    end)

    test("be chainable", function()
      assert_equal("foo:bar:baz", tostring(n1["bar"]["baz"]))
    end)

    test("accept dot notation", function()
      assert_equal("foo:bar", tostring(n1.bar))
    end)

    test("accept numbers", function()
      assert_equal("foo:3", tostring(n1[3]))
    end)
  end)

  context("Operating with redis", function()
    before(function()
      settings = {
        host = "127.0.0.1",
        port = 6379,
        db = 15
      }

      redis = Redis.connect(settings.host, settings.port)
      redis:select(settings.db)
      redis:flushdb()
    end)

    test("work if no redis instance was passed", function()
      local n1 = Nest:new("foo")
      n1:set("s1")
      assert_equal("s1", n1:get())
    end)

    test("work if a redis instance is supplied", function()
      local n1 = Nest:new("foo", redis)
      n1:set("s1")
      assert_equal("s1", n1:get())
    end)

    test("pass the redis instance to new keys", function()
      local n1 = Nest:new("foo", redis)
      assert_equal(redis, n1["bar"].redis)
    end)
  end)
end)
