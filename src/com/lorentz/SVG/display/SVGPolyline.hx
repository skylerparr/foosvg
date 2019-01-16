package com.lorentz.sVG.display;

import com.lorentz.sVG.display.base.SVGShape;
import com.lorentz.sVG.drawing.IDrawer;

class SVGPolyline extends SVGShape
{
    public var points(get, set) : Array<String>;

    public function new()
    {
        super("polyline");
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
            
            var i : Int = 2;
            while (i < points.length - 1)
            {
                drawer.lineTo(as3hx.Compat.parseFloat(points[i++]), as3hx.Compat.parseFloat(points[i++]));
            }
        }
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGPolyline = try cast(super.clone(), SVGPolyline) catch(e:Dynamic) null;
        c.points = points.copy();
        return c;
    }
}
