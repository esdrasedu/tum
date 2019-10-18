defmodule Tum.Block do

  defstruct [:height, :hash, :previous_hash, :difficulty, :message, :nounce, :public_key, :signature]

  @type t :: %__MODULE__{
    height: Integer.t,
    previous_hash: String.t,
    hash: String.t,
    difficulty: Integer.t,
    message: String.t,
    nounce: Integer.t,
    public_key: String.t,
    signature: String.t
  }

end
