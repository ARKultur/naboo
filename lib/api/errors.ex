defmodule NabooAPI.Errors do
  alias NabooAPI.Views.Errors

  @doc """
  Generates a human-readable block containing all errors in a changeset. Errors
  are then localized using translations in the `ecto` domain.
  For example, you could have an `errors.po` file in the french locale:
  ```
  msgid ""
  msgstr ""
  "Language: fr"
  msgid "can't be blank"
  msgstr "ne peut être vide"
  ```
  """

  def error_messages(changeset) do
    changeset
    |> convert_errors_to_json(changeset.data.__struct__)
  end

  defp convert_errors_to_json(errors, schema) do
    errors = Enum.reduce(errors, [], &convert_error_field(&1, &2, schema))

    Errors.render("error_messages.json", %{errors: errors})
  end

  defp convert_error_field({field, errors}, memo, schema) when is_list(errors) do
    memo ++ Enum.flat_map(errors, &convert_error_subfield(&1, field, [], schema))
  end

  defp convert_error_field({field, errors}, memo, schema) when is_map(errors) do
    memo ++ Enum.flat_map(Map.keys(errors), &convert_error_subfield(&1, field, errors[&1], schema))
  end

  defp convert_error_subfield(message, field, _, _schema) when is_binary(message) do
    # NOTE `schema` is available here if we want to use something like
    # `schema.humanize_field(field)` to be able to display `"Email address is
    # invalid"` instead of `email is invalid"`.
    ["#{field} #{message}"]
  end

  defp convert_error_subfield(message, field, memo, schema) when is_map(message) do
    Enum.reduce(message, memo, fn {subfield, errors}, memo ->
      memo ++ convert_error_field({"#{field}.#{subfield}", errors}, memo, schema)
    end)
  end

  defp convert_error_subfield(subfield, field, errors, schema) do
    field = "#{field}.#{subfield}"
    convert_error_field({field, errors}, [], schema)
  end
end
