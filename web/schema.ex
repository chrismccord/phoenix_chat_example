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
    field :foo, :string
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

      resolve fn %{message: msg}, _, _ ->
        IO.puts "executing doc"
        {:ok, msg}
      end
    end
  end

  mutation do
    field :send_message, :message do
      arg :room, non_null(:string)
      arg :body, non_null(:string)
      arg :user, non_null(:string)

      resolve fn args, _ ->
        message = %{
          room: args.room,
          body: args.body,
          author: %{name: args.user}
        }
        {:ok, message}
      end
    end
  end


end
