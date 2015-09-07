package {
    import org.flixel.*;

    import flash.utils.Dictionary;

    public class Passenger extends GameObject {
        [Embed(source="/../assets/passenger_lilD_64.png")] private static var sprite_1:Class;

        public static const STATE_RIDING:Number = 1;
        public static const STATE_STANDING:Number = 2;
        public static const STATE_MOVING_TO_STREET:Number = 3;
        private var _state:Number;

        public static const TYPE_LILD:Number = 1;
        private var _type:Number;

        private var riding_sprite:GameObject;
        private var standing_sprite:GameObject;
        private var frameRate:Number = 12;
        private var destPos:DHPoint;
        public var idx:int = 0;

        private var _driver:Player;

        {
            public static var passengerConfigs:Dictionary = new Dictionary();
            passengerConfigs[TYPE_LILD] = {
                "name": "Diego",
                "riding_sprite": sprite_1,
                "standing_sprite": sprite_1
            }
        }

        public function Passenger(kind:Number) {
            super(new DHPoint(0, 0));

            this._type = kind;

            this.riding_sprite = new GameObject(this.pos);
            this.riding_sprite.loadGraphic(sprite_1, true, false, 64, 64);
            this.riding_sprite.zSorted = true;
            this.riding_sprite.basePosOffset = new DHPoint(
                this.riding_sprite.width / 2,
                this.riding_sprite.height * 2
            );
            this.riding_sprite.addAnimation("ride_right", [0,1,2,3], this.frameRate, true);
            this.riding_sprite.addAnimation("ride_up", [4,5,6,7], this.frameRate, true);
            this.riding_sprite.addAnimation("ride_down", [8,9,10,11], this.frameRate, true);
            this.riding_sprite.addAnimation("ride_left", [12,13,14,15], this.frameRate, true);
            this.riding_sprite.play("ride_down");

            this.standing_sprite = new GameObject(this.pos);
            this.standing_sprite.loadGraphic(sprite_1, true, false, 64, 64);
            this.standing_sprite.zSorted = true;
            this.standing_sprite.addAnimation("stand", [0, 1], this.frameRate, true);
            this.standing_sprite.visible = false;
        }

        public function getStandingHitbox():FlxRect {
            return this.standing_sprite._getRect();
        }

        public function set driver(d:Player):void {
            this._driver = d;
        }

        public function get driver():Player {
            return this._driver;
        }

        public function isStanding():Boolean {
            return this._state == STATE_STANDING;
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

        public function leaveCar(hitVector:DHPoint, destPoint:DHPoint):void {
            if (this._state != STATE_MOVING_TO_STREET) {
                this._state = STATE_MOVING_TO_STREET;
                this._driver = null;
                this.destPos = destPoint;
            }
        }

        public function enterCar(driver:Player):void {
            if (this._state != STATE_RIDING) {
                this._driver = driver;
                this._state = STATE_RIDING;
            }
        }

        override public function update():void {
            super.update();
            switch (this._state) {
                case STATE_RIDING:
                    this.updateDrivingAnimation();
                    break;
                case STATE_STANDING:
                    break;
                case STATE_MOVING_TO_STREET:
                    this.dir = this.destPos.sub(this.pos).normalized().mulScl(5);
                    this.riding_sprite.angle += 9;
                    if (this.destPos.sub(this.pos)._length() < 10) {
                        this.dir = new DHPoint(0, 0);
                        this._state = STATE_STANDING;
                        this.riding_sprite.angle = 0;
                        this.standing_sprite.angle = 0;
                    }
                    break;
            }
        }

        public function updateDrivingAnimation():void {
            if (this._driver != null) {
                this.setPos(new DHPoint(
                    this._driver.getPos().x,
                    this._driver.getPos().y - (25 * this.idx)
                ));
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
}
