package {
    public class ControlResolver {
        {
            public static var controllerMappings:Object = {
                "PLAYSTATION(R)3 Controller": {
                    "right": {
                        "button": "BUTTON_9",
                        "value_on": 1,
                        "value_off": 0
                    },
                    "left": {
                        "button": "BUTTON_11",
                        "value_on": 1,
                        "value_off": 0
                    },
                    "up": {
                        "button": "BUTTON_10",
                        "value_on": 1,
                        "value_off": 0
                    },
                    "down": {
                        "button": "BUTTON_8",
                        "value_on": 1,
                        "value_off": 0
                    },
                    "a": {
                        "button": "BUTTON_18",
                        "value_on": 1,
                        "value_off": 0
                    }
                },
                // NativeJoystick name for wired 360 gamepad
                "Controller (XBOX 360 For Windows)": {
                    "Win": {
                        "right": {
                            "button": "axis_6",
                            "value_on": 65534,
                            "value_off": 32767
                        },
                        "left": {
                            "button": "axis_6",
                            "value_on": 0,
                            "value_off": 32767
                        },
                        "up": {
                            "button": "axis_7",
                            "value_on": 0,
                            "value_off": 32767
                        },
                        "down": {
                            "button": "axis_7",
                            "value_on": 65534,
                            "value_off": 32767
                        },
                        "a": {
                            "button": "0",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "b": {
                            "button": "2",
                            "value_on": 1,
                            "value_off": 0
                        }
                    }
                },
                "Xbox 360 Wired Controller": {
                    "Win": {
                        "right": {
                            "button": "BUTTON_9",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "left": {
                            "button": "BUTTON_8",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "up": {
                            "button": "BUTTON_7",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "down": {
                            "button": "BUTTON_6",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "a": {
                            "button": "BUTTON_17",
                            "value_on": 1,
                            "value_off": 0
                        }
                    },
                    "Mac": {
                        "right": {
                            "button": "BUTTON_9",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "left": {
                            "button": "BUTTON_8",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "up": {
                            "button": "BUTTON_7",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "down": {
                            "button": "BUTTON_6",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "a": {
                            "button": "BUTTON_17",
                            "value_on": 1,
                            "value_off": 0
                        }
                    }
                },
                "Xbox 360 Controller (XInput STANDARD GAMEPAD)": {
                    "Win": {
                        "right": {
                            "button": "BUTTON_19",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "left": {
                            "button": "BUTTON_18",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "up": {
                            "button": "BUTTON_17",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "down": {
                            "button": "BUTTON_16",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "a": {
                            "button": "BUTTON_4",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "b": {
                            "button": "BUTTON_6",
                            "value_on": 1,
                            "value_off": 0
                        }
                    },
                    "Mac": {
                        "right": {
                            "button": "BUTTON_9",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "left": {
                            "button": "BUTTON_8",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "up": {
                            "button": "BUTTON_7",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "down": {
                            "button": "BUTTON_6",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "a": {
                            "button": "BUTTON_17",
                            "value_on": 1,
                            "value_off": 0
                        }
                    }
                },
                "Wireless Controller": {  // PS4
                    "right": {
                        "button": "BUTTON_9",
                        "value_on": 1,
                        "value_off": 0
                    },
                    "left": {
                        "button": "BUTTON_8",
                        "value_on": 1,
                        "value_off": 0
                    },
                    "up": {
                        "button": "BUTTON_7",
                        "value_on": 1,
                        "value_off": 0
                    },
                    "down": {
                        "button": "BUTTON_6",
                        "value_on": 1,
                        "value_off": 0
                    },
                    "a": {
                        "button": "BUTTON_11",
                        "value_on": 1,
                        "value_off": 0
                    }
                },
                "USB Gamepad": {  // USB NES controller
                    "Win": {
                        "right": {
                            "button": "axis_0",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "left": {
                            "button": "axis_0",
                            "value_on": -1,
                            "value_off": 0
                        },
                        "up": {
                            "button": "axis_1",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "down": {
                            "button": "axis_1",
                            "value_on": -1,
                            "value_off": 0
                        },
                        "a": {
                            "button": "1",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "b": {
                            "button": "2",
                            "value_on": 1,
                            "value_off": 0
                        }
                    },
                    "Mac": {
                        "right": {
                            "button": "AXIS_4",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "left": {
                            "button": "AXIS_4",
                            "value_on": -1,
                            "value_off": 0
                        },
                        "up": {
                            "button": "AXIS_5",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "down": {
                            "button": "AXIS_5",
                            "value_on": -1,
                            "value_off": 0
                        },
                        "a": {
                            "button": "BUTTON_7",
                            "value_on": 1,
                            "value_off": 0
                        },
                        "b": {
                            "button": "BUTTON_8",
                            "value_on": 1,
                            "value_off": 0
                        }
                    }
                }
            }
        }
    }
}
