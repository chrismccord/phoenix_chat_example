defmodule Chat.SubscriptionChannel do
  use Phoenix.Channel
  require Logger

  def join("subscriptions", _, socket) do
    {:ok, socket}
  end

  def handle_in("new", %{"query" => query, "variables" => variables}, socket) do
    config = socket.assigns[:absinthe]

    config = put_in(config.opts[:variables], variables)

    case subscribe_query(query, config, socket) do
      {:ok, ref} ->
        {:reply, {:ok, %{ref: ref}}, socket}
      {:error, errors}->
        {:reply, {:error, errors}, socket}
    end
  end

  def subscribe_query(query, config, socket) do
    query
    |> prepare(config)
    |> case do
      {:ok, doc} ->

        Phoenix.PubSub.subscribe(socket.pubsub_server, socket.topic, [
          fastlane: {socket.transport_pid, socket.serializer, []},
          link: true,
        ])

        field_key = get_field_from_doc(doc)
        hash = :erlang.phash2({query, config})
        topic = "__absinthe_subscriptions__:#{hash}"

        pid = self()
        Absinthe.SubscriptionManager.subscribe(Chat.Endpoint, field_key, topic, doc, pid)
        {:ok, topic}
    end
  end

  defp get_field_from_doc(doc) do
    :message
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
end
