defmodule NabooWeb.Layouts.View do
  use Phoenix.View, root: "lib/naboo_web", path: "layouts/templates", namespace: NabooWeb
  use Phoenix.HTML

  import Phoenix.Controller, only: [get_flash: 2]

  alias NabooWeb.Router.Helpers, as: Routes
end
