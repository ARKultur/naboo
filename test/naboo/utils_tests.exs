defmodule Naboo.UtilsTests do
  use ExUnit.Case

  alias Naboo.Utils.BooleanConverter

  test "boolean converter utility" do
    assert BooleanConverter.convert!("true") == true
    assert BooleanConverter.convert!(true) == true

    assert BooleanConverter.convert!("false") == false
    assert BooleanConverter.convert!(false) == false

    assert BooleanConverter.convert!("1") == 1
  end
end
