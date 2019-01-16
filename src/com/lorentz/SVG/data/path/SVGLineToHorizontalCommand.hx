package com.lorentz.sVG.data.path;


class SVGLineToHorizontalCommand extends SVGPathCommand
{
    public var x : Float = 0;
    
    public var absolute : Bool = false;
    
    public function new(absolute : Bool, x : Float = 0)
    {
        super();
        this.absolute = absolute;
        this.x = x;
    }
    
    override private function get_type() : String
    {
        return (absolute) ? "H" : "h";
    }
    
    override public function clone() : Dynamic
    {
        var copy : SVGLineToHorizontalCommand = new SVGLineToHorizontalCommand(absolute);
        copy.x = x;
        return copy;
    }
}
