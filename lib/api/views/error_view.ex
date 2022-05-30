defmodule NabooAPI.Views.Errors do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def render("error_messages.json", %{errors: errors}) do
    %{
      errors: errors
    }
  end

  def render("500.json", _) do
    %{
      status: 500,
      message: "something went terribly wrong"
    }
  end

  def render("401.json", _) do
    %{
      status: 401,
      message: "unauthorized"
    }
  end

  def render("404.json", _) do
    %{
      status: 404,
      message: "could not find resource"
    }
  end

  def render("422.json", _) do
    %{
      status: 422,
      message: "unpossessable entity"
    }
  end
end
