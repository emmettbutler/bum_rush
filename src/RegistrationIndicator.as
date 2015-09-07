package {
    import org.flixel.*;

    public class RegistrationIndicator extends GameObject {
        private var textBox:FlxText;
        private var car_image:GameObject, driver_image:GameObject,
                    passenger_image:GameObject;
        private var _name:String;

        public function RegistrationIndicator(tagData:Object) {
            super(new DHPoint(0, 0));
            this._name = tagData['name'];
            var passenger_config:Object = Passenger.passengerConfigs[tagData['starting_passenger']];

            this.textBox = new FlxText(pos.x, pos.y, 200,
                tagData['name'] + " & " + passenger_config['name']);
            this.textBox.setFormat(null, 17, 0xffffffff, "center");

            this.car_image = new GameObject(pos);
            this.car_image.loadGraphic(tagData['car'], true, false, 64, 64);
            this.car_image.addAnimation("play", [8,9,10,11], 12, true);

            this.driver_image = new GameObject(pos);
            this.driver_image.loadGraphic(tagData['sprite'], true, false, 64, 64);
            this.driver_image.addAnimation("play", [8,9,10,11], 12, true);

            this.passenger_image = new GameObject(pos);
            this.passenger_image.loadGraphic(passenger_config['riding_sprite'], true, false, 64, 64);
            this.passenger_image.addAnimation("play", [8,9,10,11], 12, true);
        }

        override public function addVisibleObjects():void {
            super.addVisibleObjects();
            FlxG.state.add(this.textBox);
            FlxG.state.add(this.car_image);
            FlxG.state.add(this.driver_image);
            FlxG.state.add(this.passenger_image);
            this.car_image.play("play");
            this.driver_image.play("play");
            this.passenger_image.play("play");
        }

        override public function setPos(pos:DHPoint):void {
            super.setPos(pos);
            this.car_image.setPos(pos);
            this.driver_image.setPos(pos);
            this.passenger_image.setPos(pos);

            this.textBox.x = this.car_image.getMiddle().x - this.textBox.width / 2;
            this.textBox.y = this.car_image.getPos().y + this.car_image.height + 20;
        }
    }
}
