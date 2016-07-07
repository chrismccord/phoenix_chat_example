defmodule Chat.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ChannelTest
      @endpoint Chat.Endpoint
    end
  end
end
