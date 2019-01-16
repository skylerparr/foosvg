package com.lorentz.svg.data.path;

import com.lorentz.svg.utils.ICloneable;

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
