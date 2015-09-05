package {
    import org.flixel.*;

    public class Passenger extends GameObject {
        [Embed(source="/../assets/passenger_lilD_64.png")] private var sprite_1:Class;

        public static const STATE_RIDING:Number = 1;
        public static const STATE_STANDING:Number = 2;
        private var _state:Number;

        public static const TYPE_LILD:Number = 1;
        private var _type:Number;

        private var riding_sprite:GameObject;
        private var standing_sprite:GameObject;
        private var frameRate:Number = 12;

        private var _driver:Player;

        public function Passenger() {
            super(new DHPoint(0, 0));

            this._type = TYPE_LILD;
            this._state = STATE_RIDING;

            this.riding_sprite = new GameObject(this.pos);
            this.riding_sprite.loadGraphic(sprite_1, true, false, 64, 64);
            this.riding_sprite.addAnimation("ride_right", [0,1,2,3], this.frameRate, true);
            this.riding_sprite.addAnimation("ride_up", [4,5,6,7], this.frameRate, true);
            this.riding_sprite.addAnimation("ride_down", [8,9,10,11], this.frameRate, true);
            this.riding_sprite.addAnimation("ride_left", [12,13,14,15], this.frameRate, true);
            this.riding_sprite.play("ride_down");

            this.standing_sprite = new GameObject(this.pos);
            this.standing_sprite.loadGraphic(sprite_1, true, false, 64, 64);
            this.standing_sprite.addAnimation("stand", [0, 1], this.frameRate, true);
            this.standing_sprite.visible = false;
        }

        public function set driver(d:Player):void {
            this._driver = d;
        }

        override public function addVisibleObjects():void {
            super.addVisibleObjects();
            FlxG.state.add(this.riding_sprite);
            FlxG.state.add(this.standing_sprite);
        }

        override public function setPos(pos:DHPoint):void {
            super.setPos(pos);
            this.riding_sprite.setPos(pos);
            this.standing_sprite.setPos(pos);
        }

        override public function update():void {
            switch (this._state) {
                case STATE_RIDING:
                    this.updateDrivingAnimation();
                    break;
                case STATE_STANDING:
                    break;
            }
        }

        public function updateDrivingAnimation():void {
            var facingVector:DHPoint = this._driver.getFacingVector();
            if (facingVector.x == 1) {
                this.riding_sprite.play("ride_right");
            } else if (facingVector.x == -1) {
                this.riding_sprite.play("ride_left");
            } else if (facingVector.y == 1) {
                this.riding_sprite.play("ride_down");
            } else if (facingVector.y == -1) {
                this.riding_sprite.play("ride_up");
            }
        }
    }
}
