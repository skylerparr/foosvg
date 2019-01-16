package com.lorentz.sVG.display;

import com.lorentz.sVG.display.base.ISVGViewBox;
import com.lorentz.sVG.display.base.ISVGViewPort;
import com.lorentz.sVG.display.base.SVGContainer;
import flash.geom.Rectangle;

class SVG extends SVGContainer implements ISVGViewPort implements ISVGViewBox
{
    public var svgViewBox(get, set) : Rectangle;
    public var svgPreserveAspectRatio(get, set) : String;
    public var svgX(get, set) : String;
    public var svgY(get, set) : String;
    public var svgWidth(get, set) : String;
    public var svgHeight(get, set) : String;
    public var svgOverflow(get, set) : String;

    public function new()
    {
        super("svg");
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
    
    private function get_svgX() : String
    {
        return Std.string(getAttribute("x"));
    }
    private function set_svgX(value : String) : String
    {
        setAttribute("x", value);
        return value;
    }
    
    private function get_svgY() : String
    {
        return Std.string(getAttribute("y"));
    }
    private function set_svgY(value : String) : String
    {
        setAttribute("y", value);
        return value;
    }
    
    private function get_svgWidth() : String
    {
        return Std.string(getAttribute("width"));
    }
    private function set_svgWidth(value : String) : String
    {
        setAttribute("width", value);
        return value;
    }
    
    private function get_svgHeight() : String
    {
        return Std.string(getAttribute("height"));
    }
    private function set_svgHeight(value : String) : String
    {
        setAttribute("height", value);
        return value;
    }
    
    private function get_svgOverflow() : String
    {
        return Std.string(getAttribute("overflow"));
    }
    private function set_svgOverflow(value : String) : String
    {
        setAttribute("overflow", value);
        return value;
    }
}
