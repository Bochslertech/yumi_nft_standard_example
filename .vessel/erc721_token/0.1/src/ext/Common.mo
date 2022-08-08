import Result "mo:base/Result";

import ExtCore "./Core";

module ExtCommon = {
  type Result<Ok, Err> = Result.Result<Ok, Err>;

  type TokenIdentifier = ExtCore.TokenIdentifier;
  type Balance = ExtCore.Balance;

  type CommonError = ExtCore.CommonError;

  public type Metadata = {
    #fungible : {
      name : Text;
      symbol : Text;
      decimals : Nat8;
      metadata : ?Blob;
    };
    #nonfungible : {
      metadata : ?Blob;
    };
  };

  public type Service = actor {
    metadata : query (token : TokenIdentifier) -> async Result<Metadata, CommonError>;
    supply : query (token : TokenIdentifier) -> async Result<Balance, CommonError>;
  };
};
