defmodule NabooWeb.Errors.View do
  use Phoenix.View, root: "lib/naboo_web", path: "errors/templates", namespace: NabooWeb

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
