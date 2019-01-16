package com.lorentz.svg.display;

import com.lorentz.svg.display.base.SVGShape;
import com.lorentz.svg.drawing.IDrawer;
import com.lorentz.svg.utils.SVGUtil;
import flash.display.Graphics;

class SVGEllipse extends SVGShape
{
    public var svgCx(get, set) : String;
    public var svgCy(get, set) : String;
    public var svgRx(get, set) : String;
    public var svgRy(get, set) : String;

    private var _cxUnits : Float;
    private var _cyUnits : Float;
    private var _rxUnits : Float;
    private var _ryUnits : Float;
    
    public function new()
    {
        super("ellipse");
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
    
    private var _svgRx : String;
    private function get_svgRx() : String
    {
        return _svgRx;
    }
    private function set_svgRx(value : String) : String
    {
        _svgRx = value;
        invalidateRender();
        return value;
    }
    
    private var _svgRy : String;
    private function get_svgRy() : String
    {
        return _svgRy;
    }
    private function set_svgRy(value : String) : String
    {
        _svgRy = value;
        invalidateRender();
        return value;
    }
    
    override private function beforeDraw() : Void
    {
        super.beforeDraw();
        
        _cxUnits = getViewPortUserUnit(svgCx, SVGUtil.WIDTH);
        _cyUnits = getViewPortUserUnit(svgCy, SVGUtil.HEIGHT);
        _rxUnits = getViewPortUserUnit(svgRx, SVGUtil.WIDTH);
        _ryUnits = getViewPortUserUnit(svgRy, SVGUtil.HEIGHT);
    }
    
    override private function drawToDrawer(drawer : IDrawer) : Void
    {
        drawer.moveTo(_cxUnits + _rxUnits, _cyUnits);
        drawer.arcTo(_rxUnits, _ryUnits, 0, true, false, _cxUnits - _rxUnits, _cyUnits);
        drawer.arcTo(_rxUnits, _ryUnits, 0, true, false, _cxUnits + _rxUnits, _cyUnits);
    }
    
    override private function drawDirectlyToGraphics(graphics : Graphics) : Void
    {
        graphics.drawEllipse(_cxUnits - _rxUnits, _cyUnits - _ryUnits, _rxUnits * 2, _ryUnits * 2);
    }
    
    override private function get_hasDrawDirectlyToGraphics() : Bool
    {
        return true;
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGEllipse = try cast(super.clone(), SVGEllipse) catch(e:Dynamic) null;
        c.svgCx = svgCx;
        c.svgCy = svgCy;
        c.svgRx = svgRx;
        c.svgRy = svgRy;
        return c;
    }
}
