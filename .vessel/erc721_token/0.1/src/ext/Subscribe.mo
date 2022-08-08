import ExtCore "./Core";

module ExtSubscribe = {
  type NotifyCallback = ExtCore.NotifyCallback;

  public type ValidActor = actor {
    subscribe : shared (callback : NotifyCallback) -> ();
    unsubscribe : shared () -> ();
  };
};
