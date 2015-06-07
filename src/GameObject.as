package {
    import org.flixel.*;

    public class GameObject extends FlxSprite {
        protected var pos:DHPoint, dir:DHPoint;
        private var _parent:GameObject;
        protected var bornTime:Number, timeAlive:Number, curTime:Number;

        public function GameObject(pos:DHPoint, parent:GameObject=null) {
            super(pos.x, pos.y);
            this.pos = new DHPoint(pos.x, pos.y);
            this._parent = parent;
            this.bornTime = new Date().valueOf();
        }

        public function get parent():GameObject {
            return this._parent;
        }

        override public function update():void {
            super.update();
            this.curTime = new Date().valueOf();
            this.timeAlive = this.curTime - this.bornTime;
        }

        public function addVisibleObjects():void { }

        public function setPos(pos:DHPoint):void {
            this.x = pos.x;
            this.y = pos.y;
            this.pos = new DHPoint(this.x, this.y);
        }

        public function getPos():DHPoint {
            return this.pos;
        }

        public function getMiddle():DHPoint {
            return new DHPoint(this.x + this.width / 2,
                               this.y + this.height / 2);
        }
    }
}

