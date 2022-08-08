import Result "mo:base/Result";

import ExtCore "./Core";
import ExtCommon "./Common";

module ExtSecure = {
  type Result<Ok, Err> = Result.Result<Ok, Err>;

  type TokenIdentifier = ExtCore.TokenIdentifier;
  type Balance = ExtCore.Balance;
  type BalanceRequest = ExtCore.BalanceRequest;
  type BalanceResponse = ExtCore.BalanceResponse;
  type Metadata = ExtCommon.Metadata;
  type Extension = ExtCore.Extension;

  type CommonError = ExtCore.CommonError;

  public type Service = actor {
    extensions_secure : () -> async [Extension];
    balance_secure : (request : BalanceRequest) -> async BalanceResponse;
    metadata_secure : (token : TokenIdentifier) -> async Result<Metadata, CommonError>;
    supply_secure : (token : TokenIdentifier) -> async Result<Balance, CommonError>;
  };
};
