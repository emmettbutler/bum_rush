package {

    import org.flixel.*;

    public class Meter extends GameObject {
        protected var _innerBar:GameObject, _barFrame:GameObject;
        protected var _maxPoints:Number, _outerWidth:Number = 100,
                      _outerHeight:Number, _curPoints:Number,
                      _curDiff:Number = 0;

        public function Meter(pos:DHPoint,
                              maxPoints:Number,
                              outerWidth:Number=100,
                              outerHeight:Number=6)
        {
            super(pos);

            this._maxPoints = maxPoints;
            this._curPoints = maxPoints;
            this._curDiff = 0;
            this._outerWidth = outerWidth;
            this._outerHeight = outerHeight;

            this._barFrame = new GameObject(pos);
            this._barFrame.makeGraphic(this._outerWidth, this._outerHeight, 0xff7c6e6a);

            this._innerBar = new GameObject(pos);
            this._innerBar.makeGraphic(1, this._outerHeight - 1, 0xffe2678e);
            this._innerBar.scale.x = this._outerWidth * (maxPoints / this._maxPoints);
            this._innerBar.offset.x = -1 * (this._innerBar.scale.x / 2);
        }

        public function setPoints(points:Number):void {
            if (this._curPoints == points) {
                return;
            }
            this._curDiff = (this._curPoints - points) + this._curDiff;
            this._curPoints = points;
            this._innerBar.scale.x = Math.min(this._outerWidth * (points / this._maxPoints), this._outerWidth);
            this._innerBar.offset.x = -1 * (this._innerBar.scale.x / 2);

            if (this.isVisible()){
            } else {
                this._curDiff = 0;
            }
        }

        override public function setPos(pos:DHPoint):void {
            var outerPos:DHPoint = pos.sub(new DHPoint(this._outerWidth / 2, 0));
            this._innerBar.setPos(outerPos);
            this._barFrame.setPos(outerPos);
        }

        override public function getPos():DHPoint {
            return this._barFrame.getPos();
        }

        public function setVisible(v:Boolean):void {
            this._barFrame.visible = v;
            this._innerBar.visible = v;
        }

        public function isVisible():Boolean {
            return this._barFrame.visible;
        }

        override public function addVisibleObjects():void {
            FlxG.state.add(this._barFrame);
            FlxG.state.add(this._innerBar);
        }
    }
}