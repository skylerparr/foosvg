package com.lorentz.sVG.data.path;


class SVGLineToVerticalCommand extends SVGPathCommand
{
    public var y : Float = 0;
    
    public var absolute : Bool = false;
    
    public function new(absolute : Bool, y : Float = 0)
    {
        super();
        this.absolute = absolute;
        this.y = y;
    }
    
    override private function get_type() : String
    {
        return (absolute) ? "V" : "v";
    }
    
    override public function clone() : Dynamic
    {
        var copy : SVGLineToVerticalCommand = new SVGLineToVerticalCommand(absolute);
        copy.y = y;
        return copy;
    }
}
