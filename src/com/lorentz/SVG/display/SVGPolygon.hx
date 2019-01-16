package com.lorentz.sVG.display;

import com.lorentz.sVG.display.base.SVGShape;
import com.lorentz.sVG.drawing.IDrawer;

class SVGPolygon extends SVGShape
{
    public var points(get, set) : Array<String>;

    public function new()
    {
        super("polygon");
    }
    
    private var _points : Array<String>;
    private function get_points() : Array<String>
    {
        return _points;
    }
    private function set_points(value : Array<String>) : Array<String>
    {
        _points = value;
        invalidateRender();
        return value;
    }
    
    override private function drawToDrawer(drawer : IDrawer) : Void
    {
        if (points.length > 2)
        {
            drawer.moveTo(as3hx.Compat.parseFloat(points[0]), as3hx.Compat.parseFloat(points[1]));
            
            var j : Int = 2;
            while (j < points.length - 1)
            {
                drawer.lineTo(as3hx.Compat.parseFloat(points[j++]), as3hx.Compat.parseFloat(points[j++]));
            }
            
            drawer.lineTo(as3hx.Compat.parseFloat(points[0]), as3hx.Compat.parseFloat(points[1]));
        }
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGPolygon = try cast(super.clone(), SVGPolygon) catch(e:Dynamic) null;
        c.points = points.copy();
        return c;
    }
}
