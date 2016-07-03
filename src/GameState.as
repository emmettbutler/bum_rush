package {
    import org.flixel.*;

    import flash.desktop.NativeApplication;
    import flash.events.KeyboardEvent;
    import flash.ui.GameInputControl;
    import flash.ui.Keyboard;

    public class GameState extends FlxState {
        protected var bornTime:Number, timeAlive:Number, curTime:Number, raceBornTime:Number;
        public var gameActive:Boolean = false;
        private var sortedObjects:Array;
        private var quitText:FlxText, quitBox:GameObject, quitUpTime:Number;

        public static const EVENT_SINGLETILE_BG_LOADED:String = "bg_loaded";

        public function GameState() {
            this.sortedObjects = new Array();
        }

        override public function create():void {
            this.bornTime = new Date().valueOf();

            var that:GameState = this;
            FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,
                function(e:KeyboardEvent):void {
                    if (e.keyCode == Keyboard.ESCAPE) {
                        e.preventDefault();
                        if (FlxG.state != that) {
                            return;
                        }
                        if (!that.quitText.visible) {
                            that.quitText.visible = true;
                            that.quitBox.visible = true;
                            that.quitUpTime = new Date().getTime();
                        } else {
                            NativeApplication.nativeApplication.exit();
                        }
                    }
                });
        }

        override public function update():void {
            this.sortedObjects.length = 0;
            var basic:FlxSprite, i:uint = 0;
            while(i < length) {
                basic = members[i++] as FlxSprite;
                if (basic != null) {
                    if(basic.active && basic.exists && basic.scale != null) {
                        basic.preUpdate();
                        basic.update();
                        basic.postUpdate();
                    }
                    if (basic is GameObject && (basic as GameObject).zSorted) {
                        this.sortedObjects.push(basic as GameObject);
                    }
                }
            }
            this.sortedObjects.sort(sortByBasePos);
            this.insertSortedObjects();

            this.curTime = new Date().valueOf();
            this.timeAlive = this.curTime - this.bornTime;

            if(this.gameActive) {
                PlayersController.getInstance().update();
            }

            if(FlxG.keys.justPressed("Y") && !ScreenManager.getInstance().RELEASE) {
                FlxG.switchState(new MenuState());
            }

            if (this.quitText != null && this.quitText.visible &&
                new Date().getTime() - this.quitUpTime >= 3000)
            {
                this.quitText.visible = false;
                this.quitBox.visible = false;
            }
        }

        public function addQuitElements():void {
            var boxWidth:Number = 400;
            var boxHeight:Number = 60;
            this.quitBox = new GameObject(new DHPoint(ScreenManager.getInstance().screenWidth * .5 - boxWidth / 2,
                                                      ScreenManager.getInstance().screenHeight * .5 - boxHeight / 2 + 17));
            this.quitBox.makeGraphic(boxWidth, boxHeight, 0xdd999999);
            this.quitBox.visible = false;
            FlxG.state.add(this.quitBox);

            this.quitText = new FlxText(0,
                                        ScreenManager.getInstance().screenHeight * .5,
                                        ScreenManager.getInstance().screenWidth,
                                        "Press ESC again to quit");
            this.quitText.setFormat("Pixel_Berry_08_84_Ltd.Edition", 20, 0xccffffff, "center");
            this.quitText.visible = false;
            FlxG.state.add(this.quitText);
        }

        private function sortByBasePos(a:GameObject, b:GameObject):Number {
            var aY:Number = a.basePos != null ? a.basePos.y : a.y;
            var bY:Number = b.basePos != null ? b.basePos.y : b.y;

            if (aY > bY) {
                return 1;
            }
            if (aY < bY) {
                return -1;
            }
            return 0;
        }

        private function insertSortedObjects():void {
            var sortedObjectsCounter:int = 0;
            var cur:GameObject;
            for (var i:int = 0; i < this.length; i++) {
                if (this.members[i] != null && this.members[i] is GameObject){
                    cur = this.members[i] as GameObject;
                    if (cur.zSorted) {
                        this.members[i] = this.sortedObjects[sortedObjectsCounter++];
                    }
                }
            }
        }

        public function startRaceTimer():void {
            this.raceBornTime = new Date().valueOf();
        }

        public function controllerChanged(control:Object,
                                          mapping:Object):void
        { }
    }
}
