package {
    import org.flixel.*;

    public class GameObject extends FlxSprite {
        protected var pos:DHPoint, dir:DHPoint;
        private var _parent:GameObject;
        protected var bornTime:Number, timeAlive:Number, curTime:Number;
        protected var debugText:FlxText;
        public var zSorted:Boolean = false;
        public var basePos:DHPoint, basePosOffset:DHPoint;

        public function GameObject(pos:DHPoint, parent:GameObject=null) {
            super(pos.x, pos.y);
            this.pos = new DHPoint(pos.x, pos.y);
            this.dir = new DHPoint(0, 0);
            this._parent = parent;
            this.bornTime = new Date().valueOf();
            this.basePos = new DHPoint(0, 0);

            this.debugText = new FlxText(0, 0, 200, "");
            this.debugText.setFormat(null, 16, 0xffff0000, "left");
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
            this.pos.x = this.x;
            this.pos.y = this.y;
            this.setPos(this.pos.add(this.dir));
            if (this.basePosOffset != null) {
                this.basePos.x = this.pos.x + this.basePosOffset.x;
                this.basePos.y = this.pos.y + this.basePosOffset.y;
            } else {
                this.basePos.x = this.pos.x + this.width / 2;
                this.basePos.y = this.pos.y + this.height;
            }
            this.debugText.x = this.x;
            this.debugText.y = this.y - 30;
        }

        public function addVisibleObjects():void {
            FlxG.state.add(this.debugText);
        }

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

        public function _getRect():FlxRect {
            return new FlxRect(this.x, this.y, this.width, this.height);
        }
    }
}

