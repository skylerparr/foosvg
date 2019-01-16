package com.lorentz.svg.utils;

import flash.geom.Point;

class ArcUtils
{
    /** 
		 * Function from degrafa
		 * com.degrafa.geometry.utilities.ArcUtils
		 **/
    public static function computeSvgArc(rx : Float, ry : Float, angle : Float, largeArcFlag : Bool, sweepFlag : Bool,
            x : Float, y : Float, LastPointX : Float, LastPointY : Float) : Dynamic
    //store before we do anything with it
    {
        
        var xAxisRotation : Float = angle;
        
        // Compute the half distance between the current and the final point
        var dx2 : Float = (LastPointX - x) / 2.0;
        var dy2 : Float = (LastPointY - y) / 2.0;
        
        // Convert angle from degrees to radians
        angle = MathUtils.degressToRadius(angle);
        var cosAngle : Float = Math.cos(angle);
        var sinAngle : Float = Math.sin(angle);
        
        //Compute (x1, y1)
        var x1 : Float = (cosAngle * dx2 + sinAngle * dy2);
        var y1 : Float = (-sinAngle * dx2 + cosAngle * dy2);
        
        // Ensure radii are large enough
        rx = Math.abs(rx);
        ry = Math.abs(ry);
        var Prx : Float = rx * rx;
        var Pry : Float = ry * ry;
        var Px1 : Float = x1 * x1;
        var Py1 : Float = y1 * y1;
        
        // check that radii are large enough
        var radiiCheck : Float = Px1 / Prx + Py1 / Pry;
        if (radiiCheck > 1)
        {
            rx = Math.sqrt(radiiCheck) * rx;
            ry = Math.sqrt(radiiCheck) * ry;
            Prx = rx * rx;
            Pry = ry * ry;
        }
        
        
        //Compute (cx1, cy1)
        var sign : Float = ((largeArcFlag == sweepFlag)) ? -1 : 1;
        var sq : Float = ((Prx * Pry) - (Prx * Py1) - (Pry * Px1)) / ((Prx * Py1) + (Pry * Px1));
        sq = ((sq < 0)) ? 0 : sq;
        var coef : Float = (sign * Math.sqrt(sq));
        var cx1 : Float = coef * ((rx * y1) / ry);
        var cy1 : Float = coef * -((ry * x1) / rx);
        
        
        //Compute (cx, cy) from (cx1, cy1)
        var sx2 : Float = (LastPointX + x) / 2.0;
        var sy2 : Float = (LastPointY + y) / 2.0;
        var cx : Float = sx2 + (cosAngle * cx1 - sinAngle * cy1);
        var cy : Float = sy2 + (sinAngle * cx1 + cosAngle * cy1);
        
        
        //Compute the angleStart (angle1) and the angleExtent (dangle)
        var ux : Float = (x1 - cx1) / rx;
        var uy : Float = (y1 - cy1) / ry;
        var vx : Float = (-x1 - cx1) / rx;
        var vy : Float = (-y1 - cy1) / ry;
        var p : Float;
        var n : Float;  //Compute the angle start  ;
        
        
        
        n = Math.sqrt((ux * ux) + (uy * uy));
        p = ux;
        
        sign = ((uy < 0)) ? -1.0 : 1.0;
        
        var angleStart : Float = MathUtils.radiusToDegress(sign * Math.acos(p / n));
        
        // Compute the angle extent
        n = Math.sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy));
        p = ux * vx + uy * vy;
        sign = ((ux * vy - uy * vx < 0)) ? -1.0 : 1.0;
        var angleExtent : Float = MathUtils.radiusToDegress(sign * Math.acos(p / n));
        
        if (!sweepFlag && angleExtent > 0)
        {
            angleExtent -= 360;
        }
        else if (sweepFlag && angleExtent < 0)
        {
            angleExtent += 360;
        }
        
        angleExtent %= 360;
        angleStart %= 360;
        
        return cast(({
                    x : LastPointX,
                    y : LastPointY,
                    startAngle : angleStart,
                    arc : angleExtent,
                    radius : rx,
                    yRadius : ry,
                    xAxisRotation : xAxisRotation,
                    cx : cx,
                    cy : cy
                }), Object);
    }
    
    public static function convertToCurves(x : Float, y : Float, startAngle : Float, arcAngle : Float, xRadius : Float, yRadius : Float, xAxisRotation : Float = 0) : Array<Dynamic>
    {
        var curves : Array<Dynamic> = [];
        
        // Circumvent drawing more than is needed
        if (Math.abs(arcAngle) > 360)
        {
            arcAngle = 360;
        }
        
        // Draw in a maximum of 45 degree segments. First we calculate how many
        // segments are needed for our arc.
        var segs : Float = Math.ceil(Math.abs(arcAngle) / 45);
        
        // Now calculate the sweep of each segment
        var segAngle : Float = arcAngle / segs;
        
        var theta : Float = MathUtils.degressToRadius(segAngle);
        var angle : Float = MathUtils.degressToRadius(startAngle);
        
        // Draw as 45 degree segments
        if (segs > 0)
        {
            var beta : Float = MathUtils.degressToRadius(xAxisRotation);
            var sinbeta : Float = Math.sin(beta);
            var cosbeta : Float = Math.cos(beta);
            
            var cx : Float;
            var cy : Float;
            var x1 : Float;
            var y1 : Float;
            
            // Loop for drawing arc segments
            for (i in 0...segs)
            {
                angle += theta;
                
                var sinangle : Float = Math.sin(angle - (theta / 2));
                var cosangle : Float = Math.cos(angle - (theta / 2));
                
                var div : Float = Math.cos(theta / 2);
                cx = x + (xRadius * cosangle * cosbeta - yRadius * sinangle * sinbeta) / div;  //Why divide by Math.cos(theta/2)?  
                cy = y + (xRadius * cosangle * sinbeta + yRadius * sinangle * cosbeta) / div;  //Why divide by Math.cos(theta/2)?  
                
                sinangle = Math.sin(angle);
                cosangle = Math.cos(angle);
                
                x1 = x + (xRadius * cosangle * cosbeta - yRadius * sinangle * sinbeta);
                y1 = y + (xRadius * cosangle * sinbeta + yRadius * sinangle * cosbeta);
                
                curves.push({
                            s : new Point(x, y),
                            c : new Point(cx, cy),
                            p : new Point(x1, y1)
                        });
            }
        }
        
        return curves;
    }

    public function new()
    {
    }
}
