package com.lorentz.svg.display;

import com.lorentz.svg.display.base.SVGShape;
import com.lorentz.svg.drawing.IDrawer;
import com.lorentz.svg.utils.SVGUtil;
import flash.display.Graphics;

class SVGCircle extends SVGShape
{
    public var svgCx(get, set) : String;
    public var svgCy(get, set) : String;
    public var svgR(get, set) : String;

    private var _cxUnits : Float;
    private var _cyUnits : Float;
    private var _rUnits : Float;
    
    public function new()
    {
        super("circle");
    }
    
    private var _svgCx : String;
    private function get_svgCx() : String
    {
        return _svgCx;
    }
    private function set_svgCx(value : String) : String
    {
        if (_svgCx != value)
        {
            _svgCx = value;
            invalidateRender();
        }
        return value;
    }
    
    private var _svgCy : String;
    private function get_svgCy() : String
    {
        return _svgCy;
    }
    private function set_svgCy(value : String) : String
    {
        if (_svgCy != value)
        {
            _svgCy = value;
            invalidateRender();
        }
        return value;
    }
    
    private var _svgR : String;
    private function get_svgR() : String
    {
        return _svgR;
    }
    private function set_svgR(value : String) : String
    {
        _svgR = value;
        invalidateRender();
        return value;
    }
    
    override private function beforeDraw() : Void
    {
        super.beforeDraw();
        
        _cxUnits = getViewPortUserUnit(svgCx, SVGUtil.WIDTH);
        _cyUnits = getViewPortUserUnit(svgCy, SVGUtil.HEIGHT);
        _rUnits = getViewPortUserUnit(svgR, SVGUtil.WIDTH);
    }
    
    override private function drawToDrawer(drawer : IDrawer) : Void
    {
        drawer.moveTo(_cxUnits + _rUnits, _cyUnits);
        drawer.arcTo(_rUnits, _rUnits, 0, true, false, _cxUnits - _rUnits, _cyUnits);
        drawer.arcTo(_rUnits, _rUnits, 0, true, false, _cxUnits + _rUnits, _cyUnits);
    }
    
    override private function drawDirectlyToGraphics(graphics : Graphics) : Void
    {
        graphics.drawCircle(_cxUnits, _cyUnits, _rUnits);
    }
    
    override private function get_hasDrawDirectlyToGraphics() : Bool
    {
        return true;
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGCircle = try cast(super.clone(), SVGCircle) catch(e:Dynamic) null;
        c.svgCx = svgCx;
        c.svgCy = svgCy;
        c.svgR = svgR;
        return c;
    }
}
