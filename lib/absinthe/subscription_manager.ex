defmodule Absinthe.SubscriptionManager do
  use GenServer

  import Record

  defstruct [
    :ets,
    :endpoint
  ]

  defrecord :subscription, [
    :field,
    :topic,
    :doc, 
    :subscriber,
  ]

  def name(endpoint) do
    Module.concat(Absinthe.Subscriptions, endpoint)
  end

  def start_link(endpoint) do
    GenServer.start_link(__MODULE__, endpoint, [name: name(endpoint)])
  end

  def subscribe(endpoint, field, topic, doc, pid \\ self()) do
    record = subscription(
      field: field,
      topic: topic,
      doc: doc,
      subscriber: pid,
    )

    :ok = GenServer.call(name(endpoint), {:monitor, pid})
    true = :ets.insert(name(endpoint), record)

    :ok
  end

  def subscriptions(endpoint, field) do
    endpoint
    |> name
    |> :ets.select([{{:_, field, :'$0', :'$1', :_}, [], [{{:'$0', :'$1'}}]}])
    |> :maps.from_list
    |> :maps.to_list
  end

  def init(endpoint) do
    ets = :ets.new(name(endpoint), [
      :bag,
      :public,
      :named_table,
      keypos: 2,
      read_concurrency: true,
      write_concurrency: true,
    ])

    state = %__MODULE__{
      endpoint: endpoint,
      ets: ets,
    }

    {:ok, state}
  end

  def handle_call({:monitor, pid}, _from, state) do
    Process.monitor(pid)
    {:reply, :ok, state}
  end

  def handle_info({:DOWN, _ref, _type, pid, _info}, state) do
    true = :ets.match_delete(state.ets, {:_, :_, :_, pid})
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
