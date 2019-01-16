package com.lorentz.sVG.data.path;


class SVGCurveToCubicCommand extends SVGPathCommand
{
    public var x1 : Float = 0;
    public var y1 : Float = 0;
    public var x2 : Float = 0;
    public var y2 : Float = 0;
    public var x : Float = 0;
    public var y : Float = 0;
    
    public var absolute : Bool = false;
    
    public function new(absolute : Bool, x1 : Float = 0, y1 : Float = 0, x2 : Float = 0, y2 : Float = 0, x : Float = 0, y : Float = 0)
    {
        super();
        this.absolute = absolute;
        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;
        this.x = x;
        this.y = y;
    }
    
    override private function get_type() : String
    {
        return (absolute) ? "C" : "c";
    }
    
    override public function clone() : Dynamic
    {
        var copy : SVGCurveToCubicCommand = new SVGCurveToCubicCommand(absolute);
        copy.x1 = x1;
        copy.y1 = y1;
        copy.x2 = x2;
        copy.y2 = y2;
        copy.x = x;
        copy.y = y;
        return copy;
    }
}
