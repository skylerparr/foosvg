package com.lorentz.svg.parser;

import com.lorentz.svg.data.path.SVGArcToCommand;
import com.lorentz.svg.data.path.SVGClosePathCommand;
import com.lorentz.svg.data.path.SVGCurveToCubicCommand;
import com.lorentz.svg.data.path.SVGCurveToCubicSmoothCommand;
import com.lorentz.svg.data.path.SVGCurveToQuadraticCommand;
import com.lorentz.svg.data.path.SVGCurveToQuadraticSmoothCommand;
import com.lorentz.svg.data.path.SVGLineToCommand;
import com.lorentz.svg.data.path.SVGLineToHorizontalCommand;
import com.lorentz.svg.data.path.SVGLineToVerticalCommand;
import com.lorentz.svg.data.path.SVGMoveToCommand;
import com.lorentz.svg.data.path.SVGPathCommand;
import com.lorentz.svg.utils.MathUtils;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class SVGParserCommon {
    public static function parsePathData(input: String): Array<com.lorentz.svg.data.path.SVGPathCommand> {
        var commands: Array<com.lorentz.svg.data.path.SVGPathCommand> = new Array<com.lorentz.svg.data.path.SVGPathCommand>();

        var ereg = ~/[A-DF-Za-df-z][^A-Za-df-z]*/g;
        var matches: Array<String> = [];
        ereg.map(input, function(reg: EReg): String {
            matches.push(reg.matched(0));
            return "";
        });

        for (commandString in matches) {
            var type: String = commandString.charAt(0);

            var args: Array<String> = SVGParserCommon.splitNumericArgs(commandString.substr(1));

            if (type == "Z" || type == "z") {
                commands.push(new SVGClosePathCommand());
                continue;
            }

            var a: Int = 0;
            while (a < args.length) {
                if (type == "M" && a > 0) {
                    type = "L";
                }
                if (type == "m" && a > 0) {

                    type = "l";
                }

                switch (type)
                {
                    case "M", "m":
                        commands.push(new SVGMoveToCommand(type == "M", as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++])));
                    case "L", "l":
                        commands.push(new SVGLineToCommand(type == "L", as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++])));
                    case "H", "h":
                        commands.push(new SVGLineToHorizontalCommand(type == "H", as3hx.Compat.parseFloat(args[a++])));
                    case "V", "v":
                        commands.push(new SVGLineToVerticalCommand(type == "V", as3hx.Compat.parseFloat(args[a++])));
                    case "Q", "q":
                        commands.push(new SVGCurveToQuadraticCommand(type == "Q", as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++])));
                    case "T", "t":
                        commands.push(new SVGCurveToQuadraticSmoothCommand(type == "T", as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++])));
                    case "C", "c":
                        commands.push(new SVGCurveToCubicCommand(type == "C", as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++])));
                    case "S", "s":
                        commands.push(new SVGCurveToCubicSmoothCommand(type == "S", as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++])));
                    case "A", "a":
                        commands.push(new SVGArcToCommand(type == "A", as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++]), args[a++] != "0", args[a++] != "0", as3hx.Compat.parseFloat(args[a++]), as3hx.Compat.parseFloat(args[a++])));
                    default:
                        trace("Invalid PathCommand type: " + type);
                        a = args.length;
                }
            }
        }

        return commands;
    }

    public static function splitNumericArgs(input: String): Array<String> {
        var returnData: Array<String> = new Array<String>();

        var ereg: EReg = ~/(?:\+|-)?(?:(?:\d*\.\d+)|(?:\d+))(?:e(?:\+|-)?\d+)?/g;
        var matches: Array<String> = [];
        ereg.map(input, function(reg: EReg): String {
            matches.push(reg.matched(0));
            return "";
        });
        for (numberString in matches) {
            returnData.push(numberString);
        }

        return returnData;
    }

    public static function parseTransformation(m: String): Matrix {
        if (m.length == 0) {
            return new Matrix();
        }

        var ereg: EReg = new EReg('(\\w+?\\s*\\([^)]*\\))', "g");
        var transformations: Array<Dynamic> = ereg.split(m);

        var mat: Matrix = new Matrix();

        if (Std.is(transformations, Array)) {
            var i: Int = as3hx.Compat.parseInt(transformations.length - 1);
            while (i >= 0) {
                var ereg: EReg = new EReg('(\\w+?)\\s*\\(([^)]*)\\)', "");
                var parts: Array<Dynamic> = ereg.split(transformations[i]);
                if (Std.is(parts, Array)) {
                    var name: String = parts[1].toLowerCase();
                    var args: Array<String> = splitNumericArgs(parts[2]);

                    switch (name)
                    {
                        case "matrix":
                            mat.concat(new Matrix(as3hx.Compat.parseFloat(args[0]), as3hx.Compat.parseFloat(args[1]), as3hx.Compat.parseFloat(args[2]), as3hx.Compat.parseFloat(args[3]), as3hx.Compat.parseFloat(args[4]), as3hx.Compat.parseFloat(args[5])));
                        case "translate":
                            mat.translate(as3hx.Compat.parseFloat(args[0]), (args.length > 1) ? as3hx.Compat.parseFloat(args[1]) : 0);
                        case "scale":
                            mat.scale(as3hx.Compat.parseFloat(args[0]), (args.length > 1) ? as3hx.Compat.parseFloat(args[1]) : as3hx.Compat.parseFloat(args[0]));
                        case "rotate":
                            if (args.length > 1) {
                                var tx: Float = (args.length > 1) ? as3hx.Compat.parseFloat(args[1]) : 0;
                                var ty: Float = (args.length > 2) ? as3hx.Compat.parseFloat(args[2]) : 0;
                                mat.translate(-tx, -ty);
                                mat.rotate(MathUtils.degressToRadius(as3hx.Compat.parseFloat(args[0])));
                                mat.translate(tx, ty);
                            }
                            else {
                                mat.rotate(MathUtils.degressToRadius(as3hx.Compat.parseFloat(args[0])));
                            }
                        case "skewx":
                            var skewXMatrix: Matrix = new Matrix();
                            skewXMatrix.c = Math.tan(MathUtils.degressToRadius(as3hx.Compat.parseFloat(args[0])));
                            mat.concat(skewXMatrix);
                        case "skewy":
                            var skewYMatrix: Matrix = new Matrix();
                            skewYMatrix.b = Math.tan(MathUtils.degressToRadius(as3hx.Compat.parseFloat(args[0])));
                            mat.concat(skewYMatrix);
                    }
                }
                i--;
            }
        }

        return mat;
    }

    public static function parseViewBox(viewBox: String): Rectangle {
        if (viewBox == null || viewBox == "") {
            return null;
        }
        var ereg: EReg = new EReg('\\s', "");
        var params: Dynamic = ereg.split(viewBox);
        return new Rectangle(Reflect.field(params, Std.string(0)), Reflect.field(params, Std.string(1)), Reflect.field(params, Std.string(2)), Reflect.field(params, Std.string(3)));
    }

    public static function parsePreserveAspectRatio(text: String): Dynamic {
        var parts: Array<Dynamic> = new as3hx.Compat.Regex('(?:(defer)\\s+)?(\\w*)(?:\\s+(meet|slice))?', "gi").exec(text.toLowerCase());

        var parts2 = parts[2];
        if(parts2 == null) {
            parts2 = "xmidymid";
        }
        var parts3 = parts[3];
        if(parts3 == null) {
            parts3 = "meet";
        }

        return {
            defer : parts[1] != null,
            align : parts2,
            meetOrSlice : parts3
        };
    }

    public function new() {
    }
}
