package {
    import Box2D.Dynamics.Contacts.b2Contact;
    import Box2D.Dynamics.b2ContactListener;
    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.Joints.*;
    import org.flixel.*;

    public class ContactListener extends b2ContactListener {
        public function ContactListener():void {
        }

        override public function BeginContact(contact:b2Contact):void {
            var fixAUserData:Object = contact.GetFixtureA().GetUserData();
            var fixBUserData:Object = contact.GetFixtureB().GetUserData();

            if (fixAUserData == null || fixBUserData == null) {
                return;
            }

            if (fixAUserData['tag'] != Player.COLLISION_TAG ||
                fixBUserData['tag'] != Player.COLLISION_TAG) {
                return;
            }

            var playerAVel:Number = fixAUserData['player'].bodyVelocity;
            var playerBVel:Number = fixBUserData['player'].bodyVelocity;
            var crashVelocityThreshold:Number = 1;

            if (playerAVel < 1 && playerBVel < 1) {
                return;
            }

            var fasterPlayer:Player = fixAUserData['player'];
            var slowerPlayer:Player = fixBUserData['player'];
            if (playerBVel > playerAVel) {
                fasterPlayer = fixBUserData['player'];
                slowerPlayer = fixAUserData['player'];
            }

            slowerPlayer.removePassenger();
        }

        override public function EndContact(contact:b2Contact):void {
            var bodyA:b2Fixture = contact.GetFixtureA();
            var bodyB:b2Fixture = contact.GetFixtureB();

            if(bodyA.IsSensor() && bodyB.IsSensor()){ }
        }
    }
}
