package {
    import org.flixel.*;

    public class GameObject extends FlxSprite {
        protected var pos:DHPoint, dir:DHPoint, swapPos:DHPoint;
        private var _parent:GameObject;
        protected var bornTime:Number, timeAlive:Number, curTime:Number;
        public var zSorted:Boolean = false;
        public var basePos:DHPoint, basePosOffset:DHPoint;

        public function GameObject(pos:DHPoint, parent:GameObject=null) {
            super(pos.x, pos.y);
            this.pos = new DHPoint(pos.x, pos.y);
            this.swapPos = new DHPoint(0, 0);
            this.dir = new DHPoint(0, 0);
            this._parent = parent;
            this.bornTime = new Date().valueOf();
            this.basePos = new DHPoint(0, 0);
            this.moves = false;
        }

        public function get parent():GameObject {
            return this._parent;
        }

        public function set parent(g:GameObject):void {
            this._parent = g;
        }

        public function setDir(d:DHPoint):void {
            this.dir = d;
        }

        public function getDir():DHPoint {
            return this.dir;
        }

        override public function update():void {
            super.update();
            this.curTime = new Date().valueOf();
            this.timeAlive = this.curTime - this.bornTime;
            this.setPos(this.pos.add(this.dir, this.swapPos));
        }

        public function addVisibleObjects():void { }

        public function setPos(pos:DHPoint):void {
            this.x = pos.x;
            this.y = pos.y;
            this.pos.x = this.x;
            this.pos.y = this.y;
            if (this.basePosOffset != null) {
                this.basePos.x = this.pos.x + this.basePosOffset.x;
                this.basePos.y = this.pos.y + this.basePosOffset.y;
            } else {
                this.basePos.x = this.pos.x + this.width / 2;
                this.basePos.y = this.pos.y + this.height;
            }
        }

        public function getPos():DHPoint {
            return this.pos;
        }

        public function getMiddle():DHPoint {
            return new DHPoint(this.x + this.width / 2,
                               this.y + this.height / 2);
        }

        public function _getRect():FlxRect {
            return new FlxRect(this.x, this.y, this.width, this.height);
        }
    }
}

