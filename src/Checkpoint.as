package {
    import org.flixel.*;

    public class Checkpoint extends GameObject{
        [Embed(source="/../assets/images/worlds/BeerStore_1.png")] private var BoozeSprite:Class;
        [Embed(source="/../assets/images/worlds/Home_1.png")] private var HomeSprite:Class;
        [Embed(source="/../assets/images/worlds/MovieTheater_1.png")] private var MoviesSprite:Class;
        [Embed(source="/../assets/images/worlds/donkersDugout_3.png")] private var ParkSprite:Class;
        [Embed(source="/../assets/images/worlds/Beach.png")] private var BeachSprite:Class;
        [Embed(source="/../assets/images/worlds/BigFranks_21.png")] private var DinnerSprite:Class;
        [Embed(source="/../assets/images/worlds/NightClub_1.png")] private var ClubSprite:Class;
        [Embed(source="/../assets/audio/passenger.mp3")] private var CheckpointSFX:Class;

        private var dimensions:DHPoint;
        private var idx:Number, frameRate:Number = 12;
        private var checkpoint_sprite:GameObject;
        private var _cp_type:String;

        public static const BOOZE:String = "booze spot";
        public static const HOME:String = "start at home";
        public static const MOVIES:String = "movie theatre";
        public static const PARK:String = "picnicin";
        public static const BEACH:String = "swimmin";
        public static const DINNER:String = "chowin down";
        public static const CLUB:String = "clubbin bae";

        private var checkpointSound:FlxSound;

        public function Checkpoint(pos:DHPoint, dim:DHPoint, type:String=null) {
            super(pos);
            this.dimensions = dim;
            if(type != null) {
                this.checkpoint_sprite = new GameObject(pos);
            }

            this.checkpointSound = new FlxSound();
            this.checkpointSound.loadEmbedded(CheckpointSFX,false);
            this.checkpointSound.volume = 1;

            this._cp_type = type;

            switch (type) {
                case null:
                break;
                case Checkpoint.BOOZE:
                    this.checkpoint_sprite.loadGraphic(this.BoozeSprite, false, false, 128, 128);
                break;
                case Checkpoint.HOME:
                    this.checkpoint_sprite.loadGraphic(this.HomeSprite, false, false, 128, 128);
                break;
                case Checkpoint.MOVIES:
                    this.checkpoint_sprite.loadGraphic(this.MoviesSprite, false, false, 128, 128);
                break;
                case Checkpoint.PARK:
                    this.checkpoint_sprite.loadGraphic(this.ParkSprite, false, false, 384 / 3, 128);
                    this.checkpoint_sprite.addAnimation("anim", [0,1,2], 7, true);
                    this.checkpoint_sprite.play("anim");
                break;
                case Checkpoint.BEACH:
                    this.checkpoint_sprite.loadGraphic(this.BeachSprite, false, false, 128, 128);
                break;
                case Checkpoint.DINNER:
                    this.checkpoint_sprite.loadGraphic(this.DinnerSprite, false, false, 146, 85);
                    this.checkpoint_sprite.addAnimation("anim", [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,29,20,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0], this.frameRate, true);
                    this.checkpoint_sprite.play("anim");
                break;
                case Checkpoint.CLUB:
                    this.checkpoint_sprite.loadGraphic(this.ClubSprite, false, false, 128, 128);
                break;
            }

            this.makeGraphic(this.checkpoint_sprite.width,
                             this.checkpoint_sprite.height, 0xffff0000);
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

        public function setHitboxSize(dim:DHPoint):void {
            this.width = dim.x;
            this.height = dim.y;
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
