defmodule NabooAPI.ChangesetView do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  def render("error.json", %{changeset: changeset}) do
    errors =
      Enum.map(changeset.errors, fn {field, detail} ->
        %{
          field: field,
          detail: render_detail(detail)
        }
      end)

    %{errors: errors}
  end

  def render_detail({message, values}) do
    Enum.reduce(values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end)
  end

  def render_detail(message), do: message
end
