defmodule ChatTest do
  use ExUnit.Case
  use Phoenix.ChannelTest

  @endpoint Chat.Endpoint

  test "subscriptions" do
    {:ok, socket} = connect(Chat.UserSocket, %{})
    {:ok, _, socket} = subscribe_and_join(socket, Chat.SubscriptionChannel, "subscriptions", %{})

    payload = %{
      query: """
      subscription Messages {
        message(article_id: 1) {
          body
          author { name }
        }
      }
      """,
      variables: %{}
    }

    ref = push(socket, "new", payload)
    assert_reply ref, :ok, %{ref: ref}

    @endpoint.subscribe(ref)

    assert [_] = Absinthe.SubscriptionManager.subscriptions(Chat.Endpoint, :message)

    mutation = """
    mutation CreateMessage {
      message(body: "hello world") {
        __typename
      }
    }
    """

    Absinthe.run(mutation, Chat.Schema)

    assert_broadcast("subscription:data", payload)

    payload |> IO.inspect
  end
end
