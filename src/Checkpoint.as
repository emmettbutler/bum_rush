package {
    import org.flixel.*;

    public class Checkpoint extends GameObject{
        [Embed(source="/../assets/AptBuilding_6.png")] private var AptSprite:Class;
        [Embed(source="/../assets/BeerStore_1.png")] private var BoozeSprite:Class;
        [Embed(source="/../assets/Home_1.png")] private var HomeSprite:Class;
        [Embed(source="/../assets/Movies.png")] private var MoviesSprite:Class;
        [Embed(source="/../assets/Park.png")] private var ParkSprite:Class;
        [Embed(source="/../assets/Beach.png")] private var BeachSprite:Class;
        [Embed(source="/../assets/Dinner.png")] private var DinnerSprite:Class;
        [Embed(source="/../assets/sfx/getBeer.mp3")] private var CheckpointSFX:Class;

        private var dimensions:DHPoint;
        private var idx:Number, frameRate:Number = 12;
        private var checkpoint_sprite:GameObject;
        private var _cp_type:String;

        public static const APARTMENT:String = "booty call spot";
        public static const BOOZE:String = "booze spot";
        public static const HOME:String = "start at home";
        public static const MOVIES:String = "movie theatre";
        public static const PARK:String = "picnicin";
        public static const BEACH:String = "swimmin";
        public static const DINNER:String = "chowin down";

        private var checkpointSound:FlxSound;

        public function Checkpoint(pos:DHPoint, dim:DHPoint, type:String=null) {
            super(pos);
            this.dimensions = dim;
            if(type != null) {
                this.checkpoint_sprite = new GameObject(pos);
            }

            this.checkpointSound = new FlxSound();
            this.checkpointSound.loadEmbedded(CheckpointSFX,false);
            this.checkpointSound.volume = .1;

            switch (type) {
                case null:
                break;

                case Checkpoint.APARTMENT:
                this.checkpoint_sprite.loadGraphic(this.AptSprite, true, false, 768/6, 128);
                this.checkpoint_sprite.addAnimation("play", [0,1,2,3,4,5],
                                                    this.frameRate, true);
                this.checkpoint_sprite.play("play");
                this._cp_type = Checkpoint.APARTMENT;
                break;

                case Checkpoint.BOOZE:
                this.checkpoint_sprite.loadGraphic(this.BoozeSprite, false, false, 128, 128);
                this._cp_type = Checkpoint.BOOZE;
                break;

                case Checkpoint.HOME:
                this.checkpoint_sprite.loadGraphic(this.HomeSprite, false, false, 128, 128);
                this._cp_type = Checkpoint.HOME;
                break;

                case Checkpoint.MOVIES:
                this.checkpoint_sprite.loadGraphic(this.MoviesSprite, false, false, 128, 128);
                this._cp_type = Checkpoint.MOVIES;
                break;

                case Checkpoint.PARK:
                this.checkpoint_sprite.loadGraphic(this.ParkSprite, false, false, 128, 128);
                this._cp_type = Checkpoint.PARK;
                break;

                case Checkpoint.BEACH:
                this.checkpoint_sprite.loadGraphic(this.BeachSprite, false, false, 128, 128);
                this._cp_type = Checkpoint.BEACH;
                break;

                case Checkpoint.DINNER:
                this.checkpoint_sprite.loadGraphic(this.DinnerSprite, false, false, 128, 128);
                this._cp_type = Checkpoint.DINNER;
                break;
            }

            this.makeGraphic(this.checkpoint_sprite.width/2, this.checkpoint_sprite.height*2, 0xffff0000);
            this.visible = false;
        }

        public function get index():Number {
            return this.idx;
        }

        public function set index(n:Number):void {
            this.idx = n;
        }

        public function get cp_type():String {
            return this._cp_type;
        }

        public function setImgPos(p:DHPoint):void {
            if(this.checkpoint_sprite != null) {
                this.checkpoint_sprite.setPos(p);
            }
        }

        public function playSfx():void {
            this.checkpointSound.play();
        }

        public function stopSfx():void {
            this.checkpointSound.stop();
        }

        override public function addVisibleObjects():void {
            FlxG.state.add(this);
            FlxG.state.add(this.checkpoint_sprite);
        }
    }
}
