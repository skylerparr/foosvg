package com.lorentz.svg.parser;

import Xml.XmlType;
import flash.xml.XMLNodeType;
import haxe.xml.Fast;
import com.lorentz.svg.data.filters.ISVGFilter;
import com.lorentz.svg.data.filters.SVGColorMatrix;
import com.lorentz.svg.data.filters.SVGFilterCollection;
import com.lorentz.svg.data.filters.SVGGaussianBlur;
import com.lorentz.svg.data.gradients.SVGGradient;
import com.lorentz.svg.data.gradients.SVGLinearGradient;
import com.lorentz.svg.data.gradients.SVGRadialGradient;
import com.lorentz.svg.data.style.StyleDeclaration;
import com.lorentz.svg.display.SVG;
import com.lorentz.svg.display.SVGA;
import com.lorentz.svg.display.SVGCircle;
import com.lorentz.svg.display.SVGClipPath;
import com.lorentz.svg.display.SVGDocument;
import com.lorentz.svg.display.SVGEllipse;
import com.lorentz.svg.display.SVGG;
import com.lorentz.svg.display.SVGImage;
import com.lorentz.svg.display.SVGLine;
import com.lorentz.svg.display.SVGMarker;
import com.lorentz.svg.display.SVGMask;
import com.lorentz.svg.display.SVGPath;
import com.lorentz.svg.display.SVGPattern;
import com.lorentz.svg.display.SVGPolygon;
import com.lorentz.svg.display.SVGPolyline;
import com.lorentz.svg.display.SVGRect;
import com.lorentz.svg.display.SVGSwitch;
import com.lorentz.svg.display.SVGSymbol;
import com.lorentz.svg.display.SVGTSpan;
import com.lorentz.svg.display.SVGText;
import com.lorentz.svg.display.SVGUse;
import com.lorentz.svg.display.base.ISVGPreserveAspectRatio;
import com.lorentz.svg.display.base.ISVGViewBox;
import com.lorentz.svg.display.base.SVGContainer;
import com.lorentz.svg.display.base.SVGElement;
import com.lorentz.svg.utils.SVGColorUtils;
import com.lorentz.svg.utils.SVGUtil;
import com.lorentz.svg.utils.StringUtil;
import com.lorentz.processing.Process;
import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.events.Event;
import flash.events.EventDispatcher;

@:meta(Event(name = "complete", type = "flash.events.Event"))

class AsyncSVGParser extends EventDispatcher {

    private var _visitQueue: Array<VisitDefinition>;
    private var _svg: FastXML;
    private var _target: SVGDocument;
    private var _process: Process;

    public function new(target: SVGDocument, svg: FastXML) {
        super();
        _target = target;
        _svg = svg;
    }

    public function parse(synchronous: Bool = false): Void {
        parseStyles(_svg);
        parseGradients(_svg);
        parseFilters(_svg);

        _visitQueue = new Array<VisitDefinition>();
        trace("adding svg to visit queue");
        _visitQueue.push(new VisitDefinition(_svg, function(obj: SVGElement): Void {
            trace("adding elelemt : " + obj);
            _target.addElement(obj);
        }));
        trace("queue length " + _visitQueue.length);

        _process = new Process(null, executeLoop, parseComplete);
        if (synchronous) {
            _process.execute();
        }
        else {
            _process.start();
        }
    }

    public function cancel(): Void {
        _process.stop();
        _process = null;
    }

    private function executeLoop(): Int {
//        for (v in _visitQueue) {
//            var x: Xml = v.node.x;
//            if (x.nodeType == XmlType.Document) {
//                x = x.firstElement();
//            }
//        }

        trace("execute loop " + _visitQueue.length);
        var obj = _visitQueue.shift();
        trace(obj);
        Reflect.callMethod(_visitQueue, _visitQueue.unshift, visit(obj));
        return (_visitQueue.length == 0) ? Process.COMPLETE : Process.CONTINUE;
    }

    private function parseComplete(): Void {
        dispatchEvent(new Event(Event.COMPLETE));
        _process = null;
    }

    private function visit(visitDefinition: VisitDefinition): Array<VisitDefinition> {

        var childVisits: Array<VisitDefinition> = [];

        var elt: FastXML = visitDefinition.node;
        var x: Xml = elt.x;
        if (x.nodeType == XmlType.Document) {
            x = x.firstElement();
        }

        var obj: Dynamic = null;

        if (x.nodeType == XmlType.CData) {
            obj = Std.string(elt);
        }
        else if (x.nodeType == XmlType.Element) {
            var localName: String = x.nodeName;
            trace("localName " + localName);
            trace("visitQueue Length " + _visitQueue.length);
            switch (localName)
            {
                case "svg":obj = visitSvg(elt);
                case "defs":visitDefs(elt, childVisits);
                case "rect":obj = visitRect(elt);
                case "path":obj = visitPath(elt);
                case "polygon":obj = visitPolygon(elt);
                case "polyline":obj = visitPolyline(elt);
                case "line":obj = visitLine(elt);
                case "circle":obj = visitCircle(elt);
                case "ellipse":obj = visitEllipse(elt);
                case "g":obj = visitG(elt);
                case "clippath":obj = visitClipPath(elt);
                case "symbol":obj = visitSymbol(elt);
                case "marker":obj = visitMarker(elt);
                case "mask":obj = visitMask(elt);
                case "text":obj = visitText(elt, childVisits);
                case "tspan":obj = visitTspan(elt, childVisits);
                case "image":obj = visitImage(elt);
                case "a":obj = visitA(elt);
                case "use":obj = visitUse(elt);
                case "pattern":obj = visitPattern(elt);
                case "switch":obj = visitSwitch(elt);
            }
        }

        if (Std.is(obj, SVGElement)) {
            var element: SVGElement = try cast(obj, SVGElement) catch (e: Dynamic) null;

            element.id = getAttribute(elt, 'id');

//            element.metadata = elt.nodes.svg::metadata.get(0); //edit: SLP
            element.metadata = elt.descendants("svg:metadata").get(0);

            //Save in definitions
            if (element.id != null && element.id != "") {
                _target.addDefinition(element.id, element);
            }

            SVGUtil.presentationStyleToStyleDeclaration(elt, element.style);
            var style: String = x.get("style");
            if (style != null) {
                element.style.fromString(style);
            }

            var _class: String = x.get("class");
            if (_class != null) {
                element.svgClass = Std.string(_class);
            }

            var transform: String = x.get("transform");
            if (transform != null) {
                element.svgTransform = transform;
            }

            var clipPath: String = x.get("clip-path");
            if (clipPath != null) {
                element.svgClipPath = clipPath;
            }

            var mask: String = x.get("mask");
            if (mask != null) {
                element.svgMask = mask;
            }

            if (Std.is(element, ISVGPreserveAspectRatio)) {
                var preserveAspectRatio: String = x.get("preserveAspectRatio");
                (try cast(element, ISVGPreserveAspectRatio) catch (e: Dynamic) null).svgPreserveAspectRatio = (preserveAspectRatio != null) ? preserveAspectRatio : null;
            }

            if (Std.is(element, ISVGViewBox)) {
                var viewBox: String = x.get("viewBox");
                (try cast(element, ISVGViewBox) catch (e: Dynamic) null).svgViewBox = SVGParserCommon.parseViewBox(viewBox);
            }

            if (Std.is(element, SVGContainer)) {
                var container: SVGContainer = try cast(element, SVGContainer) catch (e: Dynamic) null;
                for (childElt in elt.descendants()) {
                    childVisits.push(new VisitDefinition(childElt, function(child: SVGElement): Void {
                        if (child != null) {
                            container.addElement(child);
                        }
                    }));
                }
            }
        }

        if (visitDefinition.onComplete != null) {
            visitDefinition.onComplete(obj);
        }

        return childVisits;
    }

    private function visitSvg(elt: FastXML): SVG {
        var obj: SVG = new SVG();

        obj.svgX = getAttribute(elt, 'x');
        obj.svgY = getAttribute(elt, 'y');
        obj.svgWidth = getAttribute(elt, 'width', '100%');
        obj.svgHeight = getAttribute(elt, 'height', '100%');

        return obj;
    }

    private function getAttribute(elt: FastXML, att: String, defaultt = null): String {
        var x: Xml = elt.x;
        if (x.nodeType == XmlType.Document) {
            x = x.firstElement();
        }
        var retVal: String = x.get(att);
        if (retVal == null) {
            retVal = defaultt;
        }
        return retVal;
    }

    private function visitDefs(elt: FastXML, childVisits: Array<VisitDefinition>): Void {
        //for each(var childElt:XML in elt.*) { {
        for (childElt in elt.elements) {
            childVisits.push(new VisitDefinition(childElt));
        }
    }

    private function visitRect(elt: FastXML): SVGRect {

        var obj: SVGRect = new SVGRect();

        obj.svgX = getAttribute(elt, 'x');
        obj.svgY = getAttribute(elt, 'y');
        obj.svgWidth = getAttribute(elt, 'width');
        obj.svgHeight = getAttribute(elt, 'height');
        obj.svgRx = getAttribute(elt, 'rx');
        obj.svgRy = getAttribute(elt, 'ry');

        return obj;
    }

    private function visitPath(elt: FastXML): SVGPath {
        var obj: SVGPath = new SVGPath();
        obj.path = SVGParserCommon.parsePathData(getAttribute(elt, "d"));
        return obj;
    }

    private function visitPolygon(elt: FastXML): SVGPolygon {
        var obj: SVGPolygon = new SVGPolygon();
        obj.points = SVGParserCommon.splitNumericArgs(getAttribute(elt, "points"));
        return obj;
    }

    private function visitPolyline(elt: FastXML): SVGPolyline {
        var obj: SVGPolyline = new SVGPolyline();
        obj.points = SVGParserCommon.splitNumericArgs(getAttribute(elt, "points"));
        return obj;
    }

    private function visitLine(elt: FastXML): SVGLine {
        var obj: SVGLine = new SVGLine();

        obj.svgX1 = getAttribute(elt, "x1");
        obj.svgY1 = getAttribute(elt, "y1");

        obj.svgX2 = getAttribute(elt, "x2");
        obj.svgY2 = getAttribute(elt, "y2");

        return obj;
    }

    private function visitCircle(elt: FastXML): SVGCircle {
        var obj: SVGCircle = new SVGCircle();

        obj.svgCx = getAttribute(elt, "cx");
        obj.svgCy = getAttribute(elt, "cy");

        obj.svgR = getAttribute(elt, "r");

        return obj;
    }

    private function visitEllipse(elt: FastXML): SVGEllipse {
        var obj: SVGEllipse = new SVGEllipse();

        obj.svgCx = getAttribute(elt, "cx");
        obj.svgCy = getAttribute(elt, "cy");
        obj.svgRx = getAttribute(elt, "rx");
        obj.svgRy = getAttribute(elt, "ry");

        return obj;
    }

    private function visitG(elt: FastXML): SVGG {
        var obj: SVGG = new SVGG();
        return obj;
    }

    private function visitA(elt: FastXML): SVGA {
        var obj: SVGA = new SVGA();
        var x: Xml = elt.x;

        //var link:String = elt.@xlink::href;
        var link: String = x.get("xlink:href");
        link = StringUtil.ltrim(link, "#");

        obj.svgHref = link;

        return obj;
    }

    private function visitClipPath(elt: FastXML): SVGClipPath {
        var obj: SVGClipPath = new SVGClipPath();
        return obj;
    }

    private function visitSymbol(elt: FastXML): SVGSymbol {
        return new SVGSymbol();
    }

    private function visitMarker(elt: FastXML): SVGMarker {
        var obj: SVGMarker = new SVGMarker();
        obj.svgRefX = getAttribute(elt, "refX");
        obj.svgRefY = getAttribute(elt, "refY");
        obj.svgMarkerWidth = getAttribute(elt, "markerWidth");
        obj.svgMarkerHeight = getAttribute(elt, "markerHeight");
        obj.svgOrient = getAttribute(elt, "orient");

        return obj;
    }

    private function visitMask(elt: FastXML): SVGMask {
        var obj: SVGMask = new SVGMask();
        return obj;
    }

    private function visitText(elt: FastXML, childVisits: Array<VisitDefinition>): SVGText {
        var obj: SVGText = new SVGText();

        obj.svgX = getAttribute(elt, "x", "0");
        obj.svgY = getAttribute(elt, "y", "0");

        var numChildrenToVisit: Int = 0;
        var visitNumber: Int = 0;
        //for each(var childElt:XML in elt.*) {
        for (childElt in elt.descendants()) {

            //todo{

            numChildrenToVisit++;
            childVisits.push(new VisitDefinition(childElt, function(child: Dynamic): Void {
                if (child != null) {
                    if (Std.is(child, String)) {
                        var str: String = Std.string(child);
                        str = SVGUtil.prepareXMLText(str);

                        if (visitNumber == 0) {
                            str = StringUtil.ltrim(str);
                        }
                        else if (visitNumber == numChildrenToVisit - 1) {
                            str = StringUtil.rtrim(str);
                        }

                        if (StringTools.trim(str) != "") {
                            obj.addTextElement(str);
                        }
                    }
                    else {
                        obj.addTextElement(child);
                    }
                }
                visitNumber++;
            }));
        }
        return obj;
    }

    private function visitTspan(elt: FastXML, childVisits: Array<VisitDefinition>): SVGTSpan {
        var obj: SVGTSpan = new SVGTSpan();
        obj.svgX = getAttribute(elt, "x");
        obj.svgY = getAttribute(elt, "y");
        obj.svgDx = getAttribute(elt, "dx", "0");
        obj.svgDy = getAttribute(elt, "dy", "0");

        var numChildrenToVisit: Int = 0;
        var visitNumber: Int = 0;
        //for each(var childElt:XML in elt.*) {
        for (childElt in elt.elements) {

            numChildrenToVisit++;
            childVisits.push(new VisitDefinition(childElt, function(child: Dynamic): Void {
                if (child != null) {
                    if (Std.is(child, String)) {
                        var str: String = Std.string(child);
                        str = SVGUtil.prepareXMLText(str);

                        if (StringTools.trim(str) != "") {
                            obj.addTextElement(str);
                        }
                    }
                    else {
                        obj.addTextElement(child);
                    }
                }
                visitNumber++;
            }));
        }

        return obj;
    }

    private function visitImage(elt: FastXML): SVGImage {
        var obj: SVGImage = new SVGImage();
        obj.svgX = (elt.has.resolve("x")) ? elt.att.x : null;
        obj.svgY = (elt.has.resolve("y")) ? elt.att.y : null;
        obj.svgWidth = (elt.has.resolve("width")) ? elt.att.width : null;
        obj.svgHeight = (elt.has.resolve("height")) ? elt.att.height : null;

        //var href:String = elt.@xlink::href;
        var href: String = elt.att.resolve("xlink:href");
        obj.svgHref = StringTools.trim(href);

        return obj;
    }

    private function visitUse(elt: FastXML): SVGUse {
        var obj: SVGUse = new SVGUse();
        obj.svgX = (elt.has.resolve("x")) ? elt.att.x : null;
        obj.svgY = (elt.has.resolve("y")) ? elt.att.y : null;
        obj.svgWidth = (elt.has.resolve("width")) ? elt.att.width : null;
        obj.svgHeight = (elt.has.resolve("height")) ? elt.att.height : null;

        //var href:String = elt.@xlink::href;
        var href: String = elt.att.resolve("xlink:href");
        obj.svgHref = StringTools.trim(href);

        return obj;
    }

    private function visitPattern(elt: FastXML): SVGPattern {
        var obj: SVGPattern = new SVGPattern();
        obj.svgX = (elt.has.resolve("x")) ? elt.att.x : null;
        obj.svgY = (elt.has.resolve("y")) ? elt.att.y : null;
        obj.svgWidth = (elt.has.resolve("width")) ? elt.att.width : null;
        obj.svgHeight = (elt.has.resolve("height")) ? elt.att.height : null;
        obj.patternTransform = (elt.has.resolve("patternTransform")) ? elt.att.patternTransform : null;
        //var href:String = elt.@xlink::href;
        var href: String = elt.att.resolve("xlink:href");
        obj.svgHref = StringTools.trim(href);
        return obj;
    }

    private function visitSwitch(elt: FastXML): SVGSwitch {
        var obj: SVGSwitch = new SVGSwitch();
        return obj;
    }

    private function parseStyles(elt: FastXML): Void {
        //var stylesTexts:XMLList = (elt..*::style.text()); {

        var stylesTexts: FastXMLList = elt.descendants("svg").descendants("style"); //todo: (elt..*::style.text());

        for (styleString in stylesTexts) {
            var content: String = SVGUtil.prepareXMLText(styleString.toString());

            var parts: Array<Dynamic> = content.split("}");
            for (s in parts) {
                s = StringTools.trim(s);
                if (s.indexOf("{") > -1) {
                    var subparts: Array<Dynamic> = s.split("{");

                    var names: Array<Dynamic> = StringTools.trim(subparts[0]).split(" ");
                    for (n in names) {
                        var style_text: String = StringTools.trim(subparts[1]);
                        _target.addStyleDeclaration(n, StyleDeclaration.createFromString(style_text));
                    }
                }
            }
        }
    }

    private function parseGradients(svg: FastXML): Void {
        //var nodes:XMLList = svg..*::*; {

        var nodes: FastXMLList = svg.descendants("svg").descendants("defs").descendants();
        for (node in nodes) {
            var x: Xml = node.x;
            var nodeName: String = x.nodeName;
            if (node != null && nodeName.toLowerCase() == "lineargradient" || nodeName.toLowerCase() == "radialgradient") {
                parseGradient(x.get('id'), node);
            }
        }
    }

    private function parseGradient(id: String, svg: FastXML): SVGGradient {
        id = StringUtil.ltrim(id, "#");

        if (_target.hasDefinition(id)) {
            return try cast(_target.getDefinition(id), SVGGradient) catch (e: Dynamic) null;
        }

        //var xml_grad:XML = svg..*.(attribute("id")==id)[0];
        var xml_grad: FastXML = svg; //todo: svg..*.(attribute("id")==id)[0];

        if (xml_grad == null) {
            return null;
        }

        var grad: SVGGradient = null;
        var x: Xml = xml_grad.x;

        switch (x.nodeName.toLowerCase())
        {
            case "lineargradient":
                grad = new SVGLinearGradient();
            case "radialgradient":
                grad = new SVGRadialGradient();
        }

        //Inherits the href reference
        //if(xml_grad.@xlink::href.length() > 0){
        if (x.get("xlink:href") != null) {

            //var baseGradient:SVGGradient = parseGradient(xml_grad.@xlink::href, svg);
            var baseGradient: SVGGradient = parseGradient(x.get("xlink:href"), svg);
            if (baseGradient != null) {
                baseGradient.copyTo(grad);
            }
        }

        var gradientUnits: String = x.get("gradientUnits");
        if (gradientUnits != null) {
            grad.gradientUnits = gradientUnits;
        }
        else {
            grad.gradientUnits = "objectBoundingBox";
        }

        var gradientTransform: String = x.get("gradientTransform");
        if (gradientTransform != null) {
            grad.transform = SVGParserCommon.parseTransformation(gradientTransform);
        }

        var _sw0_ = (grad.type);

        switch (_sw0_)
        {
            case GradientType.LINEAR:{
                var linearGrad: SVGLinearGradient = try cast(grad, SVGLinearGradient) catch (e: Dynamic) null;

                var x1: String = x.get("x1");
                if (x1 != null) {
                    linearGrad.x1 = x1;
                }
                else if (linearGrad.x1 == null) {
                    linearGrad.x1 = "0%";
                }

                var y1: String = x.get("y1");
                if (y1 != null) {
                    linearGrad.y1 = y1;
                }
                else if (linearGrad.y1 == null) {
                    linearGrad.y1 = "0%";
                }

                var x2: String = x.get("x2");
                if (x2 != null) {
                    linearGrad.x2 = x2;
                }
                else if (linearGrad.x2 == null) {
                    linearGrad.x2 = "100%";
                }

                var y2: String = x.get("y2");
                if (y2 != null) {
                    linearGrad.y2 = y2;
                }
                else if (linearGrad.y2 == null) {
                    linearGrad.y2 = "0%";
                }
            }
            case GradientType.RADIAL:{
                var radialGrad: SVGRadialGradient = try cast(grad, SVGRadialGradient) catch (e: Dynamic) null;

                var cx: String = x.get("cx");
                if (cx != null) {
                    radialGrad.cx = cx;
                }
                else if (radialGrad.cx == null) {
                    radialGrad.cx = "50%";
                }

                var cy: String = x.get("cy");
                if (cy != null) {
                    radialGrad.cy = cy;
                }
                else if (radialGrad.cy == null) {
                    radialGrad.cy = "50%";
                }

                var r: String = x.get("r");
                if (r != null) {
                    radialGrad.r = r;
                }
                else if (radialGrad.r == null) {
                    radialGrad.r = "50%";
                }

                var fx: String = x.get("fx");
                if (fx != null) {
                    radialGrad.fx = fx;
                }
                else if (radialGrad.fx == null) {
                    radialGrad.fx = radialGrad.cx;
                }

                var fy: String = x.get("fy");
                if (fy != null) {
                    radialGrad.fy = fy;
                }
                else if (radialGrad.fy == null) {
                    radialGrad.fy = radialGrad.cy;
                }
            }
        }

        var _sw1_ = (x.get("spreadMethod"));

        switch (_sw1_)
        {
            case "pad":grad.spreadMethod = SpreadMethod.PAD;
            case "reflect":grad.spreadMethod = SpreadMethod.REFLECT;
            case "repeat":grad.spreadMethod = SpreadMethod.REPEAT;
            default:grad.spreadMethod = SpreadMethod.PAD;
        }

        if (grad.colors == null) {
            grad.colors = new Array<UInt>();
        }

        if (grad.alphas == null) {
            grad.alphas = new Array<Float>();
        }

        if (grad.ratios == null) {
            grad.ratios = new Array<Int>();
        }

        //for each(var stop:XML in xml_grad.*::stop){
        for (stop in svg.descendants("stop")) {
            var x: Xml = stop.x;
            //todo:{

            var stopStyle: StyleDeclaration = new StyleDeclaration();

            var stopOpacity: String = x.get("stop-opacity");
            if (stopOpacity != null) {
                stopStyle.setProperty("stop-opacity", stopOpacity);
            }

            var stopColor: String = x.get("stop-color");
            if (stopColor != null) {
                stopStyle.setProperty("stop-color", stopColor);
            }

            var style: String = x.get("style");
            if (style != null) {
                stopStyle.fromString(style);
            }

            grad.colors.push(SVGColorUtils.parseToUint(stopStyle.getPropertyValue("stop-color")));
            grad.alphas.push((stopStyle.getPropertyValue("stop-opacity") != null) ? as3hx.Compat.parseFloat(stopStyle.getPropertyValue("stop-opacity")) : 1);

            var offset: Float = as3hx.Compat.parseFloat(StringUtil.rtrim(x.get("offset"), "%"));
            if (Std.string(x.get("offset")).indexOf("%") > -1) {
                offset /= 100;
            }
            grad.ratios.push(Std.int(offset * 255));
        }

        //Save the gradient definition
        _target.addDefinition(id, grad);

        return grad;
    }

    private function parseFilters(svg: FastXML): Void {
        //var nodes:XMLList = svg..*::*; {
        //todo:
//        var nodes : FastXMLList = null;  //todo: svg..*::*;
//        for (node in nodes)
//        {
//            if (node != null && (Std.string(node.node.localName.innerData()).toLowerCase() == "filter"))
//            {
//                parseFilterCollection(node);
//            }
//        }
    }

    private function parseFilterCollection(node: FastXML): Void {
        var filterCollection: SVGFilterCollection = new SVGFilterCollection();
        for (childNode in node.elements) {
            var filter: ISVGFilter = parseFilter(childNode);
            if (filter != null) {
                filterCollection.svgFilters.push(filter);
            }
        }

        var id: String = StringUtil.ltrim(node.att.id, "#");
        _target.addDefinition(id, filterCollection);
    }

    private function parseFilter(node: FastXML): ISVGFilter {
        var localName: String = Std.string(node.node.resolve("localName").innerData).toLowerCase();

        switch (localName)
        {
            case "fegaussianblur":return parseFilterGaussianBlur(node);
            case "fecolormatrix":return parseFilterColorMatrix(node);
        }

        return null;
    }

    private function parseFilterGaussianBlur(node: FastXML): SVGGaussianBlur {
        var obj: SVGGaussianBlur = new SVGGaussianBlur();

//        if ((Lambda.has(node, "@stdDeviation")))
        if (node.has.resolve("stdDeviation")) {
            var ereg: EReg = new EReg('[\\s,]+', "");
            var parts: Array<Dynamic> = ereg.split(Std.string(node.att.resolve('stdDeviation')));
            obj.stdDeviationX = as3hx.Compat.parseFloat(parts[0]);
            obj.stdDeviationY = (parts.length > 1) ? as3hx.Compat.parseFloat(parts[1]) : as3hx.Compat.parseFloat(parts[0]);
        }

        return obj;
    }

    private function parseFilterColorMatrix(node: FastXML): SVGColorMatrix {
        var obj: SVGColorMatrix = new SVGColorMatrix();

//        obj.type = ((Lambda.has(node, "@type"))) ? node.att.type : "matrix";
        obj.type = node.has.resolve("type") ? node.att.resolve("type") : "matrix";

        var valuesString: String = ((node.has.resolve("values"))) ? node.att.resolve("values") : "";
        var values: Array<Float> = [];
        for (v in SVGParserCommon.splitNumericArgs(valuesString)) {
            values.push(as3hx.Compat.parseFloat(v));
        }
        obj.values = values;
        return obj;
    }
//    private static var AsyncSVGParser_static_initializer = {
//        protected;
//        namespace;
//        svg = "http://www.w3.org/2000/svg";
//        true;
//    }

}

