package {
    import org.flixel.*;

    import flash.ui.GameInputDevice;
    import flash.ui.GameInputControl;

    public class Player extends GameObject {
        private var mainSprite:GameObject;
        private var controller:GameInputDevice;

        public function Player(pos:DHPoint, controller:GameInputDevice):void {
            super(pos);

            this.dir = new DHPoint(0, 0);

            this.controller = controller;

            this.mainSprite = new GameObject(this.pos);
            this.mainSprite.makeGraphic(10, 10, 0xffff0000);
        }

        override public function addVisibleObjects():void {
            FlxG.state.add(this.mainSprite);
        }

        override public function update():void {
            super.update();

            this.setPos(this.pos.add(this.dir));
        }

        public function controllerChanged(control:GameInputControl):void {
            trace("control.id=" + control.id + "\ncontrol.value=" + control.value);
            if (control.id == "BUTTON_9") {
                if (control.value == 0) {
                    this.dir.x = 0;
                } else {
                    this.dir.x = 3;
                }
            } else if (control.id == "BUTTON_8") {
                if (control.value == 0) {
                    this.dir.x = 0;
                } else {
                    this.dir.x = -3;
                }
            } else if (control.id == "BUTTON_7") {
                if (control.value == 0) {
                    this.dir.y = 0;
                } else {
                    this.dir.y = 3;
                }
            } else if (control.id == "BUTTON_6") {
                if (control.value == 0) {
                    this.dir.y = 0;
                } else {
                    this.dir.y = -3;
                }
            }
         }

        override public function setPos(pos:DHPoint):void {
            super.setPos(pos);
            this.mainSprite.setPos(pos);
        }
    }
}
