let upstream = https://github.com/Bochslertech/package-set/releases/download/v0.1/package-set.dhall sha256:cfe6d0b3a24949fd87ad17a190c447bd7eedc143318506e38c674ee2109ffec9
let Package = { name : Text, version : Text, repo : Text, dependencies : List Text }
let additions = [
  { name = "array"
  , repo = "https://github.com/aviate-labs/array.mo"
  , version = "v0.1.1"
  , dependencies = [ "base" ]
  },
  { name = "hash"
  , repo = "https://github.com/aviate-labs/hash.mo"
  , version = "v0.1.0"
  , dependencies = [ "base" ]
  },
  { name = "encoding"
  , repo = "https://github.com/aviate-labs/encoding.mo"
  , version = "v0.3.0"
  , dependencies = [ "base", "array" ]
  },
  { name = "sha"
  , repo = "https://github.com/aviate-labs/sha.mo"
  , version = "v0.1.1"
  , dependencies = [ "base", "encoding" ]
  },
  { name = "principal"
  , repo = "https://github.com/aviate-labs/principal.mo"
  , version = "v0.2.4"
  , dependencies = [ "array", "base", "hash", "encoding", "sha" ],
  },
  { name = "parser-combinators"
  , repo = "https://github.com/aviate-labs/parser-combinators.mo"
  , version = "v0.1.0"
  , dependencies = ["base"]
  },
  { name = "erc721_token"
  , repo = "https://github.com/Bochslertech/erc721_token"
  , version = "0.1"
  , dependencies = [ "base"]
  },
  { name = "json"
  , repo = "https://github.com/aviate-labs/json.mo"
  , version = "v0.1.2"
  , dependencies = [ "parser-combinators"],
  }
] : List Package
in  upstream # additions