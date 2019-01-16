package com.lorentz.sVG.data.gradients;

import flash.display.GradientType;

class SVGRadialGradient extends SVGGradient
{
    public function new()
    {
        super(GradientType.RADIAL);
    }
    
    public var cx : String;
    public var cy : String;
    public var r : String;
    public var fx : String;
    public var fy : String;
    
    override public function copyTo(target : SVGGradient) : Void
    {
        super.copyTo(target);
        
        var targetRadialGradient : SVGRadialGradient = try cast(target, SVGRadialGradient) catch(e:Dynamic) null;
        if (targetRadialGradient != null)
        {
            targetRadialGradient.cx = cx;
            targetRadialGradient.cy = cy;
            targetRadialGradient.r = r;
            targetRadialGradient.fx = fx;
            targetRadialGradient.fy = fy;
        }
    }
}
