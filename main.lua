local password = assert(require("mysql.password"))
local proto = assert(require("mysql.proto"))

local log_file = '/mysql_query.log'

local fh = io.open(log_file, "a+")

local tokenizer = require("proxy.tokenizer")

function read_query( packet )
    query = ""
    local replacing = false
    if string.byte(packet) == proxy.COM_QUERY then
        query = string.sub(packet, 2)
        if string.match(string.upper(query), '^%s*UPDATE') then
            query = "SELECT 1"
            replacing = true
        end
        if string.match(string.upper(query), '^%s*DELETE') then
            query = "SELECT 1"
            replacing = true
        end
        if string.match(string.upper(query), '^%s*INSERT') then
            query = "SELECT 1"
            replacing = true
        end
        if string.match(string.upper(query), '^%s*TRUNCATE') then
            query = "SELECT 1"
            replacing = true
        end
        -- proxy.queries:append(1, packet, {resultset_is_needed = true} )
        if (replacing) then
            proxy.queries:append(1, string.char(proxy.COM_QUERY) .. query, {resultset_is_needed = true} )
            return proxy.PROXY_SEND_QUERY
        else
            proxy.queries:append(1, packet, {resultset_is_needed = true} )
            return proxy.PROXY_SEND_QUERY
        end

    else
        query = ""
    end
end


function read_query_result (inj)
    local row_count = 0
    local res = assert(inj.resultset)

    local num_cols = string.byte(res.raw, 1)

    if num_cols > 0 and num_cols < 255 then
        for row in inj.resultset.rows do
            row_count = row_count + 1
        end
    end

    local error_status =""

    if not res.query_status or res.query_status == proxy.MYSQLD_PACKET_ERR then
        error_status = "[ERROR]"
    end

    if (res.affected_rows) then
        row_count = res.affected_rows
    end
    --
    -- write the query, adding the number of retrieved rows
    --
    local tokens = tokenizer.tokenize(inj.query:sub(2))
    local norm_query = tokenizer.normalize(tokens)

    fh:write( string.format("%s %6d --%s --%s query-time(%d) rows{%d} %s\n",
        os.date('%Y-%m-%d %H:%M:%S'),
        proxy.connection.server.thread_id,
        proxy.connection.client.default_db,
        query,
        inj.query_time,
        row_count,
        error_status))
    fh:flush()
end
