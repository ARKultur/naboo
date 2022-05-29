defmodule NabooAPI.ErrorsTest do
  use Naboo.DataCase, async: true

  import Phoenix.View, only: [render_to_string: 3]

  test "renders 404.json" do
    assert render_to_string(NabooAPI.Views.Errors, "404.json", []) =~ "could not find resource"
  end

  test "render 500.json" do
    assert render_to_string(NabooAPI.Views.Errors, "500.json", []) =~ "something went terribly wrong"
  end

  test "render any other" do
    assert render_to_string(NabooAPI.Views.Errors, "505.json", []) == "\"HTTP Version Not Supported\""
  end
end
