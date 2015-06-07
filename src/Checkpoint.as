package {
    import org.flixel.*;

    public class Checkpoint extends GameObject{
        [Embed(source="/../assets/AptBuilding_6.png")] private var AptSprite:Class;
        [Embed(source="/../assets/BeerStore_1.png")] private var BoozeSprite:Class;
        [Embed(source="/../assets/Home_1.png")] private var HomeSprite:Class;

        private var dimensions:DHPoint;
        private var idx:Number, frameRate:Number = 12;
        private var checkpoint_sprite:GameObject;

        public static const APARTMENT:String = "booty call spot";
        public static const BOOZE:String = "booze spot";
        public static const HOME:String = "start at home";

        public function Checkpoint(pos:DHPoint, dim:DHPoint, type:String=null) {
            super(pos);
            this.dimensions = dim;
            this.makeGraphic(dim.x, dim.y, 0xffff0000);
            if(type != null) {
                this.checkpoint_sprite = new GameObject(pos);
            }

            switch (type) {
                case null:
                break;

                case Checkpoint.APARTMENT:
                this.checkpoint_sprite.loadGraphic(this.AptSprite, true, false, 768/6, 128);
                this.checkpoint_sprite.addAnimation("play", [0,1,2,3,4,5],
                                                    this.frameRate, true);
                this.checkpoint_sprite.play("play");
                break;

                case Checkpoint.BOOZE:
                this.checkpoint_sprite.loadGraphic(this.BoozeSprite, false, false, 128, 128);
                break;

                case Checkpoint.HOME:
                this.checkpoint_sprite.loadGraphic(this.HomeSprite, false, false, 128, 128);
                break;
            }
        }

        public function get index():Number {
            return this.idx;
        }

        public function set index(n:Number):void {
            this.idx = n;
        }

        public function setImgPos(p:DHPoint):void {
            if(this.checkpoint_sprite != null) {
                this.checkpoint_sprite.setPos(p);
            }
        }

        override public function addVisibleObjects():void {
            FlxG.state.add(this);
            FlxG.state.add(this.checkpoint_sprite);
        }
    }
}
