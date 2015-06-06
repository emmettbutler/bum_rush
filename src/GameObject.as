package {
    import org.flixel.*;

    public class GameObject extends FlxSprite {
        protected var pos:DHPoint, dir:DHPoint;

        public function GameObject(pos:DHPoint) {
            super(pos.x, pos.y);
            this.pos = new DHPoint(pos.x, pos.y);
        }

        public function addVisibleObjects():void { }

        public function setPos(pos:DHPoint):void {
            this.x = pos.x;
            this.y = pos.y;
            this.pos = new DHPoint(this.x, this.y);
        }
    }
}

