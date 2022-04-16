defmodule NabooAPI.Views.Errors do
  use Phoenix.View, root: "lib/api", path: "errors/templates", namespace: NabooAPI

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def render("error_messages.json", %{errors: errors}) do
    %{
      errors: errors
    }
  end
end
