package com.lorentz.svg.utils;

import com.lorentz.svg.display.base.SVGElement;
import flash.display.DisplayObject;
import flash.geom.Rectangle;

class DisplayUtils
{
    public static function safeGetBounds(target : DisplayObject, targetCoordinateSpace : DisplayObject) : Rectangle
    {
        if (target.width == 0 || target.height == 0)
        {
            return new Rectangle();
        }
        
        return target.getBounds(targetCoordinateSpace);
    }
    
    public static function getSVGElement(object : DisplayObject) : SVGElement
    {
        while (object != null && !(Std.is(object, SVGElement)))
        {
            object = object.parent;
        }
        
        return try cast(object, SVGElement) catch(e:Dynamic) null;
    }

    public function new()
    {
    }
}
