package com.lorentz.svg.data.text;

import flash.display.DisplayObject;

class SVGDrawnText
{
    public function new(displayObject : DisplayObject = null, textWidth : Float = 0, startX : Float = 0, startY : Float = 0, baseLineShift : Float = 0)
    {
        this.displayObject = displayObject;
        this.textWidth = textWidth;
        this.startX = startX;
        this.startY = startY;
        this.baseLineShift = baseLineShift;
    }
    
    public var displayObject : DisplayObject;
    public var textWidth : Float = 0;
    public var startX : Float = 0;
    public var startY : Float = 0;
    public var direction : String;
    public var baseLineShift : Float = 0;
}
