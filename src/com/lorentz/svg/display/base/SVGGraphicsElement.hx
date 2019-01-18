package com.lorentz.svg.display.base;

import haxe.Constraints.Function;
import com.lorentz.svg.data.gradients.SVGGradient;
import com.lorentz.svg.data.gradients.SVGLinearGradient;
import com.lorentz.svg.data.gradients.SVGRadialGradient;
import com.lorentz.svg.display.SVGPattern;
import com.lorentz.svg.drawing.DashedDrawer;
import com.lorentz.svg.events.SVGEvent;
import com.lorentz.svg.parser.SVGParserCommon;
import com.lorentz.svg.utils.SVGColorUtils;
import com.lorentz.svg.utils.SVGUtil;
import com.lorentz.svg.utils.StringUtil;
import flash.display.CapsStyle;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.InterpolationMethod;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class SVGGraphicsElement extends SVGElement {
    private var hasFill(get, never): Bool;
    private var hasStroke(get, never): Bool;
    private var hasDashedStroke(get, never): Bool;

    private var _renderInvalidFlag: Bool = false;

    public function new(tagName: String) {
        super(tagName);
    }

    public function invalidateRender(): Void {
        if (!_renderInvalidFlag) {
            _renderInvalidFlag = true;
            invalidateProperties();
        }
    }

    override private function commitProperties(): Void {
        super.commitProperties();

        if (_renderInvalidFlag) {
            render();
        }
    }

    override private function onStyleChanged(styleName: String, oldValue: String, newValue: String): Void {
        super.onStyleChanged(styleName, oldValue, newValue);

        switch (styleName)
        {
            case "stroke", "stroke-opacity", "stroke-width", "stroke-linecap", "stroke-linejoin", "stroke-dasharray", "stroke-dashoffset", "stroke-dashalign", "fill", "marker", "marker-start", "marker-mid", "marker-end":
                invalidateRender();
        }
    }

    private function render(): Void {
        _renderInvalidFlag = false;
    }

    private function get_hasFill(): Bool {
        var fill: String = finalStyle.getPropertyValue("fill");
        return fill != "" && fill != "none" || isInClipPath();
    }

    private function get_hasStroke(): Bool {
        var stroke: String = finalStyle.getPropertyValue("stroke");
        return stroke != null && stroke != "" && stroke != "none" && !isInClipPath();
    }

    private function get_hasDashedStroke(): Bool {
        var strokeDashArray: String = finalStyle.getPropertyValue("stroke-dasharray");
        return strokeDashArray != null && strokeDashArray != "none";
    }

    private function configureDashedDrawer(dashedDrawer: DashedDrawer): Void {
        if (!hasDashedStroke) {
            return;
        }

        var strokeDashArray: Array<Dynamic> = [];
        for (length/* AS3HX WARNING could not determine type for var: length exp: ECall(EField(EIdent(SVGParserCommon),splitNumericArgs),[ECall(EField(EIdent(finalStyle),getPropertyValue),[EConst(CString(stroke-dasharray))])]) type: null */ in SVGParserCommon.splitNumericArgs(finalStyle.getPropertyValue("stroke-dasharray"))) {
            strokeDashArray.push(getViewPortUserUnit(length, SVGUtil.WIDTH_HEIGHT));
        }

        dashedDrawer.dashArray = strokeDashArray;

        dashedDrawer.dashOffset = 0;
        if (finalStyle.getPropertyValue("stroke-dashoffset") != null) {
            dashedDrawer.dashOffset = finalStyle.getPropertyValue("stroke-dashoffset");
        }

        var strokeDashAlign: String = finalStyle.getPropertyValue("stroke-dashalign");
        if (strokeDashAlign == null) {
            strokeDashAlign = "none";
        }
        var dashAlign: String = Std.string(strokeDashAlign).toLowerCase();
        dashedDrawer.alignToCorners = dashAlign == "corners";
    }

    private function beginFill(g: Graphics = null, callBack: Function = null): Void {
        if (hasFill) {
            var fill: String = finalStyle.getPropertyValue("fill");

            var fillOpacity: Float = 1;
            if (finalStyle.getPropertyValue("fill-opacity") != null) {
                fillOpacity = finalStyle.getPropertyValue("fill-opacity");
            }

            if (fill == null) {
                g.beginFill(0x000000, fillOpacity);
            }
            else if (fill.indexOf("url") > -1) {
                var id: String = SVGUtil.extractUrlId(fill);

                var grad: SVGGradient = try cast(document.getDefinition(id), SVGGradient) catch (e: Dynamic) null;
                if (grad != null) {
                    var _sw0_ = (grad.type);

                    switch (_sw0_)
                    {
                        case GradientType.LINEAR:
                            doLinearGradient(try cast(grad, SVGLinearGradient) catch (e: Dynamic) null, g, true);

                        case GradientType.RADIAL:
                            var rgrad: SVGRadialGradient = try cast(grad, SVGRadialGradient) catch (e: Dynamic) null;
                            if (rgrad.r == "0") {
                                g.beginFill(grad.colors[grad.colors.length - 1], grad.alphas[grad.alphas.length - 1]);
                            }
                            else {
                                doRadialGradient(rgrad, g, true);
                            }
                    }

                    if (callBack != null) {
                        callBack();
                    }

                    return;
                }

                var pattern: SVGPattern = try cast(document.getDefinitionClone(id), SVGPattern) catch (e: Dynamic) null;
                if (pattern != null) {
                    attachElement(pattern);

                    var patternValidated: Event->Void = function(e: Event): Void {
                        //todo: could be a memory leak here
//                        pattern.removeEventListener(SVGEvent.VALIDATED, e.callee);

                        pattern.beginFill(g);

                        detachElement(pattern);
                        if (callBack != null) {
                            callBack();
                        }
                    }
                    pattern.addEventListener(SVGEvent.VALIDATED, patternValidated);
                    pattern.validate();
                    return;
                }
            }
            else {
                var color: Int = SVGColorUtils.parseToUint(fill);
                g.beginFill(color, fillOpacity);
            }
        }

        if (callBack != null) {
            callBack();
        }
    }

    private function lineStyle(g: Graphics): Void {
        if (hasStroke) {
            var strokeOpacity: Float = 1;
            if(finalStyle.getPropertyValue("stroke-opacity") != null) {
                strokeOpacity = finalStyle.getPropertyValue("stroke-opacity");
            }

            var strokeWidth: Float = 1;
            if (finalStyle.getPropertyValue("stroke-width")) {
                strokeWidth = getViewPortUserUnit(finalStyle.getPropertyValue("stroke-width"), SVGUtil.WIDTH_HEIGHT);
            }

            var strokeLineCap: String = CapsStyle.NONE;
            if (finalStyle.getPropertyValue("stroke-linecap")) {
                switch (StringTools.trim(finalStyle.getPropertyValue("stroke-linecap")).toLowerCase())
                {
                    case "round":
                        strokeLineCap = CapsStyle.ROUND;
                    case "square":
                        strokeLineCap = CapsStyle.SQUARE;
                }
            }

            var strokeLineJoin: String = JointStyle.MITER;
            if (finalStyle.getPropertyValue("stroke-linejoin")) {
                switch (StringTools.trim(finalStyle.getPropertyValue("stroke-linejoin")).toLowerCase())
                {
                    case "round":
                        strokeLineJoin = JointStyle.ROUND;
                    case "bevel":
                        strokeLineJoin = JointStyle.BEVEL;
                }
            }

            var strokeMiterlimit: Float = 4;
            if(finalStyle.getPropertyValue("stroke-miterlimit") != null) {
                strokeMiterlimit = finalStyle.getPropertyValue("stroke-miterlimit");
            }

            var stroke: String = finalStyle.getPropertyValue("stroke");

            var color: Int = SVGColorUtils.parseToUint(stroke);
            g.lineStyle(strokeWidth, color, strokeOpacity, true, LineScaleMode.NORMAL, strokeLineCap, strokeLineJoin, strokeMiterlimit);

            if (stroke.indexOf("url") > -1) {
                var id: String = SVGUtil.extractUrlId(stroke);

                var grad: SVGGradient = try cast(document.getDefinition(id), SVGGradient) catch (e: Dynamic) null;

                if (grad != null) {
                    var _sw1_ = (grad.type);

                    switch (_sw1_)
                    {
                        case GradientType.LINEAR:{
                            doLinearGradient(try cast(grad, SVGLinearGradient) catch (e: Dynamic) null, g, false);
                        }
                        case GradientType.RADIAL:{
                            var rgrad: SVGRadialGradient = try cast(grad, SVGRadialGradient) catch (e: Dynamic) null;
                            if (rgrad.r == "0") {
                                g.lineStyle(strokeWidth, grad.colors[grad.colors.length - 1], grad.alphas[grad.alphas.length - 1], true, LineScaleMode.NORMAL, strokeLineCap, strokeLineJoin, strokeMiterlimit);
                            }
                            else {
                                doRadialGradient(rgrad, g, false);
                            }
                        }
                    }
                }
            }
        }
        else {
            g.lineStyle();
        }
    }

    private function getObjectBounds(): Rectangle {
        return new Rectangle();
    }

    private function doLinearGradient(grad: SVGLinearGradient, g: Graphics, fill: Bool = true): Void {
        var x1: Float;
        var y1: Float;
        var x2: Float;
        var y2: Float;

        if (grad.gradientUnits.toLowerCase() == "objectboundingbox") {
            var bounds: Rectangle = getObjectBounds();

            x1 = SVGUtil.getUserUnit(grad.x1, currentFontSize, bounds.width, bounds.height, SVGUtil.WIDTH) + bounds.x;
            y1 = SVGUtil.getUserUnit(grad.y1, currentFontSize, bounds.width, bounds.height, SVGUtil.HEIGHT) + bounds.y;
            x2 = SVGUtil.getUserUnit(grad.x2, currentFontSize, bounds.width, bounds.height, SVGUtil.WIDTH) + bounds.x;
            y2 = SVGUtil.getUserUnit(grad.y2, currentFontSize, bounds.width, bounds.height, SVGUtil.HEIGHT) + bounds.y;
        }
        else {
            x1 = getViewPortUserUnit(grad.x1, SVGUtil.WIDTH);
            y1 = getViewPortUserUnit(grad.y1, SVGUtil.HEIGHT);
            x2 = getViewPortUserUnit(grad.x2, SVGUtil.WIDTH);
            y2 = getViewPortUserUnit(grad.y2, SVGUtil.HEIGHT);
        }

        var mat: Matrix = SVGUtil.flashLinearGradientMatrix(x1, y1, x2, y2);
        if (grad.transform != null) {
            mat.concat(grad.transform);
        }

        if (fill) {
            g.beginGradientFill(grad.type, grad.colors, grad.alphas, grad.ratios, mat, grad.spreadMethod, InterpolationMethod.RGB);
        }
        else {
            g.lineGradientStyle(grad.type, grad.colors, grad.alphas, grad.ratios, mat, grad.spreadMethod, InterpolationMethod.RGB);
        }
    }

    private function doRadialGradient(grad: SVGRadialGradient, g: Graphics, fill: Bool = true): Void {
        var cx: Float = getViewPortUserUnit(grad.cx, SVGUtil.WIDTH);
        var cy: Float = getViewPortUserUnit(grad.cy, SVGUtil.HEIGHT);
        var r: Float = getViewPortUserUnit(grad.r, SVGUtil.WIDTH);
        var fx: Float = getViewPortUserUnit(grad.fx, SVGUtil.WIDTH);
        var fy: Float = getViewPortUserUnit(grad.fy, SVGUtil.HEIGHT);

        var mat: Matrix = SVGUtil.flashRadialGradientMatrix(cx, cy, r, fx, fy);
        if (grad.transform != null) {
            mat.concat(grad.transform);
        }

        var dx: Float = fx - cx;
        var dy: Float = fy - cy;
        var focalRatio: Float = Math.sqrt((dx * dx) + (dy * dy)) / r;

        if (fill) {
            g.beginGradientFill(grad.type, grad.colors, grad.alphas, grad.ratios, mat, grad.spreadMethod, InterpolationMethod.RGB, focalRatio);
        }
        else {
            g.lineGradientStyle(grad.type, grad.colors, grad.alphas, grad.ratios, mat, grad.spreadMethod, InterpolationMethod.RGB, focalRatio);
        }
    }
}
