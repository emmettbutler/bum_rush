package {
    import org.flixel.*;

    public class Checkpoint extends GameObject{
        private var dimensions:DHPoint;
        private var idx:Number;

        public function Checkpoint(pos:DHPoint, dim:DHPoint) {
            super(pos);
            this.dimensions = dim;
            this.makeGraphic(dim.x, dim.y, 0xffff0000);
        }

        public function get index():Number {
            return this.idx;
        }

        public function set index(n:Number):void {
            this.idx = n;
        }

        override public function addVisibleObjects():void {
            FlxG.state.add(this);
        }
    }
}
