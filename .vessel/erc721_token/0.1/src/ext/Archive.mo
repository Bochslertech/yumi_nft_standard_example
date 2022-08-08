import Result "mo:base/Result";

import ExtCore "./Core";

module ExtArchive = {
  type Result<Ok, Err> = Result.Result<Ok, Err>;

  type TransferRequest = ExtCore.TransferRequest;

  type CommonError = ExtCore.CommonError;

  public type Date = Nat64;
  public type TransactionId = Nat;

  public type Transaction = {
    txid : TransactionId;
    request : TransferRequest;
    date : Date;
  };

  public type TransactionRequest = {
    query : {
      #txid : TransactionId;
      #user : ExtCore.User;
      // from - to
      #date : (Date, Date);
      // all per page - page
      #page : (Nat, Nat);
      #all;
    }
    token : TokenIdentifier;
  };

  public type ValidActor = actor {
    add : shared (request : TransferRequest) -> TransactionId;
    transactions : query (request : TransactionsRequest) -> async Result<[Transaction], CommonError>;
  };
};
