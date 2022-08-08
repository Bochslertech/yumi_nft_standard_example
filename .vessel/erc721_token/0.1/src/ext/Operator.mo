import Result "mo:base/Result";

import ExtCore "./Core";

module ExtOperator = {
  type Result<Ok, Err> = Result.Result<Ok, Err>;

  type User = ExtCore.User;
  type SubAccount = ExtCore.SubAccount;

  type TokenIdentifier = ExtCore.TokenIdentifier;
  type Balance = ExtCore.Balance;

  type CommonError = ExtCore.CommonError;

  public type Tokens = {
    // all tokens for all balances
    #All;
    // null balance = for all balance of that token
    #Some : (TokenIdentifier, ?Balance);
  };

  public type OperatorAction = {
    #SetOperator : Tokens;
    // null removes from all
    #RemoveOperator : ?[TokenIdentifier];
  };

  public type OperatorRequest = {
    subaccount : ?SubAccount;
    operators : [(Principal, OperatorAction)]
  };

  public type OperatorResponse = Result<(), {
    #Unauthorized;
  }>;

  public type IsAuthorizedRequest = {
    owner : User;
    operator : Princpal;
    token : TokenIdentifier
    amount : Balance;
  };

  public type ValidActor = actor {
    updateOperator : shared (request : OperatorRequest) -> async OperatorResponse;
    isAuthorized : shared (request : IsAuthorizedRequest) -> async Result<Bool, CommonError>;
  };
};
