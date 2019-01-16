package com.lorentz.sVG.utils;

import flash.display.Graphics;
import flash.display.GraphicsPathCommand;

class FlashPlayerUtils
{
    public static var supportsCubicCurves(get, never) : Bool;

    private static var _supportsCubicCurves : Dynamic = null;
    private static function get_supportsCubicCurves() : Bool
    {
        if (_supportsCubicCurves == null)
        {
            _supportsCubicCurves = graphicsHasCubicCurveToMethod() && graphicsPathCommandHasCubicCurveToConstant();
        }
        
        return _supportsCubicCurves;
    }
    
    private static function graphicsHasCubicCurveToMethod() : Bool
    {
        return FastXML.filterNodes(describeType(Graphics).factory.method, function(x:FastXML) {
                    if(x.att.name == "cubicCurveTo")
                        return true;
                    return false;

                }).length() > 0;
    }
    
    private static function graphicsPathCommandHasCubicCurveToConstant() : Bool
    {
        return Lambda.has(GraphicsPathCommand, "CUBIC_CURVE_TO");
    }

    public function new()
    {
    }
}
