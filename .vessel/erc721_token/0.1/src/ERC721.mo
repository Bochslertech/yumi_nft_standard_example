import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Cycles "mo:base/ExperimentalCycles";
import Result "mo:base/Result";

import AID "./util/AccountIdentifier";
import ExtCore "./ext/Core";
import ExtCommon "./ext/Common";
import ExtAllowance "./ext/Allowance";
import ExtNonFungible "./ext/NonFungible";

shared (install) actor class ERC721(init_minter: Principal) = this {
  type Result<Ok, Err> = Result.Result<Ok, Err>;

  type HashMap<K, V> = HashMap.HashMap<K, V>;

  type AccountIdentifier = ExtCore.AccountIdentifier;
  type User = ExtCore.User;
  type SubAccount = ExtCore.SubAccount;
  type TokenIndex  = ExtCore.TokenIndex;
  type TokenIdentifier = ExtCore.TokenIdentifier;
  type Balance = ExtCore.Balance;
  type BalanceRequest = ExtCore.BalanceRequest;
  type BalanceResponse = ExtCore.BalanceResponse;
  type TransferRequest = ExtCore.TransferRequest;
  type TransferResponse = ExtCore.TransferResponse;
  type AllowanceRequest = ExtAllowance.AllowanceRequest;
  type ApproveRequest = ExtAllowance.ApproveRequest;
  type Metadata = ExtCommon.Metadata;
  type MintRequest  = ExtNonFungible.MintRequest;
  type Extension = ExtCore.Extension;
  type CommonError = ExtCore.CommonError;

  private let EXTENSIONS : [Extension] = [
    "@ext/common",
    "@ext/allowance",
    "@ext/nonfungible",
  ];

  private stable var _registryState : [(TokenIndex, AccountIdentifier)] = [];
  private var _registry : HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_registryState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);

  private stable var _allowancesState : [(TokenIndex, Principal)] = [];
  private var _allowances : HashMap<TokenIndex, Principal> = HashMap.fromIter(_allowancesState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);

  private stable var _tokenMetadataState : [(TokenIndex, Metadata)] = [];
  private var _tokenMetadata : HashMap<TokenIndex, Metadata> = HashMap.fromIter(_tokenMetadataState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);

  private stable var _supply : Balance  = 0;
  private stable var _minter : Principal  = init_minter;
  private stable var _nextTokenId : TokenIndex  = 0;

  system func preupgrade() {
    _registryState := Iter.toArray(_registry.entries());
    _allowancesState := Iter.toArray(_allowances.entries());
    _tokenMetadataState := Iter.toArray(_tokenMetadata.entries());
  };

  system func postupgrade() {
    _registryState := [];
    _allowancesState := [];
    _tokenMetadataState := [];
  };

  public shared(msg) func setMinter(minter : Principal) : async () {
    assert(msg.caller == _minter);
    _minter := minter;
  };

  public shared(msg) func mintNFT(request : MintRequest) : async TokenIndex {
    assert(msg.caller == _minter);
    let receiver = ExtCore.User.toAID(request.to);
    let token = _nextTokenId;
    let md : Metadata = #nonfungible({
      metadata = request.metadata;
    });
    _registry.put(token, receiver);
    _tokenMetadata.put(token, md);
    _supply := _supply + 1;
    _nextTokenId := _nextTokenId + 1;
    return token;
  };

  public shared(msg) func transfer(request: TransferRequest) : async TransferResponse {
    if (request.amount != 1) {
      return #err(#Other("Must use amount of 1"));
    };
    if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
      return #err(#InvalidToken(request.token));
    };
    let token = ExtCore.TokenIdentifier.getIndex(request.token);
    let owner = ExtCore.User.toAID(request.from);
    let spender = AID.fromPrincipal(msg.caller, request.subaccount);
    let receiver = ExtCore.User.toAID(request.to);

    switch (_registry.get(token)) {
      case (?token_owner) {
        if(AID.equal(owner, token_owner) == false) {
          return #err(#Unauthorized(owner));
        };
        if (AID.equal(owner, spender) == false) {
          switch (_allowances.get(token)) {
            case (?token_spender) {
              if(Principal.equal(msg.caller, token_spender) == false) {
                return #err(#Unauthorized(spender));
              };
            };
            case (_) {
              // return #err(#Unauthorized(spender));
            };
          };
        };
        _allowances.delete(token);
        _registry.put(token, receiver);
        return #ok(request.amount);
      };
      case (_) {
        return #err(#InvalidToken(request.token));
      };
    };
  };

  public shared(msg) func approve(request: ApproveRequest) : async () {
    if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
      return;
    };
    let token = ExtCore.TokenIdentifier.getIndex(request.token);
    let owner = AID.fromPrincipal(msg.caller, request.subaccount);
    switch (_registry.get(token)) {
      case (?token_owner) {
        if(AID.equal(owner, token_owner) == false) {
          return;
        };
        _allowances.put(token, request.spender);
        return;
      };
      case (_) {
        return;
      };
    };
  };

  public query func getMinter() : async Principal {
    _minter;
  };

  public query func extensions() : async [Extension] {
    EXTENSIONS;
  };

  public query func balance(request : BalanceRequest) : async BalanceResponse {
    if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
      return #err(#InvalidToken(request.token));
    };
    let token = ExtCore.TokenIdentifier.getIndex(request.token);
    let aid = ExtCore.User.toAID(request.user);
    switch (_registry.get(token)) {
      case (?token_owner) {
        if (AID.equal(aid, token_owner) == true) {
          return #ok(1);
        } else {
          return #ok(0);
        };
      };
      case (_) {
        return #err(#InvalidToken(request.token));
      };
    };
  };

  public query func allowance(request : AllowanceRequest) : async Result<Balance, CommonError> {
    if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
      return #err(#InvalidToken(request.token));
    };
    let token = ExtCore.TokenIdentifier.getIndex(request.token);
    let owner = ExtCore.User.toAID(request.owner);
    switch (_registry.get(token)) {
      case (?token_owner) {
        if (AID.equal(owner, token_owner) == false) {
          return #err(#Other("Invalid owner"));
        };
        switch (_allowances.get(token)) {
          case (?token_spender) {
            if (Principal.equal(request.spender, token_spender) == true) {
              return #ok(1);
            } else {
              return #ok(0);
            };
          };
          case (_) {
            return #ok(0);
          };
        };
      };
      case (_) {
        return #err(#InvalidToken(request.token));
      };
    };
  };

  public query func bearer(token : TokenIdentifier) : async Result<AccountIdentifier, CommonError> {
    if (ExtCore.TokenIdentifier.isPrincipal(token, Principal.fromActor(this)) == false) {
      return #err(#InvalidToken(token));
    };
    let tokenind = ExtCore.TokenIdentifier.getIndex(token);
    switch (_registry.get(tokenind)) {
      case (?token_owner) {
        return #ok(token_owner);
      };
      case (_) {
        return #err(#InvalidToken(token));
      };
    };
  };

  public query func supply(token : TokenIdentifier) : async Result<Balance, CommonError> {
    #ok(_supply);
  };

  public query func getRegistry() : async [(TokenIndex, AccountIdentifier)] {
    Iter.toArray(_registry.entries());
  };

  public query func getAllowances() : async [(TokenIndex, Principal)] {
    Iter.toArray(_allowances.entries());
  };

  public query func getTokens() : async [(TokenIndex, Metadata)] {
    Iter.toArray(_tokenMetadata.entries());
  };

  public query func metadata(token : TokenIdentifier) : async Result<Metadata, CommonError> {
    if (ExtCore.TokenIdentifier.isPrincipal(token, Principal.fromActor(this)) == false) {
      return #err(#InvalidToken(token));
    };
    let tokenind = ExtCore.TokenIdentifier.getIndex(token);
    switch (_tokenMetadata.get(tokenind)) {
      case (?token_metadata) {
        return #ok(token_metadata);
      };
      case (_) {
        return #err(#InvalidToken(token));
      };
    };
  };

  public func acceptCycles() : async () {
    let available = Cycles.available();
    let accepted = Cycles.accept(available);
    assert (accepted == available);
  };

  public query func availableCycles() : async Nat {
    return Cycles.balance();
  };


  //20211206 add http url
  // private stable var _assetsState = [];
  // private var _assets = HashMap.HashMap<Text, [Blob]>(totalSupply_, Text.equal, Text.hash);
  // private func getPath(tokenIndex : TokenIndex) : Text {
  //   return "/?cc=0&type=thumbnail&tokenid=" # tokenIndex;
  // };

  // // /?cc=0&type=thumbnail&tokenid=
  // public query func http_request(request : Http.Request) : async Http.Response {
  //   let path = request.url;

  // };
}
