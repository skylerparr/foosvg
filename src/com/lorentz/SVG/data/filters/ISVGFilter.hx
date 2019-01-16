package com.lorentz.sVG.data.filters;

import com.lorentz.sVG.utils.ICloneable;
import flash.filters.BitmapFilter;

interface ISVGFilter extends ICloneable
{

    function getFlashFilter() : BitmapFilter
    ;
}
