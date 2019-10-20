
# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :tum, Tum,
  genesis: %{
    height: 1,
    previous_hash: "",
    hash: "0131550D0A277E3B8D4492FFD3CF7D4820AAABC232720A99452821FD7654569B",
    difficulty: 1,
    message: "TUM Genesis",
    nounce: 17,
    public_key: "04A301F3D24CC0602D68C0A394E891138E0E1FE8A1FF380185311537B56559C6F41C44A8124651B251035CBFA9A1988EBDC0F53750F317DDAE6A42295660E6D7A7",
    signature: "304402207797BA2356B0E59A290240218E7A67188D0F54F514ABAF543DF7738C24D887D2022057B04BAC44B6E7256E1C37F3756817F3A95D3B3974FFEB0CDF37DDDC70D71F3C"
  },
  difficulty: 1

config :tum, Tum.Vault,
  [private_key: :undefined]
