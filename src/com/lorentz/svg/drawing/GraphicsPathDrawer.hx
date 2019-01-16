package com.lorentz.svg.drawing;

import com.lorentz.svg.utils.ArcUtils;
import com.lorentz.svg.utils.Bezier;
import com.lorentz.svg.utils.FlashPlayerUtils;
import flash.display.GraphicsPathCommand;
import flash.geom.Point;

class GraphicsPathDrawer implements IDrawer
{
    public var penX(get, never) : Float;
    public var penY(get, never) : Float;

    public var commands : Array<Int>;
    public var pathData : Array<Float>;
    
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
    
    public function new()
    {
        commands = new Array<Int>();
        pathData = new Array<Float>();
    }
    
    public function moveTo(x : Float, y : Float) : Void
    {
        commands.push(GraphicsPathCommand.MOVE_TO);
        pathData.push(x);
        pathData.push(y);
        
        _penX = x;_penY = y;
    }
    
    public function lineTo(x : Float, y : Float) : Void
    {
        commands.push(GraphicsPathCommand.LINE_TO);
        pathData.push(x);
        pathData.push(y);
        
        _penX = x;_penY = y;
    }
    
    public function curveTo(cx : Float, cy : Float, x : Float, y : Float) : Void
    {
        commands.push(GraphicsPathCommand.CURVE_TO);
        pathData.push(cx);
        pathData.push(cy);
        pathData.push(x);
        pathData.push(y);
        
        _penX = x;_penY = y;
    }
    
    public function cubicCurveTo(cx1 : Float, cy1 : Float, cx2 : Float, cy2 : Float, x : Float, y : Float) : Void
    {
        if (FlashPlayerUtils.supportsCubicCurves)
        {
            commands.push(Reflect.field(GraphicsPathCommand, "CUBIC_CURVE_TO"));
            pathData.push(cx1);
            pathData.push(cy1);
            pathData.push(cx2);
            pathData.push(cy2);
            pathData.push(x);
            pathData.push(y);
            
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
        
        // Loop for drawing arc segments
        var i : Int = 0;
        while (i < curves.length)
        {
            curveTo(curves[i].c.x, curves[i].c.y, curves[i].p.x, curves[i].p.y);
            i++;
        }
    }
}
