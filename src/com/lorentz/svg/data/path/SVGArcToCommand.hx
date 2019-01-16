package com.lorentz.svg.data.path;


class SVGArcToCommand extends SVGPathCommand
{
    public var rx : Float = 0;
    public var ry : Float = 0;
    public var xAxisRotation : Float = 0;
    
    public var largeArc : Bool = false;
    public var sweep : Bool = false;
    
    public var x : Float = 0;
    public var y : Float = 0;
    
    public var absolute : Bool = false;
    
    public function new(absolute : Bool = false, rx : Float = 0, ry : Float = 0, xAxisRotation : Float = 0, largeArc : Bool = false, sweep : Bool = false, x : Float = 0, y : Float = 0)
    {
        super();
        this.absolute = absolute;
        this.rx = rx;
        this.ry = ry;
        this.xAxisRotation = xAxisRotation;
        this.largeArc = largeArc;
        this.sweep = sweep;
        this.x = x;
        this.y = y;
    }
    
    override private function get_type() : String
    {
        return (absolute) ? "A" : "a";
    }
    
    override public function clone() : Dynamic
    {
        var copy : SVGArcToCommand = new SVGArcToCommand(absolute);
        copy.rx = rx;
        copy.ry = ry;
        copy.xAxisRotation = xAxisRotation;
        copy.largeArc = largeArc;
        copy.sweep = sweep;
        copy.x = x;
        copy.y = y;
        return copy;
    }
}
