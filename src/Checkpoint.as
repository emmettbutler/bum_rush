package {
    import org.flixel.*;

    public class Checkpoint extends GameObject{
        private var dimensions:DHPoint;

        public function Checkpoint(pos:DHPoint, dim:DHPoint) {
            super(pos);
            this.dimensions = dim;
            this.makeGraphic(dim.x, dim.y, 0xffff0000);
        }

        override public function addVisibleObjects():void {
            FlxG.state.add(this);
        }
    }
}
