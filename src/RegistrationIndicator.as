package {
    import org.flixel.*;

    public class RegistrationIndicator extends GameObject {
        [Embed(source="/../assets/JoinUp_8.png")] private var ImgJoined1:Class;

        private var textBox:FlxText;
        private var image:GameObject;
        private var _name:String;

        public function RegistrationIndicator(tagData:Object) {
            super(new DHPoint(0, 0));
            this._name = tagData['name'];
            this.textBox = new FlxText(pos.x, pos.y, 200, tagData['name']);
            this.textBox.setFormat(null, 20, 0xffffffff, "center");

            this.image = new GameObject(pos);
            this.image.loadGraphic(ImgJoined1, true, false, 664 / 8, 136);
            this.image.addAnimation("play", [0, 1, 2, 3, 4, 5, 6, 7], 12, false);
        }

        override public function addVisibleObjects():void {
            super.addVisibleObjects();
            FlxG.state.add(this.textBox);
            FlxG.state.add(this.image);
            this.image.play("play");
        }

        override public function setPos(pos:DHPoint):void {
            super.setPos(pos);
            this.image.setPos(pos);

            this.textBox.x = this.image.getMiddle().x - this.textBox.width / 2;
            this.textBox.y = this.image.getPos().y + this.image.height + 20;
        }
    }
}
