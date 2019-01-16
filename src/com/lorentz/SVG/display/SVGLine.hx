package com.lorentz.sVG.display;

import com.lorentz.sVG.display.base.SVGShape;
import com.lorentz.sVG.drawing.IDrawer;
import com.lorentz.sVG.utils.SVGUtil;

class SVGLine extends SVGShape
{
    public var svgX1(get, set) : String;
    public var svgX2(get, set) : String;
    public var svgY1(get, set) : String;
    public var svgY2(get, set) : String;

    private var _x1Units : Float;
    private var _y1Units : Float;
    private var _x2Units : Float;
    private var _y2Units : Float;
    
    public function new()
    {
        super("line");
    }
    
    private var _svgX1 : String;
    private function get_svgX1() : String
    {
        return _svgX1;
    }
    private function set_svgX1(value : String) : String
    {
        if (_svgX1 != value)
        {
            _svgX1 = value;
            invalidateRender();
        }
        return value;
    }
    
    private var _svgX2 : String;
    private function get_svgX2() : String
    {
        return _svgX2;
    }
    private function set_svgX2(value : String) : String
    {
        if (_svgX2 != value)
        {
            _svgX2 = value;
            invalidateRender();
        }
        return value;
    }
    
    private var _svgY1 : String;
    private function get_svgY1() : String
    {
        return _svgY1;
    }
    
    private function set_svgY1(value : String) : String
    {
        if (_svgY1 != value)
        {
            _svgY1 = value;
            invalidateRender();
        }
        return value;
    }
    
    private var _svgY2 : String;
    private function get_svgY2() : String
    {
        return _svgY2;
    }
    
    private function set_svgY2(value : String) : String
    {
        if (_svgY2 != value)
        {
            _svgY2 = value;
            invalidateRender();
        }
        return value;
    }
    
    override private function get_hasFill() : Bool
    {
        return false;
    }
    
    override private function beforeDraw() : Void
    {
        super.beforeDraw();
        
        _x1Units = getViewPortUserUnit(svgX1, SVGUtil.WIDTH);
        _y1Units = getViewPortUserUnit(svgY1, SVGUtil.HEIGHT);
        _x2Units = getViewPortUserUnit(svgX2, SVGUtil.WIDTH);
        _y2Units = getViewPortUserUnit(svgY2, SVGUtil.HEIGHT);
    }
    
    override private function drawToDrawer(drawer : IDrawer) : Void
    {
        drawer.moveTo(_x1Units, _y1Units);
        drawer.lineTo(_x2Units, _y2Units);
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGLine = try cast(super.clone(), SVGLine) catch(e:Dynamic) null;
        c.svgX1 = svgX1;
        c.svgX2 = svgX2;
        c.svgY1 = svgY1;
        c.svgY2 = svgY2;
        return c;
    }
}
