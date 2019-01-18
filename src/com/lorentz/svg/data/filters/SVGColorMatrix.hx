package com.lorentz.svg.data.filters;

import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;

class SVGColorMatrix implements ISVGFilter
{
    public var type : String;
    public var values : Array<Float>;
    
    public function getFlashFilter() : BitmapFilter
    {
        return new ColorMatrixFilter(values);
    }
    
    public function clone() : Dynamic
    {
        var c : SVGColorMatrix = new SVGColorMatrix();
        c.type = type;
        c.values = values.copy();
        return c;
    }

    public function new()
    {
    }
}
