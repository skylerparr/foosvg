package com.lorentz.sVG.data.path;


class SVGCurveToCubicSmoothCommand extends SVGPathCommand
{
    public var x2 : Float = 0;
    public var y2 : Float = 0;
    public var x : Float = 0;
    public var y : Float = 0;
    
    public var absolute : Bool = false;
    
    public function new(absolute : Bool, x2 : Float = 0, y2 : Float = 0, x : Float = 0, y : Float = 0)
    {
        super();
        this.absolute = absolute;
        this.x2 = x2;
        this.y2 = y2;
        this.x = x;
        this.y = y;
    }
    
    override private function get_type() : String
    {
        return (absolute) ? "S" : "s";
    }
    
    override public function clone() : Dynamic
    {
        var copy : SVGCurveToCubicSmoothCommand = new SVGCurveToCubicSmoothCommand(absolute);
        copy.x2 = x2;
        copy.y2 = y2;
        copy.x = x;
        copy.y = y;
        return copy;
    }
}
