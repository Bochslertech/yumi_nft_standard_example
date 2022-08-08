import Result "mo:base/Result";

import ExtCore "./Core";

module ExtAllowance = {
  type Result<Ok, Err> = Result.Result<Ok, Err>;

  type User = ExtCore.User;
  type SubAccount = ExtCore.SubAccount;

  type TokenIdentifier = ExtCore.TokenIdentifier;
  type Balance = ExtCore.Balance;

  type CommonError = ExtCore.CommonError;

  public type AllowanceRequest = {
    owner : User;
    spender : Principal;
    token : TokenIdentifier;
  };

  public type ApproveRequest = {
    subaccount : ?SubAccount;
    spender : Principal;
    allowance : Balance;
    token : TokenIdentifier;
  };

  public type ValidActor = actor {
    allowance : shared query (request : AllowanceRequest) -> async Result<Balance, CommonError>;
    approve : shared (request : ApproveRequest) -> async ();
  };
};
