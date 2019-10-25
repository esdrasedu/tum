defmodule Tum.ProofOfWorkTest do
  use ExUnit.Case
  doctest Tum.ProofOfWork

  alias Tum.{Block, ProofOfWork, Vault}

  setup do
    genesis = %Block{
      height: 1,
      previous_hash: "",
      hash: "000005C200F2757372A811C054820D0D7FD5D6C76F6DBE9657A403E7FBD08920",
      difficulty: 5,
      message: "TUM Genesis",
      nounce: 80685,
      public_key: "0457727F916E061490C44BF6595CDE875CC475D5AFAC2196BF69600BF2514D845448DAC3F87C5BCFEC1C1FBE9CAAE8B6A237068B1F61F37A07B9A630351E234FF1",
      signature: "3045022047CE5617727A7CCB245F432931CC2228C364AB799A4AFC00C36E50F8AEDBE51D022100BF2CC76A5A102C03CA3AB70F1817A8DEA1E361637F0BD28DF4FE436D7499FA1B"
    }

    difficulty = 1
    {:ok, %{genesis: genesis, difficulty: difficulty}}
  end

  test "hash structure" do
    block = %Block{
      height: 0,
      previous_hash: "previous hash",
      difficulty: 1,
      message: "Pickle Rick",
      nounce: 42
    }
    hash = "#{block.height}#{block.previous_hash}#{block.difficulty}#{block.message}#{block.nounce}"
    |> Vault.hash()
    assert hash == ProofOfWork.hash(block)
  end

  test "valid block", %{genesis: genesis, difficulty: difficulty} do
    block = %Block{
      height: 2,
      hash: "0BFC78176C1D9DBD37E283BC5582C3E9EA108C50C112C6F19F3F6CE7CF0F312F",
      previous_hash: genesis.hash,
      difficulty: 1,
      message: "",
      nounce: 49,
      public_key: "049B160D7AC916A7F04AD06B66C886C3F1A51BA49A219F2081FFF7888CF45BA2AEF38FF8210B54CC77A873322C9E49E03F915464A2B05CF08839E945BE1307BC2B",
      signature: "30460221008D45E9D4BAFB9C2E47B52CBFDC17752CB73C72770910E035D6116617DD326AED0221008AA89451A2E2E7F149F1EFFFDAD258A00903E012EE5A632A2771CC8F5D1E4D0F"
    }
    {:ok, _block} = ProofOfWork.is_valid?(block, genesis, difficulty)
  end

  test "block with invalid hash", %{genesis: genesis, difficulty: difficulty} do
    block = %Block{
      difficulty: 1,
      hash: "00FC78176C1D9DBD37E283BC5582C3E9EA108C50C112C6F19F3F6CE7CF0F312F",
      height: 2,
      message: "",
      nounce: 49,
      previous_hash: "000005C200F2757372A811C054820D0D7FD5D6C76F6DBE9657A403E7FBD08920",
      public_key: "04233093343D636C49AD15A0A8B97680AA6AE0BCA59DE4608FAD3751018364DCA21ADE18FF45AF9CBB92BBB4E82D994EA8275DE6E1BACA82E06DDD17490F37D854",
      signature: "304502205EDAD4FDBA2ED2BF880C9783991B65CE04AC07644E93EAD8872D209CB4349266022100A89C837C753200533527DC88AECB2D18650071F3D191F860DC10603B27BD37F2"
    }
    {:error, [:block_hash_invalid]} = ProofOfWork.is_valid?(block, genesis, difficulty)
  end

  test "block with invalid previous_hash", %{genesis: genesis, difficulty: difficulty} do
    block = %Block{
      difficulty: 1,
      hash: "0E31A571768D72D42C2D88C5AD2F4D624F002CE5A5FBA145424101D484F34597",
      height: 2,
      message: "",
      nounce: 61,
      previous_hash: "fake hash",
      public_key: "04E06A991B6AA18197BC5211C6A21C8EE1A4B4CB9C29D92CB1D5AA116787562A65047812F6CBFAC3E93C3E7B8223B60BB4F7F0B3F5A7D7746413541C1F4EB03D1C",
      signature: "304502200A038F882D629CB23810940AE71A7D0DBB7DE14A0F7077C79F489CF5CDFE12570221009A205524600126EED0ED396D6945ADFA35E8FFBCE7304567A593D1831771FFE7"
    }
    {:error, [:previous_hash_invalid]} = ProofOfWork.is_valid?(block, genesis, difficulty)
  end

  test "block with invalid difficulty", %{genesis: genesis, difficulty: difficulty} do
    block = %Block{
      difficulty: 0,
      hash: "2A4DBC61D90D24DA1B65A730425F2D8BC2064271EF00F3413A9882A0F062067A",
      height: 2,
      message: "",
      nounce: 0,
      previous_hash: "000005C200F2757372A811C054820D0D7FD5D6C76F6DBE9657A403E7FBD08920",
      public_key: "040A16FC8763E6E736C0043EB93ECB5D698A09038ECE14C14E2AE7B099CB70AD92491A1B293D8060B59235EE743F315A1264E6DBDE271D74E45B0046F6F1AC268C",
      signature: "30440220286750E47FBF431E8E7E67D5D842DC88769CF53B73DD51639C51C8F63ED175AE022075B1C7384F4B0F6A97A08F70EC7E92F46AB8D69AA2C3DDB6313A83DB015C1A50"
    }
    {:error, [:block_difficulty_invalid]} = ProofOfWork.is_valid?(block, genesis, difficulty)
  end

  test "block with invalid signature", %{genesis: genesis, difficulty: difficulty} do
    block = %Block{
      height: 2,
      hash: "0BFC78176C1D9DBD37E283BC5582C3E9EA108C50C112C6F19F3F6CE7CF0F312F",
      previous_hash: genesis.hash,
      difficulty: 1,
      message: "",
      nounce: 49,
      public_key: "049B160D7AC916A7F04AD06B66C886C3F1A51BA49A219F2081FFF7888CF45BA2AEF38FF8210B54CC77A873322C9E49E03F915464A2B05CF08839E945BE1307BC2B",
      signature: "40460221008D45E9D4BAFB9C2E47B52CBFDC17752CB73C72770910E035D6116617DD326AED0221008AA89451A2E2E7F149F1EFFFDAD258A00903E012EE5A632A2771CC8F5D1E4D0F"
    }
    {:error, [:block_sign_invalid]} = ProofOfWork.is_valid?(block, genesis, difficulty)
  end

  test "valid chain" do
    blocks = [
    %{
      difficulty: 1,
      hash: "0BB00A200128BA9362274F1E0CF1D7DF16143D676F99DB62C7229843FBC5E337",
      height: 1,
      message: "Tum Genesis",
      nounce: 31,
      previous_hash: "1",
      public_key: "04DD9D4934E842E7A0264482DCB1E02B0793AF89DEAB4BC31F225F1C9493BA41FB6490635C19CECCFB17A1E92BAC3E4C971112C723A38DA0CC093D27AE12E12C02",
      signature: "3045022100E570A4C179C6D43F36EB8CEAC4FAA06CB1AB422FF2949F57B65E492A0E395E23022050E661D965507F473761DFE71A5847E9C5BDB16AA1B06EDFE5019961F7BBE0D7"
    },
    %Block{
      difficulty: 1,
      hash: "02BAD8C88564C54F18C7EAE98B58C73A4EAA1A539A44210BAE30A2B761A34CA7",
      height: 2,
      message: "Block 2",
      nounce: 29,
      previous_hash: "000005C200F2757372A811C054820D0D7FD5D6C76F6DBE9657A403E7FBD08920",
      public_key: "0457727F916E061490C44BF6595CDE875CC475D5AFAC2196BF69600BF2514D845448DAC3F87C5BCFEC1C1FBE9CAAE8B6A237068B1F61F37A07B9A630351E234FF1",
      signature: "30460221009D99ABAC672E011DA3333C9A288B7704A2DEB44E8EEF45E5EE14801DDCB1D724022100E829A5948ED6D63A72786F36E43A74372C8CD7D3ECEF27A10A3D5AB2A09A72F7"
    },
    %Block{
      difficulty: 1,
      hash: "022BFA786A1F5EFF61497B7515ACA599D4F22F03499F6E191DE58516089010A5",
      height: 3,
      message: "Block 3",
      nounce: 39,
      previous_hash: "02BAD8C88564C54F18C7EAE98B58C73A4EAA1A539A44210BAE30A2B761A34CA7",
      public_key: "0457727F916E061490C44BF6595CDE875CC475D5AFAC2196BF69600BF2514D845448DAC3F87C5BCFEC1C1FBE9CAAE8B6A237068B1F61F37A07B9A630351E234FF1",
      signature: "304402201900AEA45825C20D454CE3CFE0EA612ABE2D175CD20CE96CE33C9463985414D202203F6AEB6912A55ADCD95E3608B55E072F844662C916AC0220B4C29964AE221A00"
    }
    ]
    {:ok, _blocks} = ProofOfWork.is_valid?(blocks, 1)
  end

  test "wrong sort chain" do
    blocks = [
      %{
        difficulty: 5,
        hash: "000005C200F2757372A811C054820D0D7FD5D6C76F6DBE9657A403E7FBD08920",
        height: 1,
        message: "TUM Genesis",
        nounce: 80685,
        previous_hash: "",
        public_key: "0457727F916E061490C44BF6595CDE875CC475D5AFAC2196BF69600BF2514D845448DAC3F87C5BCFEC1C1FBE9CAAE8B6A237068B1F61F37A07B9A630351E234FF1",
        signature: "3045022047CE5617727A7CCB245F432931CC2228C364AB799A4AFC00C36E50F8AEDBE51D022100BF2CC76A5A102C03CA3AB70F1817A8DEA1E361637F0BD28DF4FE436D7499FA1B"
      },
      %Block{
        difficulty: 1,
        hash: "022BFA786A1F5EFF61497B7515ACA599D4F22F03499F6E191DE58516089010A5",
        height: 3,
        message: "Block 3",
        nounce: 39,
        previous_hash: "02BAD8C88564C54F18C7EAE98B58C73A4EAA1A539A44210BAE30A2B761A34CA7",
        public_key: "0457727F916E061490C44BF6595CDE875CC475D5AFAC2196BF69600BF2514D845448DAC3F87C5BCFEC1C1FBE9CAAE8B6A237068B1F61F37A07B9A630351E234FF1",
        signature: "304402201900AEA45825C20D454CE3CFE0EA612ABE2D175CD20CE96CE33C9463985414D202203F6AEB6912A55ADCD95E3608B55E072F844662C916AC0220B4C29964AE221A00"
      },
      %Block{
        difficulty: 1,
        hash: "02BAD8C88564C54F18C7EAE98B58C73A4EAA1A539A44210BAE30A2B761A34CA7",
        height: 2,
        message: "Block 2",
        nounce: 29,
        previous_hash: "000005C200F2757372A811C054820D0D7FD5D6C76F6DBE9657A403E7FBD08920",
        public_key: "0457727F916E061490C44BF6595CDE875CC475D5AFAC2196BF69600BF2514D845448DAC3F87C5BCFEC1C1FBE9CAAE8B6A237068B1F61F37A07B9A630351E234FF1",
        signature: "30460221009D99ABAC672E011DA3333C9A288B7704A2DEB44E8EEF45E5EE14801DDCB1D724022100E829A5948ED6D63A72786F36E43A74372C8CD7D3ECEF27A10A3D5AB2A09A72F7"
      }
    ]
    {:error, _errors} =  ProofOfWork.is_valid?(blocks, 1)
  end

  test "wrong genesis" do
    blocks = [
      %{
        difficulty: 5,
        hash: "000005C200F2757372A811C054820D0D7FD5D6C76F6DBE9657A403E7FBD08920",
        height: 1,
        message: "TUM Genesis",
        nounce: 80685,
        previous_hash: "",
        public_key: "0457727F916E061490C44BF6595CDE875CC475D5AFAC2196BF69600BF2514D845448DAC3F87C5BCFEC1C1FBE9CAAE8B6A237068B1F61F37A07B9A630351E234FF1",
        signature: "3045022047CE5617727A7CCB245F432931CC2228C364AB799A4AFC00C36E50F8AEDBE51D022100BF2CC76A5A102C03CA3AB70F1817A8DEA1E361637F0BD28DF4FE436D7499FA1B"
      },
      %Block{
        difficulty: 1,
        hash: "09F02BC79A380A12B138D802FAE9566A3B3E3F56D5E450BE7CD9D384AF036250",
        height: 2,
        message: "Block 1",
        nounce: 10,
        previous_hash: "0BB00A200128BA9362274F1E0CF1D7DF16143D676F99DB62C7229843FBC5E337",
        public_key: "04DD9D4934E842E7A0264482DCB1E02B0793AF89DEAB4BC31F225F1C9493BA41FB6490635C19CECCFB17A1E92BAC3E4C971112C723A38DA0CC093D27AE12E12C02",
        signature: "30450220333046A3DB91327C84312E16B0ED1D5637BB4C14B43CFA7E95A2F1FC54B0339D022100F5AE8A7CADB2C480921323AB76F88466092CDC6E948C1BFA9E19D34B036AF5C3"
      }
    ]
    {:ok, _blocks} = ProofOfWork.is_valid?(blocks, 1)
  end

end
