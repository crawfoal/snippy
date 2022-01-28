# Findings and Notes from OTEL Exploration

## Getting Started; Manual Router Instrumentation

Following the official [OpenTelemetry getting started guide for Erlang/Elixir](https://opentelemetry.io/docs/instrumentation/erlang/getting-started/), I added the following code to my router:

```elixir
# lib/snippy/router.ex

defmodule Snippy.Router do
  use Plug.Router

  require OpenTelemetry.Tracer, as: Tracer

  ...

  get "/snippets/:id" do
    Tracer.with_span "GET /snippets/:id" do
      case Snippets.by_id(conn.params["id"]) do
        %Snippet{} = snippet ->
          Tracer.add_event("Snippet found!", [{"id", snippet.id}])
          Tracer.set_attributes([{:created_at, snippet.created_at}])
          Tracer.with_span("rendering template snippets/show.html") do
            render(conn, "snippets/show.html", [snippet: snippet])
          end
        _ ->
          send_resp(conn, 404, "not found")
      end
    end
  end

  ...

end
```

The route was already there, the `Tracer` stuff was added. There was also some
other setup / configuration. I used the stdout otel exporter, and hitting that
endpoint resulted in logs that look like this:

```
10:41:53.018 [info]  Exporter :otel_exporter_stdout successfully initialized
*SPANS FOR DEBUG*
{span,104901750976216822064294109682881232763,16223624244574451164,[],
      9326832361540470184,<<"rendering template snippets/show.html">>,
      internal,-576460719169640000,-576460719168955000,
      {attributes,128,infinity,0,#{}},
      {events,128,128,infinity,0,[]},
      {links,128,128,infinity,0,[]},
      undefined,1,false,
      {instrumentation_library,<<"snippy">>,<<"0.1.0">>,undefined}}
{span,104901750976216822064294109682881232763,9326832361540470184,[],
      undefined,<<"GET /snippets/:id">>,internal,-576460719172646000,
      -576460719168949000,
      {attributes,128,infinity,0,#{created_at => 1643391740}},
      {events,128,128,infinity,0,
              [{event,1643391740262977000,<<"Snippet found!">>,
                      {attributes,128,infinity,0,#{<<"id">> => 0}}}]},
      {links,128,128,infinity,0,[]},
      undefined,1,false,
      {instrumentation_library,<<"snippy">>,<<"0.1.0">>,undefined}}
```

Next, I plan to try out the Cowboy instrumentation.

## Trying Cowboy Instrumentation

This wasn't as clear to me how get things set up. Here is what I did:

Add `{:opentelemetry_cowboy, "~> 0.1.0"}` to mix.exs.

Add `:opentelemetry_cowboy.setup()` to the top of `Snippy.Application.start/2`.

In `config/config.exs`, add the following:

```elixir
config :plug_cowboy,
  stream_handlers: [:cowboy_telemetry_h, :cowboy_stream_h]
```

The output was similar to before (but now we didn't have to manually instrument
anything):

```
13:32:31.753 [info]  Exporter :otel_exporter_stdout successfully initialized
*SPANS FOR DEBUG*
{span,229444313604941404299956659992245096523,14807930922232316523,[],
      undefined,<<"HTTP GET">>,internal,-576460731814122000,
      -576460731793944000,
      {attributes,128,infinity,0,
                  #{'http.client_ip' => <<"127.0.0.1">>,
                    'http.flavor' => '1.1','http.host' => <<"localhost">>,
                    'http.host.port' => 4001,'http.method' => <<"GET">>,
                    'http.request_content_length' => 0,
                    'http.response_content_length' => 368,
                    'http.scheme' => <<"http">>,'http.status' => <<"200 OK">>,
                    'http.target' => <<"/">>,
                    'http.user_agent' =>
                        <<"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36">>,
                    'net.host.ip' => <<"127.0.0.1">>,
                    'net.transport' => 'IP.TCP'}},
      {events,128,128,infinity,0,[]},
      {links,128,128,infinity,0,[]},
      {status,error,<<>>},
      1,false,
      {instrumentation_library,<<"opentelemetry_cowboy">>,<<"0.1.0">>,
                               undefined}}
*SPANS FOR DEBUG*
{span,59671832927772628504598497512751237439,2899088774407480155,[],undefined,
      <<"HTTP POST">>,internal,-576460697619661000,-576460697607387000,
      {attributes,128,infinity,0,
                  #{'http.client_ip' => <<"127.0.0.1">>,
                    'http.flavor' => '1.1','http.host' => <<"localhost">>,
                    'http.host.port' => 4001,'http.method' => <<"POST">>,
                    'http.request_content_length' => 21,
                    'http.response_content_length' => 77,
                    'http.scheme' => <<"http">>,
                    'http.status' => <<"302 Found">>,
                    'http.target' => <<"/snippets">>,
                    'http.user_agent' =>
                        <<"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36">>,
                    'net.host.ip' => <<"127.0.0.1">>,
                    'net.transport' => 'IP.TCP'}},
      {events,128,128,infinity,0,[]},
      {links,128,128,infinity,0,[]},
      {status,error,<<>>},
      1,false,
      {instrumentation_library,<<"opentelemetry_cowboy">>,<<"0.1.0">>,
                               undefined}}
{span,260920921550751863175829614968274387594,7097891257589533241,[],
      undefined,<<"HTTP GET">>,internal,-576460697605546000,
      -576460697603537000,
      {attributes,128,infinity,0,
                  #{'http.client_ip' => <<"127.0.0.1">>,
                    'http.flavor' => '1.1','http.host' => <<"localhost">>,
                    'http.host.port' => 4001,'http.method' => <<"GET">>,
                    'http.request_content_length' => 0,
                    'http.response_content_length' => 348,
                    'http.scheme' => <<"http">>,'http.status' => <<"200 OK">>,
                    'http.target' => <<"/snippets/0">>,
                    'http.user_agent' =>
                        <<"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36">>,
                    'net.host.ip' => <<"127.0.0.1">>,
                    'net.transport' => 'IP.TCP'}},
      {events,128,128,infinity,0,[]},
      {links,128,128,infinity,0,[]},
      {status,error,<<>>},
      1,false,
      {instrumentation_library,<<"opentelemetry_cowboy">>,<<"0.1.0">>,
                               undefined}}
```
