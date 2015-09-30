package {
    import org.flixel.*;

    public class RegistrationIndicator extends GameObject {
        [Embed(source="/../assets/fonts/Pixel_Berry_08_84_Ltd.Edition.TTF", fontFamily="Pixel_Berry_08_84_Ltd.Edition", embedAsCFF="false")] public var GameFont:String;

        private var joined_sprite:FlxExtSprite, base_sprite:FlxExtSprite;
        private var _joined:Boolean = false;
        private var _name:String, _tag:Number;

        public function RegistrationIndicator(tagData:Object) {
            super(new DHPoint(0, 0));
            this._name = tagData['name'];
            this._tag = tagData['tag'];
            var passenger_config:Object = Passenger.passengerConfigs[tagData['starting_passenger']];

            var pathPrefix:String = "../assets/images/ui/";
            this.base_sprite = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + tagData['join_prefix'] + "_out.png", false);
            this.joined_sprite = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + tagData['join_prefix'] + ".png", false);
            this.joined_sprite.visible = false;
        }

        public function get tag():Number {
            return this._tag;
        }

        public function set joined(v:Boolean):void {
            this._joined = v;
            this.joined_sprite.visible = true;
        }

        override public function addVisibleObjects():void {
            super.addVisibleObjects();
            FlxG.state.add(this.base_sprite);
            FlxG.state.add(this.joined_sprite);
        }

        override public function setPos(pos:DHPoint):void {
            super.setPos(pos);
        }
    }
}
