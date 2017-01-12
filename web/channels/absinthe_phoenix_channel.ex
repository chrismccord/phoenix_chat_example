defmodule Absinthe.Phoenix.Channel do
  use Phoenix.Channel
  require Logger

  def join("__absinthe__:control", _, socket) do
    {:ok, socket}
  end

  def handle_in("doc", %{"query" => query, "variables" => variables}, socket) do
    config = socket.assigns[:absinthe]

    Logger.info("""
    GraphQL Doc
    #{query}
    """)

    config = put_in(config.opts[:variables], variables)

    handle_doc(query, config, socket)
  end

  def handle_info(%{event: event, payload: payload}, socket) do
    push(socket, event, payload)
    {:noreply, socket}
  end

  def handle_doc(query, config, socket) do
    query
    |> prepare(config)
    |> case do
      {:ok, doc} ->
        doc
        |> classify
        |> execute(doc, query, config, socket)
    end
  end

  defp classify(doc) do
    Absinthe.Blueprint.current_operation(doc).schema_node.__reference__.identifier
  end

  defp execute(:subscription, doc, query, config, socket) do
    hash = :erlang.phash2({query, config})
    topic = "__absinthe__:#{hash}"

    socket.endpoint.subscribe(topic)

    # :ok = Phoenix.PubSub.subscribe(socket.pubsub_server, topic, [
    #   fastlane: {socket.transport_pid, socket.serializer, []},
    #   link: true,
    # ])

    pid = self()
    for field_key <- field_keys(doc) do
      Absinthe.Subscriptions.Manager.subscribe(Chat.Endpoint, field_key, topic, doc, pid)
    end

    {:reply, {:ok, %{ref: topic}}, socket}
  end
  defp execute(_, doc, _query, config, socket) do
    {:ok, result, _} = Absinthe.Pipeline.run(doc, finalization_pipeline(config))
    result |> IO.inspect
    {:reply, {:ok, result}, socket}
  end

  defp field_keys(doc) do
    doc
    |> Absinthe.Blueprint.current_operation
    |> Map.fetch!(:fields)
    |> Enum.map(fn %{schema_node: schema_node, argument_data: argument_data} ->
      name = schema_node.__reference__.identifier
      key = schema_node.topic.(argument_data)

      {name, key}
    end)
  end

  def prepare(query, config) do
    case Absinthe.Pipeline.run(query, preparation_pipeline(config)) do
      {:ok, blueprint, _} ->
        {:ok, blueprint}
    end
  end

  def preparation_pipeline(config) do
    config.schema_mod
    |> Absinthe.Pipeline.for_document(config.opts)
    |> Absinthe.Pipeline.upto(Absinthe.Phase.Document.Flatten)
  end

  def finalization_pipeline(config) do
    [
      {Absinthe.Phase.Document.Execution.Resolution, config.opts},
      Absinthe.Phase.Document.Result,
    ]
  end
end
