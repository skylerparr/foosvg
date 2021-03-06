package com.lorentz.svg.utils;

import haxe.Constraints.Function;
import flash.geom.Point;

@:final class MathUtils {
    /**
    Robert Penner's Math intersect2Lines.

    Returns the point of intersection between two lines.

    Parameters:
    p1, p2 - two points on first line
    p3, p4 - two points on second line

    Returns:
    Point of intersection
    */
    public static function intersect2Lines(p1: Point, p2: Point, p3: Point, p4: Point): Point {
        var x1: Float = p1.x;
        var y1: Float = p1.y;
        var x4: Float = p4.x;
        var y4: Float = p4.y;

        var dx1: Float = p2.x - x1;
        var dx2: Float = p3.x - x4;

//        if (dx1 == null && dx2 == null) {
//            return null;
//        } // new Point(NaN, NaN);

        var m1: Float = (p2.y - y1) / dx1;
        var m2: Float = (p3.y - y4) / dx2;

//        if (dx1 == null) {
//
//            return new Point(x1, m2 * (x1 - x4) + y4);
//        }
//        else if (dx2 == null) {
//
//            return new Point(x4, m1 * (x4 - x1) + y1);
//        }
        var xInt: Float = (-m2 * x4 + y4 + m1 * x1 - y1) / (m1 - m2);
        var yInt: Float = m1 * (xInt - x1) + y1;

        return new Point(xInt, yInt);
    }

    /**
    Returns the midpoint of a line segment.

    Parameters:
    a, b - endpoints of line segment (each with .x and .y properties)
    */
    public static function midLine(a: Point, b: Point): Point {
        return Point.interpolate(a, b, 0.5);
    }

    /**
    Robert Penner's Math method bezierSplit.

    Divides a cubic bezier curve into two halves (each also cubic beziers).

    Parameters:
    p0 - first anchor (Point object)
    p1 - first control (Point object)
    p2 - second control (Point object)
    p3 - second anchor (Point object)

    Returns:
    An object with
    b0 - 1st cubic bezier (with properties a,b,c,d corresp to p0,p1,p2,p3)
    b1 - 2nd cubic bezier (same)
    */
    public static function bezierSplit(p0: Point, p1: Point, p2: Point, p3: Point): Dynamic {
        var m: Function = MathUtils.midLine;
        var p01: Point = m(p0, p1);
        var p12: Point = m(p1, p2);
        var p23: Point = m(p2, p3);
        var p02: Point = m(p01, p12);
        var p13: Point = m(p12, p23);
        var p03: Point = m(p02, p13);
        return {
            b0 : {
                a : p0,
                b : p01,
                c : p02,
                d : p03
            },
            b1 : {
                a : p03,
                b : p13,
                c : p23,
                d : p3
            }
        };
    }

    public static function degressToRadius(angle: Float): Float {
        return angle * (Math.PI / 180);
    }

    public static function radiusToDegress(angle: Float): Float {
        return angle * (180 / Math.PI);
    }

    public static function quadCurveSliceUpTo(sx: Float, sy: Float, cx: Float, cy: Float, ex: Float, ey: Float, t: Float): Array<Dynamic> {
        if (Math.isNaN(t)) {
            t = 1;
        }
        if (t != 1) {
            var midx: Float = cx + (ex - cx) * t;
            var midy: Float = cy + (ey - cy) * t;
            cx = sx + (cx - sx) * t;
            cy = sy + (cy - sy) * t;
            ex = cx + (midx - cx) * t;
            ey = cy + (midy - cy) * t;
        }
        return [sx, sy, cx, cy, ex, ey];
    }

    public static function quadCurveSliceFrom(sx: Float, sy: Float, cx: Float, cy: Float, ex: Float, ey: Float, t: Float): Array<Dynamic> {
        if (Math.isNaN(t)) {
            t = 1;
        }
        if (t != 1) {
            var midx: Float = sx + (cx - sx) * t;
            var midy: Float = sy + (cy - sy) * t;
            cx = cx + (ex - cx) * t;
            cy = cy + (ey - cy) * t;
            sx = midx + (cx - midx) * t;
            sy = midy + (cy - midy) * t;
        }
        return [sx, sy, cx, cy, ex, ey];
    }

    public function new() {
    }
}

