defmodule Chat.Schema do
  use Absinthe.Schema

  object :user do
    field :name, :string
  end

  object :message do
    field :body, :string
    field :author, :user
  end

  query do
  end

  subscription do
    field :message, :message do
      arg :room, non_null(:string)

      topic fn args ->
        args.room
      end

      trigger :send_message, topic: fn message ->
        message.room
      end
    end
  end

  mutation do
    field :send_message, :message do
      arg :room, non_null(:string)
      arg :body, non_null(:string)

      resolve fn args, info ->
        message = Map.put(args, :author, %{name: "Ben Wilson"})
        Absinthe.Subscriptions.publish_from_mutation(Chat.Endpoint, info, message)
        {:ok, message}
      end
    end
  end


end
