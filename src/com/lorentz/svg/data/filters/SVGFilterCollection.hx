package com.lorentz.svg.data.filters;

import com.lorentz.svg.utils.ICloneable;
import flash.filters.BitmapFilter;

class SVGFilterCollection implements ICloneable
{
    public var svgFilters : Array<ISVGFilter> = new Array<ISVGFilter>();
    
    public function getFlashFilters() : Array<BitmapFilter>
    {
        var flashFilters : Array<BitmapFilter> = [];
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
    
    public function clone() : SVGFilterCollection
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
