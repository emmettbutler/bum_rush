package {
    import org.flixel.*;

    import flash.ui.GameInputDevice;
    import flash.ui.GameInputControl;

    public class Player extends GameObject {
        private var mainSprite:GameObject;
        private var controller:GameInputDevice;
        private var accel:DHPoint, facingVector:DHPoint;
        private var throttle:Boolean;

        public function Player(pos:DHPoint, controller:GameInputDevice):void {
            super(pos);

            this.dir = new DHPoint(0, 0);
            this.accel = new DHPoint(0, 0);
            this.facingVector = new DHPoint(1, 0);
            this.throttle = false;

            this.controller = controller;

            this.mainSprite = new GameObject(this.pos, this);
            this.mainSprite.makeGraphic(10, 10, 0xffff0000);
        }

        public function getCollider():GameObject {
            return this.mainSprite;
        }

        override public function addVisibleObjects():void {
            FlxG.state.add(this.mainSprite);
        }

        override public function update():void {
            super.update();

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
            this.dir = this.dir.add(this.accel).limited(3);
            this.setPos(this.pos.add(this.dir));
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
