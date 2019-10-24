
# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :logger, level: :info

config :tum, Tum,
  genesis: %{
    height: 1,
    previous_hash: "",
    hash: "000005C200F2757372A811C054820D0D7FD5D6C76F6DBE9657A403E7FBD08920",
    difficulty: 5,
    message: "TUM Genesis",
    nounce: 80685,
    public_key: "0457727F916E061490C44BF6595CDE875CC475D5AFAC2196BF69600BF2514D845448DAC3F87C5BCFEC1C1FBE9CAAE8B6A237068B1F61F37A07B9A630351E234FF1",
    signature: "3045022047CE5617727A7CCB245F432931CC2228C364AB799A4AFC00C36E50F8AEDBE51D022100BF2CC76A5A102C03CA3AB70F1817A8DEA1E361637F0BD28DF4FE436D7499FA1B"
  },
  difficulty: 1

config :tum, Tum.Vault,
  [private_key: System.get_env("TUM_PRIVATE_KEY")]

config :tum, Tum.Network,
  [mdns: false]
