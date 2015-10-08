package {
    import org.flixel.*;

    public class RegistrationIndicator extends GameObject {
        [Embed(source="/../assets/fonts/Pixel_Berry_08_84_Ltd.Edition.TTF", fontFamily="Pixel_Berry_08_84_Ltd.Edition", embedAsCFF="false")] public var GameFont:String;

        private var joined_sprite:FlxExtSprite, base_sprite:FlxExtSprite,
                    phone_sprite:FlxExtSprite;
        private var _joined:Boolean = false;
        private var _name:String, _tag:Number;
        private var lastStateSwitchTime:Number = 0;

        public static const STATE_START:Number = 1;
        public static const STATE_INTRO_START:Number = 198347569;
        public static const STATE_BUZZ:Number = 2;
        public static const STATE_PHONE:Number = 3;
        public static const STATE_HEART:Number = 4;
        public static const STATE_ASK:Number = 5;
        public static const STATE_SHOCK:Number = 6;
        public static const STATE_DONE:Number = 7;
        private var _state:Number = STATE_START;

        public function RegistrationIndicator(tagData:Object) {
            super(new DHPoint(0, 0));
            this._name = tagData['name'];
            this._tag = tagData['tag'];
            var passenger_config:Object = Passenger.passengerConfigs[tagData['starting_passenger']];

            var pathPrefix:String = "../assets/images/ui/";

            this.base_sprite = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + tagData['join_prefix'] + "_out.png", false);

            this.joined_sprite = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + tagData['join_prefix'] + "_sheet_9.png", false, true, 169, 95);
            this.joined_sprite.visible = false;
            this.joined_sprite.addAnimation("start", [0], 13, false);
            this.joined_sprite.addAnimation("buzz", [1, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2], 17, false);
            this.joined_sprite.addAnimation("heart", [4, 5, 4, 5, 4, 5, 4, 5], 7, true);
            this.joined_sprite.addAnimation("ask", [6, 7], 7, true);
            this.joined_sprite.addAnimation("shock", [8], 13, false);
            this.joined_sprite.play("start");

            this.phone_sprite = ScreenManager.getInstance().loadSingleTileBG(pathPrefix + "phone_" + tagData['join_prefix'] + "_sheet_6.png", false, true, 169, 95);
            this.phone_sprite.visible = false;
            this.phone_sprite.addAnimation("appear", [0, 1, 2, 3, 4, 5], 13, false);
        }

        public function get state():Number {
            return this._state;
        }

        public function get tag():Number {
            return this._tag;
        }

        public function set joined(v:Boolean):void {
            this._joined = v;
            this.joined_sprite.visible = true;
        }

        public function get joined():Boolean {
            return this._joined;
        }

        public function highlight():void {
            this.joined_sprite.color = 0xffffa5d8;
        }

        public function unhighlight():void {
            this.joined_sprite.color = 0xffffffff;
        }

        override public function addVisibleObjects():void {
            super.addVisibleObjects();
            FlxG.state.add(this.base_sprite);
            FlxG.state.add(this.joined_sprite);
            FlxG.state.add(this.phone_sprite);
        }

        override public function setPos(pos:DHPoint):void {
            super.setPos(pos);
        }

        public function startIntro():void {
            if (this._joined) {
                this._state = STATE_INTRO_START;
                this.lastStateSwitchTime = this.timeAlive;
            }
            this.base_sprite.visible = false;
        }

        override public function update():void {
            super.update();

            if (this._state == STATE_INTRO_START) {
                if (this.timeAlive - this.lastStateSwitchTime >= 2.1 * 1000) {
                    this.lastStateSwitchTime = this.timeAlive;
                    this._state = STATE_BUZZ;
                    this.joined_sprite.play("buzz");
                }
            } else if (this._state == STATE_BUZZ) {
                if (this.timeAlive - this.lastStateSwitchTime >= 1.5 * 1000) {
                    this.lastStateSwitchTime = this.timeAlive;
                    this._state = STATE_PHONE;
                    this.joined_sprite.visible = false;
                    this.phone_sprite.visible = true;
                    this.phone_sprite.play("appear");
                }
            } else if (this._state == STATE_PHONE) {
                if (this.timeAlive - this.lastStateSwitchTime >= 4 * 1000) {
                    this.lastStateSwitchTime = this.timeAlive;
                    this._state = STATE_HEART;
                    this.phone_sprite.visible = false;
                    this.joined_sprite.visible = true;
                    this.joined_sprite.play("heart");
                }
            } else if (this._state == STATE_HEART) {
                if (this.timeAlive - this.lastStateSwitchTime >= 3 * 1000) {
                    this.lastStateSwitchTime = this.timeAlive;
                    this._state = STATE_ASK;
                    this.joined_sprite.play("ask");
                }
            } else if (this._state == STATE_ASK) {
                if (this.timeAlive - this.lastStateSwitchTime >= 3 * 1000) {
                    this.lastStateSwitchTime = this.timeAlive;
                    this._state = STATE_SHOCK;
                    this.joined_sprite.play("shock");
                }
            } else if (this._state == STATE_SHOCK) {
                if (this.timeAlive - this.lastStateSwitchTime >= 3 * 1000) {
                    this.lastStateSwitchTime = this.timeAlive;
                    this._state = STATE_DONE;
                }
            }
        }

        override public function destroy():void {
            this.joined_sprite.unload();
            this.joined_sprite = null;
            this.base_sprite.unload();
            this.base_sprite = null;
            this.phone_sprite.unload();
            this.phone_sprite = null;
            super.destroy();
        }
    }
}
