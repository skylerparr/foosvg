package com.lorentz.sVG.display.base;


interface ISVGViewPort extends ISVGPreserveAspectRatio
{
    
    
    var svgX(get, set) : String;    
    
    
    var svgY(get, set) : String;    
    
    
    var svgWidth(get, set) : String;    
    
    
    var svgHeight(get, set) : String;    
    
    
    var svgOverflow(get, set) : String;    
    
    var viewPortWidth(get, never) : Float;    
    var viewPortHeight(get, never) : Float;

}
