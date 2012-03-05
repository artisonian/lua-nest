require "luarocks.require"
local redis = require "redis"

Nest = {}

local commands = {
  "append", "blpop", "brpop", "brpoplpush", "decr", "decrby",
  "del", "exists", "expire", "expireat", "get", "getbit", "getrange", "getset",
  "hdel", "hexists", "hget", "hgetall", "hincrby", "hkeys", "hlen", "hmget",
  "hmset", "hset", "hsetnx", "hvals", "incr", "incrby", "lindex", "linsert",
  "llen", "lpop", "lpush", "lpushx", "lrange", "lrem", "lset", "ltrim", "move",
  "persist", "publish", "rename", "renamenx", "rpop", "rpoplpush", "rpush",
  "rpushx", "sadd", "scard", "sdiff", "sdiffstore", "set", "setbit", "setex",
  "setnx", "setrange", "sinter", "sinterstore", "sismember", "smembers",
  "smove", "sort", "spop", "srandmember", "srem", "strlen", "subscribe",
  "sunion", "sunionstore", "ttl", "type", "unsubscribe", "watch", "zadd",
  "zcard", "zcount", "zincrby", "zinterstore", "zrange", "zrangebyscore",
  "zrank", "zrem", "zremrangebyrank", "zremrangebyscore", "zrevrange",
  "zrevrangebyscore", "zrevrank", "zscore", "zunionstore"
}

local function compact (...)
  local t = {}
  for _,v in pairs({...}) do
    if v ~= nil then t[#t + 1] = v end
  end
  return t
end

function Nest:new (namespace, redis)
  local o = { namespace={ tostring(namespace) } }
  o.redis = redis or Redis.connect()
  setmetatable(o, self)
  -- self.__index = self
  return o
end

function Nest.__eq (a, b)
  return tostring(a) == tostring(b)
end

function Nest.__index (t, k)
  for _, v in ipairs(commands) do
    if v == k then
      local r = rawget(t, "redis")
      local cmd = r[k]
      return function(...)
        local args = compact(...)
        return cmd(r, args)
      end
    end
  end

  for _, v in ipairs (t.namespace) do
    if v == k then
      return t
    end
  end

  return Nest:new(tostring(t) .. ":" .. k, t.redis)
end

function Nest.__tostring (t)
  return table.concat(t.namespace, ":")
end

-- Pretty printer for tables
function Nest.redis_pp (o)
  if type(o) == "table" then
    local output = {}
    for k,v in pairs(o) do
      output[k] = string.format("%q", v)
    end
    print(string.format("[%s]", table.concat(output, ", ")))
  else
    print(o)
  end
end

return Nest
