defmodule Chat.Controllers.Pages do
  use Phoenix.Controller

  def index(conn, _params) do
    html conn, File.read!(Path.join(["priv/views/index.html"]))
  end
end
