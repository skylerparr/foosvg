package com.lorentz.svg.display;

import com.lorentz.svg.display.base.ISVGPreserveAspectRatio;
import com.lorentz.svg.display.base.ISVGViewBox;
import com.lorentz.svg.display.base.SVGContainer;
import flash.geom.Rectangle;

class SVGSymbol extends SVGContainer implements ISVGViewBox implements ISVGPreserveAspectRatio
{
    public var svgViewBox(get, set) : Rectangle;
    public var svgPreserveAspectRatio(get, set) : String;

    public function new()
    {
        super("symbol");
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
    
    private function get_svgPreserveAspectRatio() : String
    {
        return Std.string(getAttribute("preserveAspectRatio"));
    }
    private function set_svgPreserveAspectRatio(value : String) : String
    {
        setAttribute("preserveAspectRatio", value);
        return value;
    }
}
