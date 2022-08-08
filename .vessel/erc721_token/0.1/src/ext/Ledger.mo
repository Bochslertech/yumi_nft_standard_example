import ExtCore "./Core";

module ExtLedger = {
  type SubAccount = ExtCore.SubAccount;
  type AccountIdentifier = ExtCore.AccountIdentifier;
  type TokenIdentifier = ExtCore.TokenIdentifier;

  public type AccountBalanceArgs = {
    account : AccountIdentifier;
    token : TokenIdentifier;
  };

  public type BlockHeight = Nat64;

  public type ICPTs = { e8s : Nat64 };

  public type SendArgs = {
    to : AccountIdentifier;
    fee : ICPTs;
    memo : Nat64;
    from_subaccount : ?SubAccount;
    created_at_time : ?{ timestamp_nanos : Nat64 };
    amount : ICPTs;
    token : TokenIdentifier;
  };

  public type ValidActor = actor {
    account_balance_dfx : shared query AccountBalanceArgs -> async ICPTs;
    send_dfx : shared SendArgs -> async BlockHeight;
  };
};
