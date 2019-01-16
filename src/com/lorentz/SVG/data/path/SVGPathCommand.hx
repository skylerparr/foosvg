package com.lorentz.sVG.data.path;

import com.lorentz.sVG.utils.ICloneable;

class SVGPathCommand implements ICloneable
{
    public var type(get, never) : String;

    public function new()
    {
    }
    
    private function get_type() : String
    {
        return "";
    }
    
    public function clone() : Dynamic
    {
        return null;
    }
}
