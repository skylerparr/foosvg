package com.lorentz.sVG.data.path;


class SVGClosePathCommand extends SVGPathCommand
{
    override private function get_type() : String
    {
        return "z";
    }
    
    override public function clone() : Dynamic
    {
        return new SVGClosePathCommand();
    }

    public function new()
    {
        super();
    }
}
