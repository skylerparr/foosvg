package com.lorentz.svg.display;

import com.lorentz.svg.display.base.ISVGViewBox;
import com.lorentz.svg.display.base.SVGContainer;
import flash.geom.Rectangle;

class SVGMask extends SVGContainer implements ISVGViewBox
{
    public var svgViewBox(get, set) : Rectangle;

    public function new()
    {
        super("mask");
    }
    
    private function get_svgViewBox() : Rectangle
    {
        return try cast(getAttribute("viewBox"), Rectangle) catch(e:Dynamic) null;
    }
    private function set_svgViewBox(value : Rectangle) : Rectangle
    {
        setAttribute("viewBox", value);
        return value;
    }
}
