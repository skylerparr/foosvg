package com.lorentz.svg.display;

import com.lorentz.svg.display.base.SVGShape;
import com.lorentz.svg.drawing.IDrawer;
import com.lorentz.svg.utils.SVGUtil;
import com.lorentz.svg.display.base.SVGElement;

class SVGRect extends SVGShape
{
    public var svgX(get, set) : String;
    public var svgY(get, set) : String;
    public var svgWidth(get, set) : String;
    public var svgHeight(get, set) : String;
    public var svgRx(get, set) : String;
    public var svgRy(get, set) : String;

    private var _xUnits : Float;
    private var _yUnits : Float;
    private var _widthUnits : Float;
    private var _heightUnits : Float;
    private var _rxUnits : Float;
    private var _ryUnits : Float;
    
    public function new()
    {
        super("rect");
    }
    
    private var _svgX : String;
    private function get_svgX() : String
    {
        return _svgX;
    }
    private function set_svgX(value : String) : String
    {
        if (_svgX != value)
        {
            _svgX = value;
            invalidateRender();
        }
        return value;
    }
    
    private var _svgY : String;
    private function get_svgY() : String
    {
        return _svgY;
    }
    private function set_svgY(value : String) : String
    {
        if (_svgY != value)
        {
            _svgY = value;
            invalidateRender();
        }
        return value;
    }
    
    private var _svgWidth : String;
    private function get_svgWidth() : String
    {
        return _svgWidth;
    }
    private function set_svgWidth(value : String) : String
    {
        if (_svgWidth != value)
        {
            _svgWidth = value;
            invalidateRender();
        }
        return value;
    }
    
    private var _svgHeight : String;
    private function get_svgHeight() : String
    {
        return _svgHeight;
    }
    private function set_svgHeight(value : String) : String
    {
        if (_svgHeight != value)
        {
            _svgHeight = value;
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
        if (_svgRx != value)
        {
            _svgRx = value;
            invalidateRender();
        }
        return value;
    }
    
    private var _svgRy : String;
    private function get_svgRy() : String
    {
        return _svgRy;
    }
    
    private function set_svgRy(value : String) : String
    {
        if (_svgRy != value)
        {
            _svgRy = value;
            invalidateRender();
        }
        return value;
    }
    
    override private function beforeDraw() : Void
    {
        super.beforeDraw();
        
        _xUnits = getViewPortUserUnit(svgX, SVGUtil.WIDTH);
        _yUnits = getViewPortUserUnit(svgY, SVGUtil.HEIGHT);
        _widthUnits = getViewPortUserUnit(svgWidth, SVGUtil.WIDTH);
        _heightUnits = getViewPortUserUnit(svgHeight, SVGUtil.HEIGHT);
        
        _rxUnits = 0;
        _ryUnits = 0;
        
        if (svgRx != null)
        {
            _rxUnits = getViewPortUserUnit(svgRx, SVGUtil.WIDTH);
            if (svgRy == null)
            {
                _ryUnits = _rxUnits;
            }
        }
        if (svgRy != null)
        {
            _ryUnits = getViewPortUserUnit(svgRy, SVGUtil.HEIGHT);
            if (svgRx == null)
            {
                _rxUnits = _ryUnits;
            }
        }
    }
    
    override private function drawToDrawer(drawer : IDrawer) : Void
    {
        if (_rxUnits == 0 && _ryUnits == 0)
        {
            drawer.moveTo(_xUnits, _yUnits);
            drawer.lineTo(_xUnits + _widthUnits, _yUnits);
            drawer.lineTo(_xUnits + _widthUnits, _yUnits + _heightUnits);
            drawer.lineTo(_xUnits, _yUnits + _heightUnits);
            drawer.lineTo(_xUnits, _yUnits);
        }
        else
        {
            drawer.moveTo(_xUnits + _rxUnits, _yUnits);
            drawer.lineTo(_xUnits + _widthUnits - _rxUnits, _yUnits);
            drawer.arcTo(_ryUnits, _rxUnits, 90, false, true, _xUnits + _widthUnits, _yUnits + _ryUnits);
            drawer.lineTo(_xUnits + _widthUnits, _yUnits + _heightUnits - _ryUnits);
            drawer.arcTo(_ryUnits, _rxUnits, 90, false, true, _xUnits + _widthUnits - _rxUnits, _yUnits + _heightUnits);
            drawer.lineTo(_xUnits + _rxUnits, _yUnits + _heightUnits);
            drawer.arcTo(_ryUnits, _rxUnits, 90, false, true, _xUnits, _yUnits + _heightUnits - _ryUnits);
            drawer.lineTo(_xUnits, _yUnits + _ryUnits);
            drawer.arcTo(_ryUnits, _rxUnits, 90, false, true, _xUnits + _rxUnits, _yUnits);
        }
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGRect = try cast(super.clone(), SVGRect) catch(e:Dynamic) null;
        c.svgX = svgX;
        c.svgY = svgY;
        c.svgWidth = svgWidth;
        c.svgHeight = svgHeight;
        c.svgRx = svgRx;
        c.svgRy = svgRy;
        return c;
    }
}
