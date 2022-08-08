import Result "mo:base/Result";

import ExtCore "./Core";

module ExtNonFungible = {
  type Result<Ok, Err> = Result.Result<Ok, Err>;

  type User = ExtCore.User;
  type AccountIdentifier = ExtCore.AccountIdentifier;
  type TokenIdentifier = ExtCore.TokenIdentifier;

  type CommonError = ExtCore.CommonError;

  public type MintRequest = {
    to : User;
    metadata : ?Blob;
  };

  public type Service = actor {
    bearer : query (token : TokenIdentifier) -> async Result<AccountIdentifier, CommonError>;
    mintNFT : shared (request : MintRequest) -> async ();
  };
};
