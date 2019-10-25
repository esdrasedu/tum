defmodule Tum.VaultTest do
  use ExUnit.Case
  doctest Tum.Vault

  alias Tum.Vault

  test "create random keys" do
    {:ok, pid} = Vault.start_link([private_key: nil])
    private_key = Vault.private_key(pid)
    public_key = Vault.public_key(pid)
    assert is_bitstring(private_key)
    assert is_bitstring(public_key)
  end

  test "create specifc key" do
    args = [private_key: "7BB9CCC61415C1E4BDC9888FAC2B2FFE333AF728AFE8E7322E5B918A50D194C9"]
    {:ok, pid} = Vault.start_link(args)
    private_key = Vault.private_key(pid)
    public_key = Vault.public_key(pid)
    assert private_key == "7BB9CCC61415C1E4BDC9888FAC2B2FFE333AF728AFE8E7322E5B918A50D194C9"
    assert public_key == "04764DBCFA88C1FD1E3E7DB6FEE9CA6B79161D6B561B4BFCD293D9AF77B9C7BAB0F58D7A9FCAB7D123D53D1F97FED931970D8481DBE76320C86E32C1E3245B8E70"
  end

  test "hash message" do
    hash = Vault.hash("Welcome to Elixir Camp")
    assert hash == "8674D4FB0069E708E22015C507688263CD4C22C77F0FB501A3FE413C626F4949"
  end

  test "sign and valid message" do
    {:ok, pid} = Vault.start_link()
    message = "Welcome to Elixir Camp"
    public_key = Vault.public_key(pid)
    signature = Vault.sign(pid, message)
    assert Vault.is_valid?(message, signature, public_key)
  end

end
