package {
    import org.flixel.*;

    import flash.ui.GameInputDevice;
    import flash.ui.GameInputControl;

    public class Player extends GameObject {
        [Embed(source="/../assets/Char1_32.png")] private var sprite_1:Class;
        private var mainSprite:GameObject;
        private var controller:GameInputDevice;
        private var accel:DHPoint, facingVector:DHPoint;
        private var throttle:Boolean;
        private var frameRate:Number = 12;

        public function Player(pos:DHPoint, controller:GameInputDevice):void {
            super(pos);

            this.dir = new DHPoint(0, 0);
            this.accel = new DHPoint(0, 0);
            this.facingVector = new DHPoint(1, 0);
            this.throttle = false;

            this.controller = controller;

            this.mainSprite = new GameObject(this.pos, this);
            this.mainSprite.loadGraphic(sprite_1, true, false, 32, 43);
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

        public function getCollider():GameObject {
            return this.mainSprite;
        }

        override public function addVisibleObjects():void {
            FlxG.state.add(this.mainSprite);
        }

        override public function update():void {
            super.update();
            this.updateDrivingAnimation();
            this.updateMovement();
        }

        public function updateMovement():void {
            if (this.throttle) {
                this.accel = this.facingVector.mulScl(.2);
            } else {
                if (this.dir._length() > 1) {
                    this.accel = this.dir.reverse().mulScl(.05);
                } else {
                    this.accel.x = 0;
                    this.accel.y = 0;
                    this.dir.x = 0;
                    this.dir.y = 0;
                }
            }
            this.dir = this.dir.add(this.accel).limited(5);
            this.setPos(this.pos.add(this.dir));
        }

        public function updateDrivingAnimation():void {
            if(Math.abs(this.facingVector.x) > Math.abs(this.facingVector.y)) {
                if(this.throttle) {
                    if(this.facingVector.x >= 0) {
                        this.mainSprite.play("drive_right");
                    } else {
                        this.mainSprite.play("drive_left");
                    }
                } else {
                    if(this.facingVector.x >= 0) {
                        this.mainSprite.play("idle_right");
                    } else {
                        this.mainSprite.play("idle_left");
                    }
                }
            } else if(Math.abs(this.facingVector.y) > Math.abs(this.facingVector.x)) {
                if(this.throttle) {
                    if(this.facingVector.y >= 0) {
                        this.mainSprite.play("drive_down");
                    } else {
                        this.mainSprite.play("drive_up");
                    }
                } else {
                    if(this.facingVector.y >= 0) {
                        this.mainSprite.play("idle_down");
                    } else {
                        this.mainSprite.play("idle_up");
                    }
                }
            }
        }

        public function controllerChanged(control:GameInputControl,
                                          mapping:Object):void
        {
            if (control.value == 0 || control.value == 1) {
                trace("control.id=" + control.id + "\ncontrol.value=" + control.value);
            } else {
                return;
            }
            if (control.device.id != this.controller.id) {
                return;
            }

            if (control.id == mapping["right"]) {
                if (control.value == 0) {
                    this.facingVector.x = 0;
                } else {
                    this.facingVector.x = 1;
                }
            } else if (control.id == mapping["left"]) {
                if (control.value == 0) {
                    this.facingVector.x = 0;
                } else {
                    this.facingVector.x = -1;
                }
            } else if (control.id == mapping["up"]) {
                if (control.value == 0) {
                    this.facingVector.y = 0;
                } else {
                    this.facingVector.y = 1;
                }
            } else if (control.id == mapping["down"]) {
                if (control.value == 0) {
                    this.facingVector.y = 0;
                } else {
                    this.facingVector.y = -1;
                }
            } else if (control.id == mapping["a"]) {
                if (control.value == 1) {
                    this.throttle = true;
                } else {
                    this.throttle = false;
                }
            }
        }

        public function collisionCallback(collidePosition:DHPoint):void {
            var disp:DHPoint = this.getCollider().getMiddle().sub(collidePosition);
            //this.dir = this.dir.sub(disp.normalized().reverse());
        }

        override public function setPos(pos:DHPoint):void {
            super.setPos(pos);
            this.mainSprite.setPos(pos);
        }
    }
}
