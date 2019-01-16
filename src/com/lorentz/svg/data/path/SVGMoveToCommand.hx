package com.lorentz.svg.data.path;


class SVGMoveToCommand extends SVGPathCommand
{
    public var x : Float = 0;
    public var y : Float = 0;
    
    public var absolute : Bool = false;
    
    public function new(absolute : Bool, x : Float = 0, y : Float = 0)
    {
        super();
        this.absolute = absolute;
        this.x = x;
        this.y = y;
    }
    
    override private function get_type() : String
    {
        return (absolute) ? "M" : "m";
    }
    
    override public function clone() : Dynamic
    {
        var copy : SVGMoveToCommand = new SVGMoveToCommand(absolute);
        copy.x = x;
        copy.y = y;
        return copy;
    }
}
