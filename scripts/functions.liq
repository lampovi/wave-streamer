def new_listeners(new, ref_table, url) =
    table = !ref_table
    listeners = string_of(int_of_string(table["listeners"]) + new)
    ref_table := list_assoc_update(table, ("listeners", listeners))
    print("Number of listeners sent: " ^ string_of(listeners) ^ " >>>>> " ^ url)
    ignore(http.post( url, data=listeners,
        headers=[("Content-Type", "text/plain; charset=utf-8")]))
end

def on_listener_connect(ref_table, listeners_url, ~headers, ~uri, ~protocol, client) =
    table = !ref_table
    new_listeners(1, ref_table, listeners_url)
    print("Client " ^ client ^ " connected to stream " ^ string.quote(table["name"]))
end

def on_listener_disconnect(ref_table, listeners_url, client) =
    table = !ref_table
    new_listeners(-1, ref_table, listeners_url)
    print("Client " ^ client ^ " disconnected from stream " ^ string.quote(table["name"]))
end

def send_metadata(url, metadata) =
    json = json_of(compact=true, metadata)
    print("Track data sent: " ^ json ^ " >>>>> " ^ url)
    ignore(http.post( url, data=json,
        headers=[("Content-Type", "application/json; charset=utf-8")]))
end

def send_tables(tables, url) = 
    json = json_of(compact=true, tables)
    # We should send request before the receiver wakes up, because we send
    # tables only once at start
    print("Pray that receiver has already woken up...")
    sleep(10.)
    ignore(http.post( url, data=json,
        headers=[("Content-Type", "application/json; charset=utf-8")]))
    print("Streams data sent: " ^ json ^ " >>>>> " ^ url)
end

def serve_source( source, ref_table, port, listeners_url, encoder) =
    table = !ref_table
    listeners_url = listeners_url % [("s", table["name"])]
    output.harbor(
        mount         = table["mount"],
        format        = table["mime"],
        port          = port,
        encoding      = "UTF-8",
        on_connect    = on_listener_connect(ref_table, listeners_url),
        on_disconnect = on_listener_disconnect(ref_table, listeners_url),
        encoder,
        source
    )
end