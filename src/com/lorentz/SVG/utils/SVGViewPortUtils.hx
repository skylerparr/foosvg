package com.lorentz.sVG.utils;

import flash.geom.Rectangle;

class SVGViewPortUtils
{
    public static function getContentMetrics(viewPortRect : Rectangle, contentBox : Rectangle, contentAlign : String, meetOrSlice : String) : Dynamic
    {
        var scaleX : Float = 1;
        var scaleY : Float = 1;
        
        if (contentAlign == "none")
        {
            scaleX = viewPortRect.width / contentBox.width;
            scaleY = viewPortRect.height / contentBox.height;
        }
        else if (meetOrSlice == "meet")
        {
            scaleX = scaleY = Math.min(viewPortRect.width / contentBox.width, viewPortRect.height / contentBox.height);
        }
        else if (meetOrSlice == "slice")
        {
            scaleX = scaleY = Math.max(viewPortRect.width / contentBox.width, viewPortRect.height / contentBox.height);
        }
        
        var xPart : String = contentAlign.substr(0, 4).toLowerCase();
        var yPart : String = contentAlign.substr(4, 4).toLowerCase();
        
        var x : Float = -contentBox.left * scaleX;
        var y : Float = -contentBox.top * scaleY;
        
        switch (xPart)
        {
            //case "xmin" : x += 0; break;
            case "xmid":x += viewPortRect.width / 2 - contentBox.width * scaleX / 2;
            case "xmax":x += viewPortRect.width - contentBox.width * scaleX;
        }
        
        switch (yPart)
        {
            //case "ymin" : y += 0; break;
            case "ymid":y += viewPortRect.height / 2 - contentBox.height * scaleY / 2;
            case "ymax":y += viewPortRect.height - contentBox.height * scaleY;
        }
        
        return {
            contentScaleX : scaleX,
            contentScaleY : scaleY,
            contentX : x,
            contentY : y
        };
    }

    public function new()
    {
    }
}
