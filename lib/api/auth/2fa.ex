defmodule NabooAPI.Auth.TwoFactor do

  def gen_token() do
    :crypto.strong_rand_bytes(8)
    |> Base.encode32()
    |> :pot.hotp(_number_of_trials = 1)
  end

end
