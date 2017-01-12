defmodule Absinthe.Subscriptions do
  def publish_from_mutation(endpoint, field_res, mutation_result) do
    subscribed_fields = get_subscription_fields(field_res)

    root_value = Map.new(subscribed_fields, fn {field, _} ->
      {field, mutation_result}
    end)

    for {field, _} <- subscribed_fields,
    {topic, doc} <- get_docs(endpoint, field) do

      pipeline = [
        {Absinthe.Phase.Document.Execution.Resolution, root_value: root_value},
        Absinthe.Phase.Document.Result,
      ]

      {:ok, data, _} = Absinthe.Pipeline.run(doc, pipeline)
      endpoint.broadcast!(topic, "subscription:data", data)
    end
  end

  defp get_subscription_fields(field_res) do
    field_res.definition.schema_node.triggers
  end

  defp get_docs(endpoint, field) do
    Absinthe.SubscriptionManager.subscriptions(endpoint, field)
  end
end
