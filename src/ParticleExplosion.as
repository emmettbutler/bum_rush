package {

    import org.flixel.*;

    public class ParticleExplosion {
        private var pos:DHPoint;
        private var particleCount:Number, particleSpeed:Number;
        private var particles:Array;
        private var lifespan:Number;
        private var particleGravity:DHPoint;
        private var particleBaseScale:Number;
        private var particleShrinkFactor:Number;
        private var particleShrinkRateFrames:Number;
        private var particleParent:GameObject;
        private var particleRotationSpeed:Number;
        private var particleType:Number;

        public function ParticleExplosion(
            particleCount:Number=25,
            lifespanSec:Number=2,
            particleShrinkFactor:Number=.6,
            particleShrinkRateFrames:Number=12,
            particleSpeed:Number=13,
            particleBaseScale:Number=.7,
            particleParent:GameObject=null,
            particleRotationSpeed=0,
            particleType=Particle.TYPE_PLAIN)
        {
            this.particleCount = particleCount;
            this.particleSpeed = particleSpeed;
            this.particles = new Array();
            this.lifespan = lifespanSec * 1000;
            this.particleGravity = new DHPoint(0, 0);
            this.particleShrinkFactor = particleShrinkFactor;
            this.particleShrinkRateFrames = particleShrinkRateFrames;
            this.particleBaseScale = particleBaseScale;
            this.particleParent = particleParent;
            this.particleRotationSpeed = particleRotationSpeed;
            this.particleType = particleType;

            var curPart:Particle, speedMul:Number;
            for (var i:int = 0; i < this.particleCount; i++) {
                curPart = new Particle(this.lifespan,
                                       this.particleShrinkFactor,
                                       this.particleShrinkRateFrames,
                                       this.particleBaseScale,
                                       this.particleType);
                curPart.parent = this.particleParent;
                this.particles.push(curPart);
            }
        }

        public function set gravity(g:DHPoint):void {
            this.particleGravity.x = g.x;
            this.particleGravity.y = g.y;
        }

        public function addVisibleObjects():void {
            for (var i:int = 0; i < this.particleCount; i++) {
                FlxG.state.add(this.particles[i]);
            }
        }

        public function run(pos:DHPoint):void {
            this.pos = pos;
            var speedMul:Number, angle:Number = 2, p:Particle;
            for(var i:int = 0; i < this.particles.length; i++) {
                p = this.particles[i];
                p.makeAlive();
                p.setPos(this.pos.sub(
                    new DHPoint(p.frameWidth / 2, p.frameHeight / 2)));
                speedMul = Math.random() * .5;
                p.setDir(new DHPoint(
                    Math.cos(angle) * (this.particleSpeed * speedMul),
                    Math.sin(angle) * (this.particleSpeed * speedMul)
                ));
                angle += (Math.PI * 2) / this.particleCount;
            }
        }

        public function update():void {
            for(var i:int = 0; i < this.particles.length; i++) {
                if (this.particles[i].active) {
                    this.particles[i].setDir(this.particles[i].getDir().add(
                        this.particleGravity
                    ));
                    this.particles[i].angle += this.particleRotationSpeed;
                }
            }
        }
    }
}
