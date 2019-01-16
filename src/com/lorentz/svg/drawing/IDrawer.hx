package com.lorentz.svg.drawing;


interface IDrawer
{
    
    var penX(get, never) : Float;    
    var penY(get, never) : Float;

    
    function moveTo(x : Float, y : Float) : Void
    ;
    
    function lineTo(x : Float, y : Float) : Void
    ;
    
    function curveTo(cx : Float, cy : Float, x : Float, y : Float) : Void
    ;
    
    function cubicCurveTo(cx1 : Float, cy1 : Float, cx2 : Float, cy2 : Float, x : Float, y : Float) : Void
    ;
    
    function arcTo(rx : Float, ry : Float, angle : Float, largeArcFlag : Bool, sweepFlag : Bool, x : Float, y : Float) : Void
    ;
}
