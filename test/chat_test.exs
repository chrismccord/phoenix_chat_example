defmodule ChatTest do
  use ExUnit.Case
  use Phoenix.ChannelTest

  @endpoint Chat.Endpoint

  test "subscriptions" do
    {:ok, socket} = connect(Chat.UserSocket, %{})
    {:ok, _, socket} = subscribe_and_join(socket, Absinthe.Phoenix.Channel, "__absinthe__:control", %{})

    payload = %{
      query: """
      subscription Messages {
        message(room: "lobby") {
          body
          author { name }
        }
      }
      """,
      variables: %{}
    }

    ref = push(socket, "doc", payload)
    assert_reply ref, :ok, %{ref: "__absinthe__:" <> _}

    assert [_] = Absinthe.SubscriptionManager.subscriptions(Chat.Endpoint, {:message, "lobby"})

    mutation = """
    mutation SendMessage($body: String!, $user: String!) {
      sendMessage(room: "lobby", body: $body, user: $user) {
        __typename
      }
    }
    """

    assert {:ok, %{data: _}} = Absinthe.run(mutation, Chat.Schema, variables: %{"body" => "hello world", "user" => "Ben Wilson"})

    assert_push("subscription:data", payload)

    assert payload == %{data: %{"message" => %{"author" => %{"name" => "Ben Wilson"},
      "body" => "hello world"}}}
  end
end
