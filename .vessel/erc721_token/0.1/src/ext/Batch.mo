import Result "mo:base/Result";

import ExtCore "./Core";

module ExtBatch = {
  type Result<Ok, Err> = Result.Result<Ok, Err>;

  type BalanceRequest = ExtCore.BalanceRequest;
  type BalanceResponse = ExtCore.BalanceResponse;

  public type BatchError = {
    #Error : Text;
  };

  public type ValidActor = actor {
    balance_batch : query (request : [BalanceRequest]) -> async Result<[BalanceResponse], BatchError>;
    transfer_batch : shared (request : [TransferRequest]) -> async Result<[TransferResponse], BatchError>;
  };
};
