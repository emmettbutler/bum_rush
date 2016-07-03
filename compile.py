import argparse
import datetime as dt
import os
import subprocess


def _get_mainclass():
    return "MenuState", "MenuState"


def write_entry_point():
    main_class, main_classpath = _get_mainclass()
    entry_point_class = "{}main".format(main_class.lower())

    with open("src/{}.as".format(entry_point_class), "w") as f:
        f.write(
"""
package {{
    import {main_classpath};
    import org.flixel.*;
    import flash.ui.GameInput;
    [SWF(width="640", height="480", backgroundColor="#000000")]
    [Frame(factoryClass="{preloader_class}")]

    public class {entry_point_class} extends FlxGame {{
        private static var gameInput:GameInput;
        public function {entry_point_class}(){{
            gameInput = new GameInput();
            super(640, 480, {main_class}, 1);
        }}
    }}
}}
""".format(preloader_class="{}_loader".format(main_class.lower()),
           entry_point_class=entry_point_class,
           main_class=main_class,
           main_classpath=main_classpath))
    return entry_point_class


def write_preloader():
    main_class, main_classpath = _get_mainclass()
    entry_point_class = "{}main".format(main_class.lower())
    preloader_class = "{}_loader".format(main_class.lower())

    with open("src/{}.as".format(preloader_class), "w") as f:
        f.write(
"""
package
{{
    import org.flixel.system.FlxPreloader;
    public class {preloader_class} extends FlxPreloader {{
        public function {preloader_class}() {{
            className = "{entry_point_class}";
            super();
        }}
    }}
}}
""".format(preloader_class=preloader_class,
           entry_point_class=entry_point_class))
    return preloader_class


def compile_main(entry_point_class,
                 libpath,
                 debug_level,
                 short_dialogue=False,
                 disable_saves=False,
                 windowed=False,
                 platform="air"):
    stacktraces = "true"
    omit_trace = "false"
    debug = "true"
    debug_flag = "true"
    test_flag = "true"
    if debug_level == "test":
        debug_flag = "false"
        test_flag = "true"
    elif debug_level == "release":
        debug_flag = "false"
        omit_trace = "true"
        stacktraces = "false"
        debug = "false"
        test_flag = "false"
    swfpath = "src/{entry_point_class}{ts}.swf".format(
        entry_point_class=entry_point_class,
        ts="")
    extlib = ""
    if platform == "windows":
        extlib = "-external-library-path+=extensions\\ane\NativeJoystick.swc"
    command = [
        "amxmlc", "src/{entry_point_class}.as".format(entry_point_class=entry_point_class), "-o",
        swfpath,
        "-compiler.include-libraries", libpath,
        extlib,
        "-use-network=false", "-verbose-stacktraces={}".format(stacktraces),
        "-debug={}".format(debug),
        "{}".format("-advanced-telemetry" if debug else ""),
        "-omit-trace-statements={}".format(omit_trace),
        "-define=CONFIG::debug,{}".format(debug_flag),
        "-define=CONFIG::test,{}".format(test_flag),
        "-define=CONFIG::include_extension,{}".format(str(platform == "windows").lower()),
        '-define=CONFIG::platform,"{}"'.format(platform),
    ]
    print " ".join(command)
    subprocess.check_call(command, shell=platform == "windows")
    return swfpath


def get_conf_path(entry_point_class):
    return "{}.xml".format(entry_point_class)


def write_conf_file(swf_path, entry_point_class, version_id, platform):
    conf_path = get_conf_path(entry_point_class)
    extlibs = ""
    if platform == "windows":
        extlibs = """
<supportedProfiles>extendedDesktop</supportedProfiles>
<extensions>
    <extensionID>com.iam2bam.ane.nativejoystick</extensionID>
</extensions>"""

    with open(conf_path, "w") as f:
        f.write(
"""
<application xmlns="http://ns.adobe.com/air/application/{version_id}">
    <id>com.emmettbutler.BumRush</id>
    <versionNumber>1.0</versionNumber>
    <filename>BumRush-{ts}</filename>
    <icon>
        <image128x128>assets/logosmall.png</image128x128>
    </icon>
    <initialWindow>
        <content>{swf_path}</content>
        <visible>true</visible>
        <width>640</width>
        <height>480</height>
        <maximizable>false</maximizable>
        <resizable>false</resizable>
    </initialWindow>
    {extlibs}
</application>
""".format(version_id=version_id,
           ts=dt.datetime.now().strftime('%Y.%m.%d.%H.%M.%S'),
           swf_path=swf_path,
           extlibs=extlibs)
    )
    return conf_path


def run_main(conf_file, runtime="", platform="air"):
    if runtime:
        runtime = "-runtime {}".format(runtime)
    extdir = ""
    if platform == "windows":
        extdir = "-extdir extensions\\ane_unzipped -profile extendedDesktop"
    command = "adl {runtime} {extdir} {conf_path}".format(runtime=runtime,
                                                          conf_path=conf_file,
                                                          extdir=extdir)
    print command
    subprocess.call(command.split())


def package_application(entry_point_class, swf_path, platform="air", outfile_name="BumRush"):
    """
    To generate cibelecert.pfx:
        adt -certificate -cn SelfSign -ou QE -o "Emmett and Nina" -c US 2048-RSA bootycallcert.pfx AmanoJyakku!
    """
    command = 'adt -certificate -cn SelfSign -ou QE -o "Emmett_Butler" -c US 2048-RSA bootycallcert.pfx AmanoJyakku!'
    print command
    subprocess.call(command.split(), shell=platform == "windows")

    outfile = "{}.air".format(outfile_name)
    target = ""
    extdir = ""
    if platform == "mac":
        target = "-target bundle"
        outfile = "{}.app".format(outfile_name)
    elif platform == "windows":
        target = "-target bundle"
        outfile = outfile_name
        extdir = "-extdir extensions\\ane"
    command = "adt -package -storetype pkcs12 -keystore bootycallcert.pfx {tsa} {target} {outfile} {entry_point_class}.xml {swf_path} assets {extdir}".format(
        entry_point_class=entry_point_class, swf_path=swf_path, target=target,
        extdir=extdir, outfile=outfile, tsa="-tsa none" if platform == "air" else "")
    print command
    subprocess.call(command.split(), shell=platform == "windows")


def main():
    libpath = args.libpath[0]

    entry_point_class = write_entry_point()

    if args.run_only:
        run_main(get_conf_path(entry_point_class), platform=args.platform)
    else:
        preloader_class = write_preloader()
        swf_path = compile_main(entry_point_class.split('.')[-1], libpath,
                                args.debug_level[0],
                                platform=args.platform)
        conf_path = write_conf_file(swf_path, entry_point_class,
                                    args.version_id[0], args.platform)

        if args.package:
            package_application(entry_point_class, swf_path, platform=args.platform,
                                outfile_name=args.outfile_name)
        else:
            run_main(conf_path, platform=args.platform)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Compile Cibele")
    parser.add_argument('--libpath', '-l', metavar="LIBPATH", type=str,
                        nargs=1,
                        help="The name of the flex directory in /opt")
    parser.add_argument('--version_id', '-v', metavar="VERSION_ID", type=str,
                        nargs=1, default=["3.1"],
                        help="The xml namespace version to compile against")
    parser.add_argument('--outfile_name', '-o', metavar="OUTFILE_NAME", type=str,
                        default="BumRush",
                        help="The name of the output file to generate during packaging, without extension")
    parser.add_argument('--package', '-p', action="store_true",
                        help="Build an executable")
    parser.add_argument('--platform', '-t', type=str, default="air",
                        help="The platform for which to build an executable (windows | mac | air)")
    parser.add_argument('--run_only', '-r', action="store_true",
                        help="Don't compile, just run")
    parser.add_argument('--debug_level', '-d', metavar="DBGLEVEL", type=str,
                        default=["test"], nargs=1,
                        help="Debug level to compile under. One of [debug|test|release]")
    args = parser.parse_args()

    main()
