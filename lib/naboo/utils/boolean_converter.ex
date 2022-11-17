defmodule Naboo.Utils.BooleanConverter do
  def convert!("true"), do: true
  def convert!("false"), do: false
  def convert!(false), do: false
  def convert!(true), do: true
  def convert!(num), do: String.to_integer(num)
end
