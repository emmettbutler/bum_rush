package {
    public class ControlResolver {
        public static const player_1:Number = 0;
        public static const player_2:Number = 1;

        {
            public static var characterTags:Array = [
                ControlResolver.player_1,
                ControlResolver.player_2
            ]
            public static var controllerMappings:Object = {
                "PLAYSTATION(R)3 Controller": {
                    "right": "BUTTON_9",
                    "left": "BUTTON_11",
                    "up": "BUTTON_10",
                    "down": "BUTTON_8",
                    "a": "BUTTON_18"
                },
                "Xbox 360 Wired Controller": {
                    "right": "BUTTON_9",
                    "left": "BUTTON_8",
                    "up": "BUTTON_7",
                    "down": "BUTTON_6",
                    "a": "BUTTON_17"
                },
                "Wireless Controller": {  // PS4
                    "right": "BUTTON_9",
                    "left": "BUTTON_8",
                    "up": "BUTTON_7",
                    "down": "BUTTON_6",
                    "a": "BUTTON_11"
                }
            }
        }
    }
}
