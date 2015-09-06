package {
    import org.flixel.*;

    import flash.ui.GameInputControl;

    public class GameState extends FlxState {
        protected var bornTime:Number, timeAlive:Number, curTime:Number, raceBornTime:Number;
        public var gameActive:Boolean = false;
        private var sortedObjects:Array;

        public static const EVENT_SINGLETILE_BG_LOADED:String = "bg_loaded";

        public function GameState() {
            this.sortedObjects = new Array();
        }

        override public function create():void {
            this.bornTime = new Date().valueOf();
        }

        override public function update():void {
            this.sortedObjects.length = 0;
            var basic:GameObject, i:uint = 0;
            while(i < length) {
                // maintain a list of GameObjects to be z-sorted by their foot position
                if (members[i] is GameObject && (members[i] as GameObject).zSorted) {
                    this.sortedObjects.push(members[i]);
                }
                basic = members[i++] as GameObject;
                if (basic != null) {
                    if(basic.active && basic.exists && basic.scale != null) {
                        basic.preUpdate();
                        basic.update();
                        basic.postUpdate();
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

            if(FlxG.keys.justPressed("R")) {
                FlxG.switchState(new MenuState());
            }
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
            for (var i:int = 0; i < this.members.length; i++) {
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
