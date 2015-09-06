package {

    import org.flixel.*;

    public class Particle extends GameObject {
        private var lifespan:Number, shrinkFactor:Number, shrinkRateFrames:Number;
        private var framesAlive:Number, baseScale:Number;
        //public var parent:GameObject;
        private var _lock:Boolean = false;
        private var lastActiveTime:Number;
        private var deactivateTime:Number;

        public function Particle(lifespan:Number,
                                 shrinkFactor:Number=.6,
                                 shrinkRateFrames=12,
                                 baseScale=.7)
        {
            super(new DHPoint(0, 0));
            this.framesAlive = 0;
            this.lifespan = lifespan;
            this.shrinkFactor = shrinkFactor;
            this.shrinkRateFrames = shrinkRateFrames;
            this.baseScale = baseScale;
            this.zSorted = true;
            var randParticle:Number = Math.floor(Math.random() * 2),
                partImage:Class, partDim:DHPoint = new DHPoint(20, 40);
            this.makeGraphic(5,5,0xffffffff);

            this.zSorted = false;
            this.visible = false;
            this.active = false;
        }

        public function makeAlive():void {
            this.visible = true;
            this.active = true;
            this.framesAlive = 0;
            var rand:Number = Math.random() * .3;
            this.scale.x = this.baseScale + rand;
            this.scale.y = this.baseScale + rand;
        }

        override public function update():void {
            super.update();
            this.framesAlive++;
            if(this.active && !this._lock) {
                this._lock = true;
                this.lastActiveTime = this.framesAlive;
                this.deactivateTime = this.framesAlive + 3000;
            }
            if(this.framesAlive >= this.deactivateTime) {
                this._lock = false;
                this.active = false;
                this.visible = false;
            }
            if (this.parent != null) {
                this.basePos = this.parent.basePos;
                this.basePos.y += 1;
            }
            if (this.framesAlive % this.shrinkRateFrames == 0) {
                this.scale.x *= this.shrinkFactor;
                this.scale.y *= this.shrinkFactor;
            }
        }
    }
}