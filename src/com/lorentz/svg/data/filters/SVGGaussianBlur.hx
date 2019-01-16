package com.lorentz.svg.data.filters;

import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BlurFilter;

class SVGGaussianBlur implements ISVGFilter
{
    public var stdDeviationX : Float = 0;
    public var stdDeviationY : Float = 0;
    
    public function getFlashFilter() : BitmapFilter
    {
        return new BlurFilter(stdDeviationX * 2, stdDeviationY * 2, BitmapFilterQuality.HIGH);
    }
    
    public function clone() : Dynamic
    {
        var c : SVGGaussianBlur = new SVGGaussianBlur();
        c.stdDeviationX = stdDeviationX;
        c.stdDeviationY = stdDeviationY;
        return c;
    }

    public function new()
    {
    }
}
