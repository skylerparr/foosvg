package com.lorentz.svg.data.filters;

import com.lorentz.svg.utils.ICloneable;
import flash.filters.BitmapFilter;

interface ISVGFilter extends ICloneable
{

    function getFlashFilter() : BitmapFilter
    ;
}
