import ExtCore "./Core";

module ExtFee = {
  type User = ExtCore.User;
  type SubAccount = ExtCore.SubAccount;

  type TokenIdentifier = ExtCore.TokenIdentifier;
  type Balance = ExtCore.Balance;

  type Memo = ExtCore.Memo;

  public type TransferRequest = {
    from : User;
    to : User;
    token : TokenIdentifier;
    amount : Balance;
    fee : Balance;
    memo : Memo;
    notify : Bool;
    subaccount : ?SubAccount;
  };

  public type Service = actor {
    fee : (token : TokenIdentifier) -> async ();
  }
};
