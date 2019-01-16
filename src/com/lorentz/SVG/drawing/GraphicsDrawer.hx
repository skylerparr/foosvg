package com.lorentz.sVG.drawing;

import com.lorentz.sVG.utils.ArcUtils;
import com.lorentz.sVG.utils.Bezier;
import com.lorentz.sVG.utils.FlashPlayerUtils;
import flash.display.Graphics;
import flash.geom.Point;

class GraphicsDrawer implements IDrawer
{
    public var penX(get, never) : Float;
    public var penY(get, never) : Float;

    private var _graphics : Graphics;
    
    private var _penX : Float = 0;
    private function get_penX() : Float
    {
        return _penX;
    }
    
    private var _penY : Float = 0;
    private function get_penY() : Float
    {
        return _penY;
    }
    
    public function new(graphics : Graphics)
    {
        _graphics = graphics;
    }
    
    public function moveTo(x : Float, y : Float) : Void
    {
        _graphics.moveTo(x, y);
        _penX = x;_penY = y;
    }
    
    public function lineTo(x : Float, y : Float) : Void
    {
        _graphics.lineTo(x, y);
        _penX = x;_penY = y;
    }
    
    public function curveTo(cx : Float, cy : Float, x : Float, y : Float) : Void
    {
        _graphics.curveTo(cx, cy, x, y);
        _penX = x;_penY = y;
    }
    
    public function cubicCurveTo(cx1 : Float, cy1 : Float, cx2 : Float, cy2 : Float, x : Float, y : Float) : Void
    {
        if (FlashPlayerUtils.supportsCubicCurves)
        {
            Reflect.field(_graphics, "cubicCurveTo")(cx1, cy1, cx2, cy2, x, y);
            _penX = x;_penY = y;
        }
        //Convert cubic curve to quadratic curves
        else
        {
            
            var anchor1 : Point = new Point(_penX, _penY);
            var control1 : Point = new Point(cx1, cy1);
            var control2 : Point = new Point(cx2, cy2);
            var anchor2 : Point = new Point(x, y);
            
            var bezier : Bezier = new Bezier(anchor1, control1, control2, anchor2);
            
            for (quadP/* AS3HX WARNING could not determine type for var: quadP exp: EField(EIdent(bezier),QPts) type: null */ in bezier.QPts)
            {
                curveTo(quadP.c.x, quadP.c.y, quadP.p.x, quadP.p.y);
            }
        }
    }
    
    public function arcTo(rx : Float, ry : Float, angle : Float, largeArcFlag : Bool, sweepFlag : Bool, x : Float, y : Float) : Void
    {
        var ellipticalArc : Dynamic = ArcUtils.computeSvgArc(rx, ry, angle, largeArcFlag, sweepFlag, x, y, _penX, _penY);
        
        var curves : Array<Dynamic> = ArcUtils.convertToCurves(ellipticalArc.cx, ellipticalArc.cy, ellipticalArc.startAngle, ellipticalArc.arc, ellipticalArc.radius, ellipticalArc.yRadius, ellipticalArc.xAxisRotation);
        
        var i : Int = 0;
        while (i < curves.length)
        {
            curveTo(curves[i].c.x, curves[i].c.y, curves[i].p.x, curves[i].p.y);
            i++;
        }
    }
}
