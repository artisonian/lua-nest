lua-nest
===

A Lua port of [Nest](https://github.com/soveran/nest).

Usage
---

From Nest's [README](https://github.com/soveran/nest/blob/master/README.markdown):

``` lua
local Nest = require "nest"
local rpp = Nest.redis_pp     -- pretty printer for Redis lists and sets

ns = Nest:new("foo")
print(ns["bar"])                -- "foo:bar"
print(ns["bar"]["baz"]["qux"])  -- "foo:bar:baz:qux"
print(ns["bar"][42])            -- "foo:bar:42"
```

``` lua
events = Nest:new("events")
id = events[id]:incr()

events[id]["attendees"]:sadd("Albert")

meetup = events[id]
rpp(meetup["attendees"]:smembers())   -- ["Albert"]
```

``` lua
events = Nest:new("events", meetup.redis)

events:sadd(meetup)
print(events:sismember(meetup))       -- true
rpp(events:smembers())                -- ["events:1"]

events:del()
```

Testing
---

    luarocks install telescope
    tsc -f test/*.lua
