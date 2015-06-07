package {
    import flash.events.Event;

    public class DHDataEvent extends Event {
        public var userData:Object;

        public function DHDataEvent(type:String, userData:Object, bubbles:Boolean=false,
                                  cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.userData = userData;
        }

        public override function clone():Event {
            return new DHDataEvent(type, userData, bubbles, cancelable);
        }
    }
}
