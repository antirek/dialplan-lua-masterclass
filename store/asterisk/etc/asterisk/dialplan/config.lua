local config = {
    ["basepath"] = os.getenv("DIALPLAN_LIB_BASE_PATH") or "/etc/asterisk/dialplan/";

    ["mongo"] = {
    	["host"] = "mongodb";
    	["dbname"] = "masterclass";
    	["collection"] = "ivrs";
	};

	["redis"] = {
		["host"] = "redis";
		["port"] = "6379";
	};

	["ivrs"] = {
		["url"] = "http://manager/ivrs"
	};
}


return config;