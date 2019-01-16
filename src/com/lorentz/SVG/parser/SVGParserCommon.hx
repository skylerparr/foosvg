package com.lorentz.sVG.parser;

import com.lorentz.sVG.data.path.SVGArcToCommand;
import com.lorentz.sVG.data.path.SVGClosePathCommand;
import com.lorentz.sVG.data.path.SVGCurveToCubicCommand;
import com.lorentz.sVG.data.path.SVGCurveToCubicSmoothCommand;
import com.lorentz.sVG.data.path.SVGCurveToQuadraticCommand;
import com.lorentz.sVG.data.path.SVGCurveToQuadraticSmoothCommand;
import com.lorentz.sVG.data.path.SVGLineToCommand;
import com.lorentz.sVG.data.path.SVGLineToHorizontalCommand;
import com.lorentz.sVG.data.path.SVGLineToVerticalCommand;
import com.lorentz.sVG.data.path.SVGMoveToCommand;
import com.lorentz.sVG.data.path.SVGPathCommand;
import com.lorentz.sVG.utils.MathUtils;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class SVGParserCommon
{
    public static function parsePathData(input : String) : Array<com.lorentz.sVG.data.path.SVGPathCommand>
    {
        var commands : Array<com.lorentz.sVG.data.path.SVGPathCommand> = new Array<com.lorentz.sVG.data.path.SVGPathCommand>();
        
        for (commandString/* AS3HX WARNING could not determine type for var: commandString exp: ECall(EField(EIdent(input),match),[ERegexp([A-DF-Za-df-z][^A-Za-df-z]*,g)]) type: null */ in input.match(new as3hx.Compat.Regex('[A-DF-Za-df-z][^A-Za-df-z]*', "g")))
        {
            var type : String = commandString.charAt(0);
            var args : Array<String> = SVGParserCommon.splitNumericArgs(commandString.substr(1));
            
            if (type == "Z" || type == "z")
            {
                commands.push(new SVGClosePathCommand());
                continue;
            }
            
            var a : Int = 0;
            while (a < args.length)
            {
                if (type == "M" && a > 0)
                
                //Subsequent pairs of coordinates are treated as implicit lineto commands{
                    
                    type = "L";
                }
                if (type == "m" && a > 0)
                
                //Subsequent pairs of coordinates are treated as implicit lineto commands{
                    
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
                    default:trace("Invalid PathCommand type: " + type);
                        a = args.length;
                }
            }
        }
        
        return commands;
    }
    
    public static function splitNumericArgs(input : String) : Array<String>
    {
        var returnData : Array<String> = new Array<String>();
        
        var matchedNumbers : Array<Dynamic> = input.match(new as3hx.Compat.Regex('(?:\\+|-)?(?:(?:\\d*\\.\\d+)|(?:\\d+))(?:e(?:\\+|-)?\\d+)?', "g"));
        for (numberString in matchedNumbers)
        {
            returnData.push(numberString);
        }
        
        return returnData;
    }
    
    public static function parseTransformation(m : String) : Matrix
    {
        if (m.length == 0)
        {
            return new Matrix();
        }
        
        var transformations : Array<Dynamic> = m.match(new as3hx.Compat.Regex('(\\w+?\\s*\\([^)]*\\))', "g"));
        
        var mat : Matrix = new Matrix();
        
        if (Std.is(transformations, Array))
        {
            var i : Int = as3hx.Compat.parseInt(transformations.length - 1);
            while (i >= 0)
            {
                var parts : Array<Dynamic> = new as3hx.Compat.Regex('(\\w+?)\\s*\\(([^)]*)\\)', "").exec(transformations[i]);
                if (Std.is(parts, Array))
                {
                    var name : String = parts[1].toLowerCase();
                    var args : Array<String> = splitNumericArgs(parts[2]);
                    
                    switch (name)
                    {
                        case "matrix":
                            mat.concat(new Matrix(as3hx.Compat.parseFloat(args[0]), as3hx.Compat.parseFloat(args[1]), as3hx.Compat.parseFloat(args[2]), as3hx.Compat.parseFloat(args[3]), as3hx.Compat.parseFloat(args[4]), as3hx.Compat.parseFloat(args[5])));
                        case "translate":
                            mat.translate(as3hx.Compat.parseFloat(args[0]), (args.length > 1) ? as3hx.Compat.parseFloat(args[1]) : 0);
                        case "scale":
                            mat.scale(as3hx.Compat.parseFloat(args[0]), (args.length > 1) ? as3hx.Compat.parseFloat(args[1]) : as3hx.Compat.parseFloat(args[0]));
                        case "rotate":
                            if (args.length > 1)
                            {
                                var tx : Float = (args.length > 1) ? as3hx.Compat.parseFloat(args[1]) : 0;
                                var ty : Float = (args.length > 2) ? as3hx.Compat.parseFloat(args[2]) : 0;
                                mat.translate(-tx, -ty);
                                mat.rotate(MathUtils.degressToRadius(as3hx.Compat.parseFloat(args[0])));
                                mat.translate(tx, ty);
                            }
                            else
                            {
                                mat.rotate(MathUtils.degressToRadius(as3hx.Compat.parseFloat(args[0])));
                            }
                        case "skewx":
                            var skewXMatrix : Matrix = new Matrix();
                            skewXMatrix.c = Math.tan(MathUtils.degressToRadius(as3hx.Compat.parseFloat(args[0])));
                            mat.concat(skewXMatrix);
                        case "skewy":
                            var skewYMatrix : Matrix = new Matrix();
                            skewYMatrix.b = Math.tan(MathUtils.degressToRadius(as3hx.Compat.parseFloat(args[0])));
                            mat.concat(skewYMatrix);
                    }
                }
                i--;
            }
        }
        
        return mat;
    }
    
    public static function parseViewBox(viewBox : String) : Rectangle
    {
        if (viewBox == null || viewBox == "")
        {
            return null;
        }
        var params : Dynamic = viewBox.split(new as3hx.Compat.Regex('\\s', ""));
        return new Rectangle(Reflect.field(params, Std.string(0)), Reflect.field(params, Std.string(1)), Reflect.field(params, Std.string(2)), Reflect.field(params, Std.string(3)));
    }
    
    public static function parsePreserveAspectRatio(text : String) : Dynamic
    {
        var parts : Array<Dynamic> = new as3hx.Compat.Regex('(?:(defer)\\s+)?(\\w*)(?:\\s+(meet|slice))?', "gi").exec(text.toLowerCase());
        
        return {
            defer : parts[1] != null,
            align : parts[2] || "xmidymid",
            meetOrSlice : parts[3] || "meet"
        };
    }

    public function new()
    {
    }
}
