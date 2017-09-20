local inspect = require('inspect');
local mongo = require('mongo');
local httpclient = require('httpclient');
local _ = require('moses');
local JSON = require("JSON");
local redis = require('redis');


local config = require('/etc/asterisk/dialplan/config');
local redisClient = redis.connect(config.redis.host, config.redis.port);



local checkstatus = function (dialstatus)
    if dialstatus == 'BUSY' then
        app.playback("followme/sorry");
    elseif dialstatus == 'CHANUNAVAIL' then
        app.playback("followme/sorry");
    end
end


local example1 = function(context, extension)
    --- пример простого звонка
    app.noop("context: " .. context .. ", extension: " .. extension);

    local data = {
        linkedid = channel["CDR(linkedid)"]:get();
        uniqueid = channel["CDR(uniqueid)"]:get();
    }

    app.noop('data: '..inspect(data));
    app.dial('SIP/' .. extension, 10);

    local dialstatus = channel["DIALSTATUS"]:get();
    
    app.noop('dialstatus: '..dialstatus);
    app.set("CHANNEL(language)=ru");    
    checkstatus(dialstatus);

    app.hangup();
end

local hangup = function(context, extension)
    app.noop('hangup!!');

    local billsec = channel["CDR(billsec)"]:get();
    app.noop("billsec: "..inspect(tonumber(billsec)));
end






local dbConn = function ()
    local db, err = mongo.Connection.New({
        auto_reconnect = true;
    });
    
    if err then
        db = nil; 
    else
        local ok, err = db:connect(config.mongo.host);
    end

    return db
end

local getIVRbyExtension = function (dbconn, extension)
    local cursor = dbconn:query(config.mongo.dbname..'.'..config.mongo.collection, {
        -- _id = mongo.ObjectId(tostring(id)),
        extension = tostring(extension)
    });

    return cursor:next()
end


local example2 = function(context, extension)

    -- пример звонка с использованием прямого доступа к БД монго
    app.noop("context: " .. context .. ", extension: " .. extension);

    local data = {
        linkedid = channel["CDR(linkedid)"]:get();
        uniqueid = channel["CDR(uniqueid)"]:get();
    }

    app.noop('data: '..inspect(data));

    local t1 = os.time();

    local dbconn = dbConn();
    local ivr;
    if not dbconn then 
        app.noop('oh, no!!! ');
        app.hangup();
    end
    
    ivr = getIVRbyExtension(dbconn, extension);
    app.noop('ivr:'..inspect(ivr));

    app.playback(ivr.filename);


    app.noop('diiftime: '..inspect(os.difftime(os.time() - t1)));
    app.hangup();
end


local example3 = function(context, extension)

    -- пример звонка с использованием http доступа к ресурсам
    app.noop("context: " .. context .. ", extension: " .. extension);

    local data = {
        linkedid = channel["CDR(linkedid)"]:get();
        uniqueid = channel["CDR(uniqueid)"]:get();
    }

    app.noop('data: '..inspect(data));

    local t1 = os.time();

    local hc = httpclient.new()
    local res = hc:get(config.ivrs.url)
    local ivrs, ivr;

    if res.body then
      app.noop(inspect(res.body));
      ivrs = JSON:decode(res.body);
      app.noop('ivrs:'..inspect(ivrs));

      ivr = _.select(ivrs, function (key, value) 
        return (value.extension == extension)
      end)

    else
      app.noop(res.err)
    end


    if ivr and ivr[1] then
        app.playback(ivr[1].filename);
    else 
        app.noop('no ivr in resource '..inspect(config.ivrs.url));
    end

    app.noop('diiftime: '..inspect(os.difftime(os.time() - t1)));
    app.hangup();
end




local setRedis = function (key, value)
    local expire = 5; -- секунды хранения в редис
    redisClient:set(key, value);
    redisClient:expire(key, expire);
end

local getRedis = function (key)
    return redisClient:get(key);
end





local example4 = function(context, extension)

    -- пример звонка с использованием redis
    app.noop("context: " .. context .. ", extension: " .. extension);

    local data = {
        linkedid = channel["CDR(linkedid)"]:get();
        uniqueid = channel["CDR(uniqueid)"]:get();
    }

    app.noop('data: '..inspect(data));

    setRedis(data.linkedid, 'ANSWER');


    app.playback('tt-monkeys');
    app.hangup();
end


local hangup4 = function (context, extension)
    app.noop('hangup 4!!');
    local linkedid = channel["CDR(linkedid)"]:get();
    local data = getRedis(linkedid)

    app.noop('data from redis: '..inspect(data));
end





local Dialplan = {
    getExtensions = function()
        return {

            ["internal"] = {
                ["_X."] = example4;

                ["h"] = hangup4;
            };

            ["incoming"] = {
                ["_XXXXXXXXXX"] = incoming;

                ["h"] = hangup;
            };
	}
    end
}

return Dialplan