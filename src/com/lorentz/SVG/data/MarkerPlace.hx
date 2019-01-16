package com.lorentz.sVG.data;

import flash.geom.Point;

class MarkerPlace
{
    public var position : Point;
    public var angle : Float;
    public var type : String;
    public var strokeWidth : Float;
    
    public function new(position : Point, angle : Float, type : String, strokeWidth : Float = 0)
    {
        this.position = position;
        this.angle = angle;
        this.type = type;
        this.strokeWidth = strokeWidth;
    }
    
    public function averageAngle(otherAngle : Float) : Void
    {
        angle = (angle + otherAngle) * 0.5;
    }
}
