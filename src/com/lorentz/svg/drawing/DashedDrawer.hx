package com.lorentz.svg.drawing;

import com.lorentz.svg.utils.ArcUtils;
import com.lorentz.svg.utils.Bezier;
import com.lorentz.svg.utils.MathUtils;
import flash.geom.Point;

class DashedDrawer implements IDrawer {
    public var penX(get, never): Float;
    public var penY(get, never): Float;
    public var dashArray(get, set): Array<Dynamic>;
    public var dashOffset(get, set): Float;
    public var alignToCorners(get, set): Bool;

    private var _baseDrawer: IDrawer;

    public function new(baseDrawer: IDrawer) {
        _baseDrawer = baseDrawer;
        initDash(_dashOffset);
    }

    private function get_penX(): Float {
        return _baseDrawer.penX;
    }

    private function get_penY(): Float {
        return _baseDrawer.penY;
    }

    private var _dashArray: Array<Dynamic> = [10, 10]; //same as svg's dasharray
    private var _dashOffset: Float = 0; //same as svg's dashoffset

    private var _totalLength: Float = 20; //Total length of dashArray
    private var _alignToCorners: Bool = false;

    private var _curveAccuracy: Float = 6;
    private var isLine: Bool = true;
    private var _dashIndex: Int = 0; //where are we in the _dashArray currently
    private var _dashDrawnLength: Float = 0; //The length of the curent dash

    private var _scaleToAlign: Float = 1;
    private var _isAligned: Bool = false;

    private function get_dashArray(): Array<Dynamic> {
        return _dashArray;
    }

    private function set_dashArray(value: Array<Dynamic>): Array<Dynamic> {
        //check for errors {

        var i: Int = 0;
        while (i < value.length) {
            if (Math.isNaN(value[i] = as3hx.Compat.parseFloat(value[i])) || value[i] < 0) {
                return value;
            }
            i++;
        }

        //if its an odd length, make it even by doubling it
        if ((value.length & 1) != 0) {
            value = value.concat(value);
        }

        _totalLength = 0;
        for (v in value) {
            _totalLength += v;
        }

        _dashArray = value;

        initDash(_dashOffset);
        return value;
    }

    private function get_dashOffset(): Float {
        return _dashOffset;
    }

    private function set_dashOffset(value: Float): Float {
        _dashOffset = value;
        initDash(_dashOffset);
        return value;
    }

    private function get_alignToCorners(): Bool {
        return _alignToCorners;
    }

    private function set_alignToCorners(value: Bool): Bool {
        _alignToCorners = value;
        return value;
    }

    private function initDash(offset: Float): Void {
        var i: Int;

        isLine = true;
        _dashIndex = 0;
        _dashDrawnLength = 0;

        offset = offset % _totalLength;
        if (offset < 0) {
            offset = _totalLength - offset;
        }
        while (offset > 0) {
            var v: Float = Math.min(offset, _dashArray[_dashIndex]);
            offset -= v;
            moveInDashArray(v);
        }
    }

    private function getDashLength(): Float {
        if (_isAligned) {
            return _dashArray[_dashIndex] * _scaleToAlign;
        }
        else {
            return _dashArray[_dashIndex];
        }
    }

    private function moveInDashArray(length: Float): Void {
        _dashDrawnLength += length;

        if (_dashDrawnLength >= getDashLength()) {

            //Dash complete, move to next dash{

            isLine = !isLine;
            _dashIndex++;
            if (_dashIndex > dashArray.length - 1) {
                _dashIndex = 0;
            }
            _dashDrawnLength = 0;
        }
    }

    private function initDashAlign(length: Float): Void {
        var startTrim: Float = _dashArray[0] / 2;
        var endTrim: Float = _dashArray[_dashArray.length - 1] + _dashArray[_dashArray.length - 2] / 2;

        length += startTrim + endTrim;

        var numDashArrayRepeats: Int = Math.round(length / _totalLength);
        var dashesLength: Float = _totalLength * numDashArrayRepeats;

        _scaleToAlign = length / dashesLength;

        initDash(startTrim);

        _isAligned = true;
    }

    private function endDashAlign(): Void {
        _isAligned = false;
        _scaleToAlign = 1;
    }

    public function moveTo(x: Float, y: Float): Void {
        _baseDrawer.moveTo(x, y);
    }

    public function lineTo(x: Float, y: Float): Void {
        if (_alignToCorners && !_isAligned) {
            initDashAlign(lineLength(x - penX, y - penY));
            lineTo(x, y);
            endDashAlign();
            return;
        }

        var lineLength: Float;
        var lengthToDraw: Float;
        do {
            var dx: Float = x - penX;
            var dy: Float = y - penY;

            lineLength = this.lineLength(dx, dy);

            lengthToDraw = Math.min(lineLength, getDashLength() - _dashDrawnLength);

            var newX: Float;
            var newY: Float;

            if (lengthToDraw < lineLength) {

                //Draw part of the line{

                var lineAngle: Float = Math.atan2(dy, dx);
                newX = Math.cos(lineAngle) * lengthToDraw + penX;
                newY = Math.sin(lineAngle) * lengthToDraw + penY;
            }
            else {
                newX = x;
                newY = y;
            }

            if (isLine) {
                _baseDrawer.lineTo(newX, newY);
            }
            else {
                _baseDrawer.moveTo(newX, newY);
            }

            moveInDashArray(lengthToDraw);
        }
        while ((lengthToDraw < lineLength));

        _scaleToAlign = 1;
    }

    public function curveTo(cx: Float, cy: Float, x: Float, y: Float): Void {
        if (_alignToCorners && !_isAligned) {
            initDashAlign(curveLength(penX, penY, cx, cy, x, y, _curveAccuracy));
            curveTo(cx, cy, x, y);
            endDashAlign();
            return;
        }

        var lengthToDraw: Float;
        var curveLength: Float;
        do {
            curveLength = this.curveLength(penX, penY, cx, cy, x, y, _curveAccuracy);

            lengthToDraw = Math.min(curveLength, getDashLength() - _dashDrawnLength);

            var newCX: Float;
            var newCY: Float;
            var newX: Float;
            var newY: Float;

            if (lengthToDraw < curveLength) {

                //Draw part of the curve{

                var splitCurveFactor: Float = lengthToDraw / curveLength;

                var curveToDraw: Array<Dynamic> = MathUtils.quadCurveSliceUpTo(penX, penY, cx, cy, x, y, splitCurveFactor);

                newCX = curveToDraw[2];newCY = curveToDraw[3];
                newX = curveToDraw[4];newY = curveToDraw[5];

                var otherCurve: Array<Dynamic> = MathUtils.quadCurveSliceFrom(penX, penY, cx, cy, x, y, splitCurveFactor);

                //Update variables of the next curve
                cx = otherCurve[2];cy = otherCurve[3];
            }
            else {
                newCX = cx;newCY = cy;
                newX = x;newY = y;
            }

            if (isLine) {
                _baseDrawer.curveTo(newCX, newCY, newX, newY);
            }
            else {
                _baseDrawer.moveTo(newX, newY);
            }

            moveInDashArray(lengthToDraw);
        }
        while (lengthToDraw < curveLength);
    }

    public function cubicCurveTo(cx1: Float, cy1: Float, cx2: Float, cy2: Float, x: Float, y: Float): Void {
        if (_alignToCorners && !_isAligned) {
            initDashAlign(cubicCurveLength(penX, penY, cx1, cy1, cx2, cy2, x, y, _curveAccuracy));
            cubicCurveTo(cx1, cy1, cx2, cy2, x, y);
            endDashAlign();
            return;
        }

        var bezier: Bezier = new Bezier(new Point(penX, penY), new Point(cx1, cy1), new Point(cx2, cy2), new Point(x, y));

        for (quadP in bezier.QPts) {
            curveTo(quadP.c.x, quadP.c.y, quadP.p.x, quadP.p.y);
        }
    }

    public function arcTo(rx: Float, ry: Float, angle: Float, largeArcFlag: Bool, sweepFlag: Bool, x: Float, y: Float): Void {
        if (_alignToCorners && !_isAligned) {
            initDashAlign(arcLength(penX, penY, rx, ry, angle, largeArcFlag, sweepFlag, x, y, _curveAccuracy));
            arcTo(rx, ry, angle, largeArcFlag, sweepFlag, x, y);
            endDashAlign();
            return;
        }

        var ellipticalArc: Dynamic = ArcUtils.computeSvgArc(rx, ry, angle, largeArcFlag, sweepFlag, x, y, penX, penY);

        var curves: Array<Dynamic> = ArcUtils.convertToCurves(ellipticalArc.cx, ellipticalArc.cy, ellipticalArc.startAngle, ellipticalArc.arc, ellipticalArc.radius, ellipticalArc.yRadius, ellipticalArc.xAxisRotation);

        var i: Int = 0;
        while (i < curves.length) {
            curveTo(curves[i].c.x, curves[i].c.y, curves[i].p.x, curves[i].p.y);
            i++;
        }
    }

    private function lineLength(sx: Float, sy: Float, ex: Float = null, ey: Float = null): Float {
        if (ex == null && ey == null) {
            return Math.sqrt(sx * sx + sy * sy);
        }
        var dx: Float = ex - sx;
        var dy: Float = ey - sy;
        return Math.sqrt(dx * dx + dy * dy);
    }

    private function curveLength(sx: Float, sy: Float, cx: Float, cy: Float, ex: Float, ey: Float, accuracy: Float): Float {
        var total: Float = 0;
        var tx: Float = sx;
        var ty: Float = sy;
        var px: Float;
        var py: Float;
        var t: Float;
        var it: Float;
        var a: Float;
        var b: Float;
        var c: Float;
        var n: Float = (accuracy != 0 && !Math.isNaN(accuracy)) ? accuracy : _curveAccuracy;
        for (i in 1...Std.int(n) + 1) {
            t = i / n;
            it = 1 - t;
            a = it * it;
            b = 2 * t * it;c = t * t;
            px = a * sx + b * cx + c * ex;
            py = a * sy + b * cy + c * ey;
            total += lineLength(tx, ty, px, py);
            tx = px;
            ty = py;
        }
        return total;
    }

    private function cubicCurveLength(sx: Float, sy: Float, cx1: Float, cy1: Float, cx2: Float, cy2: Float, x: Float, y: Float, accuracy: Float): Float {
        var bezier: Bezier = new Bezier(new Point(sx, sy), new Point(cx1, cy1), new Point(cx2, cy2), new Point(x, y));

        var length: Float = 0;
        var curX: Float = sx;
        var curY: Float = sy;

        for (quadP/* AS3HX WARNING could not determine type for var: quadP exp: EField(EIdent(bezier),QPts) type: null */ in bezier.QPts) {
            length += curveLength(curX, curY, quadP.c.x, quadP.c.y, quadP.p.x, quadP.p.y, accuracy);
            curX = quadP.p.x;curY = quadP.p.y;
        }

        return length;
    }

    private function arcLength(sx: Float, sy: Float, rx: Float, ry: Float, angle: Float, largeArcFlag: Bool, sweepFlag: Bool, x: Float, y: Float, accuracy: Float): Float {
        var ellipticalArc: Dynamic = ArcUtils.computeSvgArc(rx, ry, angle, largeArcFlag, sweepFlag, x, y, sx, sy);

        var curves: Array<Dynamic> = ArcUtils.convertToCurves(ellipticalArc.cx, ellipticalArc.cy, ellipticalArc.startAngle, ellipticalArc.arc, ellipticalArc.radius, ellipticalArc.yRadius, ellipticalArc.xAxisRotation);

        var length: Float = 0;
        var curX: Float = sx;
        var curY: Float = sy;

        var i: Int = 0;
        while (i < curves.length) {
            length += curveLength(curX, curY, curves[i].c.x, curves[i].c.y, curves[i].p.x, curves[i].p.y, accuracy);
            curX = curves[i].p.x;curY = curves[i].p.y;
            i++;
        }

        return length;
    }
}
