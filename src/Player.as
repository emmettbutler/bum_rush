package {
    import org.flixel.*;

    import flash.ui.GameInputDevice;
    import flash.ui.GameInputControl;

    public class Player extends GameObject {
        private var driver_sprite:Class;
        private var mainSprite:GameObject;
        private var controller:GameInputDevice;
        private var accel:DHPoint, directionsPressed:DHPoint,
                    collideDirection:DHPoint, throttle:Boolean,
                    facingVector:DHPoint;
        private var _colliding:Boolean = false;
        private var _collisionDirection:Array;
        private var lapIndicator:FlxText;
        private var _driver_name:String;
        private var driver_tag:Number, frameRate:Number = 12, _laps:Number = 0, lastLapTime:Number = -1;
        private var _lastCheckpointIdx:Number = 0;
        private var keyboardControls:Boolean = false;

        public function Player(pos:DHPoint,
                               controller:GameInputDevice,
                               keyboard:Boolean=false,
                               _tag:Number=0):void
        {
            super(pos);

            this.dir = new DHPoint(0, 0);
            this.accel = new DHPoint(0, 0);
            this.directionsPressed = new DHPoint(1, 0);
            this.facingVector = new DHPoint(1, 0);
            this.throttle = false;
            this.keyboardControls = keyboard;

            this.controller = controller;
            this.driver_tag = _tag;

            var tagData:Object = PlayersController.getInstance().resolveTag(this.driver_tag);
            this.driver_sprite = tagData['sprite'];
            this._driver_name = tagData['name'];

            this.addAnimations();
            this.lapIndicator = new FlxText(this.pos.x, this.pos.y - 30, 200, "");
            this.lapIndicator.setFormat(null, 30, 0xffff0000, "center");
        }

        public function addAnimations():void {
            this.mainSprite = new GameObject(this.pos, this);
            this.mainSprite.loadGraphic(driver_sprite, true, false, 32, 43);
            this.mainSprite.addAnimation("drive_right", [0,1,2,3], this.frameRate, true);
            this.mainSprite.addAnimation("drive_up", [4,5,6,7], this.frameRate, true);
            this.mainSprite.addAnimation("drive_down", [8,9,10,11], this.frameRate, true);
            this.mainSprite.addAnimation("drive_left", [12,13,14,15], this.frameRate, true);
            this.mainSprite.addAnimation("idle_right", [16,17,18,19], this.frameRate, true);
            this.mainSprite.addAnimation("idle_up", [20,21,22,23], this.frameRate, true);
            this.mainSprite.addAnimation("idle_down", [24,25,26,27], this.frameRate, true);
            this.mainSprite.addAnimation("idle_left", [28,29,30,31], this.frameRate, true);
            this.mainSprite.play("idle_up");
        }

        public function set colliding(c:Boolean):void {
            this._colliding = c;
        }

        public function set collisionDirection(c:Array):void {
            this._collisionDirection = c;
        }

        public function getCollider():GameObject {
            return this.mainSprite;
        }

        override public function addVisibleObjects():void {
            FlxG.state.add(this.mainSprite);
            FlxG.state.add(this.lapIndicator);
        }

        public function get lastCheckpointIdx():Number {
            return this._lastCheckpointIdx;
        }

        public function get laps():Number {
            return this._laps;
        }

        public function get driver_name():String {
            return this._driver_name;
        }

        public function crossCheckpoint(checkpoint:Checkpoint, lastIdx:Number):void {
            if (this._lastCheckpointIdx == checkpoint.index - 1 ||
                (this._lastCheckpointIdx == lastIdx && checkpoint.index == 0))
            {
                this._lastCheckpointIdx = checkpoint.index;
                if (this._lastCheckpointIdx == lastIdx) {
                    this._laps += 1;
                    this.lastLapTime = this.curTime;
                    this.lapIndicator.text = this._laps + "";
                }
            }
        }

        override public function update():void {
            super.update();
            this.updateDrivingAnimation();
            this.updateMovement();
            if (this.keyboardControls) {
                this.updateKeyboard();
            }

            if ((this.curTime - this.lastLapTime) / 1000 >= 2) {
                this.lapIndicator.text = "";
            }
        }

        public function updateMovement():void {
            this.dir = this.dir.add(this.accel).limited(6);
            this.setPos(this.pos.add(this.dir));

            if (this.throttle) {  // accelerating
                if (this.directionsPressed.x != 0 || this.directionsPressed.y != 0) {
                    this.accel = this.directionsPressed.mulScl(.4);
                } else {
                    this.accel = this.facingVector.mulScl(.4);
                }
            } else if (this.dir._length() > 1) {  // not accelerating but moving forward
                this.accel = this.dir.reverse().mulScl(.08);
            } else {  // stopped
                this.accel.x = 0;
                this.accel.y = 0;
                this.dir.x = 0;
                this.dir.y = 0;
            }

            if (this._colliding) {
                if (this._collisionDirection != null) {
                    if (this._collisionDirection[0] == 1 &&
                        this._collisionDirection[1] == 1 &&
                        this._collisionDirection[2] == 1 &&
                        this._collisionDirection[3] == 1)
                    {
                        // stuck!
                    } else {
                        if (this._collisionDirection[1] == 1) {
                            // right
                            this.dir.x = 0;
                            this.accel.x = Math.min(0, this.accel.x);
                        } else if (this._collisionDirection[0] == 1) {
                            // left
                            this.dir.x = 0;
                            this.accel.x = Math.max(0, this.accel.x);
                        }
                        if (this._collisionDirection[3] == 1) {
                            // down
                            this.dir.y = 0;
                            this.accel.y = Math.min(0, this.accel.y);
                        } else if (this._collisionDirection[2] == 1) {
                            // up
                            this.dir.y = 0;
                            this.accel.y = Math.max(0, this.accel.y);
                        }
                    }
                }
            }
        }

        public function updateDrivingAnimation():void {
            if(Math.abs(this.directionsPressed.x) > Math.abs(this.directionsPressed.y)) {
                if(this.throttle) {
                    if(this.directionsPressed.x >= 0) {
                        this.mainSprite.play("drive_right");
                        this.facingVector.x = 1;
                        this.facingVector.y = 0;
                    } else {
                        this.mainSprite.play("drive_left");
                        this.facingVector.x = -1;
                        this.facingVector.y = 0;
                    }
                } else {
                    if(this.directionsPressed.x >= 0) {
                        this.mainSprite.play("idle_right");
                        this.facingVector.x = 1;
                        this.facingVector.y = 0;
                    } else {
                        this.mainSprite.play("idle_left");
                        this.facingVector.x = -1;
                        this.facingVector.y = 0;
                    }
                }
            } else if(Math.abs(this.directionsPressed.y) > Math.abs(this.directionsPressed.x)) {
                if(this.throttle) {
                    if(this.directionsPressed.y >= 0) {
                        this.mainSprite.play("drive_down");
                        this.facingVector.y = 1;
                        this.facingVector.x = 0;
                    } else {
                        this.mainSprite.play("drive_up");
                        this.facingVector.y = -1;
                        this.facingVector.x = 0;
                    }
                } else {
                    if(this.directionsPressed.y >= 0) {
                        this.mainSprite.play("idle_down");
                        this.facingVector.x = 0;
                        this.facingVector.y = 1;
                    } else {
                        this.mainSprite.play("idle_up");
                        this.facingVector.x = 0;
                        this.facingVector.y = -1;
                    }
                }
            }
        }

        public function updateKeyboard():void {
            if (FlxG.keys.justPressed("D")) {
                this.directionsPressed.x = 1;
            } else if (FlxG.keys.justReleased("D")){
                this.directionsPressed.x = 0;
            }
            if (FlxG.keys.justPressed("A")) {
                this.directionsPressed.x = -1;
            } else if (FlxG.keys.justReleased("A")){
                this.directionsPressed.x = 0;
            }

            if (FlxG.keys.justPressed("W")) {
                this.directionsPressed.y = -1;
            } else if (FlxG.keys.justReleased("W")){
                this.directionsPressed.y = 0;
            }
            if (FlxG.keys.justPressed("S")) {
                this.directionsPressed.y = 1;
            } else if (FlxG.keys.justReleased("S")){
                this.directionsPressed.y = 0;
            }

            if (FlxG.keys.justPressed("SPACE")) {
                this.throttle = true;
            } else if (FlxG.keys.justReleased("SPACE")) {
                this.throttle = false;
            }
        }

        public function controllerChanged(control:GameInputControl,
                                          mapping:Object):void
        {
            if (control.value == 0 || control.value == 1) {
            } else {
                return;
            }
            if (this.controller == null || control.device.id != this.controller.id) {
                return;
            }

            if (control.id == mapping["right"]) {
                if (control.value == 0) {
                    this.directionsPressed.x = 0;
                } else {
                    this.directionsPressed.x = 1;
                }
            } else if (control.id == mapping["left"]) {
                if (control.value == 0) {
                    this.directionsPressed.x = 0;
                } else {
                    this.directionsPressed.x = -1;
                }
            } else if (control.id == mapping["up"]) {
                if (control.value == 0) {
                    this.directionsPressed.y = 0;
                } else {
                    this.directionsPressed.y = 1;
                }
            } else if (control.id == mapping["down"]) {
                if (control.value == 0) {
                    this.directionsPressed.y = 0;
                } else {
                    this.directionsPressed.y = -1;
                }
            } else if (control.id == mapping["a"]) {
                if (control.value == 1) {
                    this.throttle = true;
                } else {
                    this.throttle = false;
                }
            }
        }

        override public function getMiddle():DHPoint {
            return this.mainSprite.getMiddle();
        }

        public function collisionCallback(player:Player):void {
            var disp:DHPoint = this.getCollider().getMiddle().sub(player.getCollider().getMiddle());
            //var scaler:Number = player.dir._length();
            //this.accel = disp.normalized().mulScl(Math.max(5, scaler));
        }

        override public function setPos(pos:DHPoint):void {
            super.setPos(pos);
            this.mainSprite.setPos(pos);
            this.lapIndicator.x = pos.x;
            this.lapIndicator.y = pos.y;
        }
    }
}
