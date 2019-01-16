package com.lorentz.sVG.data.filters;

import com.lorentz.sVG.utils.ICloneable;
import flash.filters.BitmapFilter;

class SVGFilterCollection implements ICloneable
{
    public var svgFilters : Array<ISVGFilter> = new Array<ISVGFilter>();
    
    public function getFlashFilters() : Array<Dynamic>
    {
        var flashFilters : Array<Dynamic> = [];
        for (svgFilter in svgFilters)
        {
            var flashFilter : BitmapFilter = svgFilter.getFlashFilter();
            if (flashFilter != null)
            {
                flashFilters.push(flashFilter);
            }
        }
        return flashFilters;
    }
    
    public function clone() : Dynamic
    {
        var c : SVGFilterCollection = new SVGFilterCollection();
        var i : Int = 0;
        while (i < svgFilters.length)
        {
            c.svgFilters.push(svgFilters[i].clone());
            i++;
        }
        return c;
    }

    public function new()
    {
    }
}
