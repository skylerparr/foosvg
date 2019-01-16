package com.lorentz.svg.parser;

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

@:meta(Event(name="complete",type="flash.events.Event"))

class AsyncSVGParser extends EventDispatcher
{
    
    
    private var _visitQueue : Array<VisitDefinition>;
    private var _svg : FastXML;
    private var _target : SVGDocument;
    private var _process : Process;
    
    public function new(target : SVGDocument, svg : FastXML)
    {
        super();
        _target = target;
        _svg = svg;
    }
    
    public function parse(synchronous : Bool = false) : Void
    {
        parseStyles(_svg);
        parseGradients(_svg);
        parseFilters(_svg);
        
        _visitQueue = new Array<VisitDefinition>();
        _visitQueue.push(new VisitDefinition(_svg, function(obj : SVGElement) : Void
                {
                    _target.addElement(obj);
                }));
        
        _process = new Process(null, executeLoop, parseComplete);
        if (synchronous)
        {
            _process.execute();
        }
        else
        {
            _process.start();
        }
    }
    
    public function cancel() : Void
    {
        _process.stop();
        _process = null;
    }
    
    private function executeLoop() : Int
    {
        _visitQueue.unshift.apply(this, visit(_visitQueue.shift()));
        return (_visitQueue.length == 0) ? Process.COMPLETE : Process.CONTINUE;
    }
    
    private function parseComplete() : Void
    {
        dispatchEvent(new Event(Event.COMPLETE));
        _process = null;
    }
    
    private function visit(visitDefinition : VisitDefinition) : Array<Dynamic>
    {
        var childVisits : Array<Dynamic> = [];
        
        var elt : Fast = visitDefinition.node;
        
        var obj : Dynamic;
        
        if (elt.node.nodeKind.innerData() == "text")
        {
            obj = Std.string(elt);
        }
        else if (elt.node.nodeKind.innerData() == "element")
        {
            var localName : String = Std.string(elt.node.localName.innerData()).toLowerCase();
            
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
        
        if (Std.is(obj, SVGElement))
        {
            var element : SVGElement = try cast(obj, SVGElement) catch(e:Dynamic) null;
            
            element.id = elt.att.id;
            
//            element.metadata = elt.nodes.svg::metadata.get(0); //edit: SLP
            element.metadata = elt.nodes.svg.nodes.metadata[0];

            //Save in definitions
            if (element.id != null && element.id != "")
            {
                _target.addDefinition(element.id, element);
            }
            
            SVGUtil.presentationStyleToStyleDeclaration(elt, element.style);
            if (Lambda.has(elt, "@style"))
            {
                element.style.fromString(elt.att.style);
            }
            
            if (Lambda.has(elt, "@class"))
            {
                element.svgClass = Std.string(elt.get("@class"));
            }
            
            if (Lambda.has(elt, "@transform"))
            {
                element.svgTransform = Std.string(elt.att.transform);
            }
            
            if (Lambda.has(elt, "@clip-path"))
            {
                element.svgClipPath = Std.string(elt.get("@clip-path"));
            }
            
            if (Lambda.has(elt, "@mask"))
            {
                element.svgMask = Std.string(elt.att.mask);
            }
            
            if (Std.is(element, ISVGPreserveAspectRatio))
            {
                (try cast(element, ISVGPreserveAspectRatio) catch(e:Dynamic) null).svgPreserveAspectRatio = ((Lambda.has(elt, "@preserveAspectRatio"))) ? elt.att.preserveAspectRatio : null;
            }
            
            if (Std.is(element, ISVGViewBox))
            {
                (try cast(element, ISVGViewBox) catch(e:Dynamic) null).svgViewBox = SVGParserCommon.parseViewBox(elt.att.viewBox);
            }
            
            if (Std.is(element, SVGContainer))
            {
                var container : SVGContainer = try cast(element, SVGContainer) catch(e:Dynamic) null;
                
                for (childElt/* AS3HX WARNING could not determine type for var: childElt exp: ECall(EField(EIdent(elt),elements),[]) type: null */ in elt.nodes.elements())
                {
                    childVisits.push(new VisitDefinition(childElt, function(child : SVGElement) : Void
                            {
                                if (child != null)
                                {
                                    container.addElement(child);
                                }
                            }));
                }
            }
        }
        
        if (visitDefinition.onComplete != null)
        {
            visitDefinition.onComplete(obj);
        }
        
        return childVisits;
    }
    
    private function visitSvg(elt : FastXML) : SVG
    {
        var obj : SVG = new SVG();
        
        obj.svgX = ((Lambda.has(elt, "@x"))) ? elt.att.x : null;
        obj.svgY = ((Lambda.has(elt, "@y"))) ? elt.att.y : null;
        obj.svgWidth = ((Lambda.has(elt, "@width"))) ? elt.att.width : "100%";
        obj.svgHeight = ((Lambda.has(elt, "@height"))) ? elt.att.height : "100%";
        
        return obj;
    }
    
    private function visitDefs(elt : FastXML, childVisits : Array<Dynamic>) : Void
    //for each(var childElt:XML in elt.*) {
    {

        for (childElt in []) {

            childVisits.push(new VisitDefinition(childElt));
        }
    }

    private function visitRect(elt : FastXML) : SVGRect
    {
        var obj : SVGRect = new SVGRect();

        obj.svgX = elt.att.x;
        obj.svgY = elt.att.y;
        obj.svgWidth = elt.att.width;
        obj.svgHeight = elt.att.height;
        obj.svgRx = elt.att.rx;
        obj.svgRy = elt.att.ry;

        return obj;
    }

    private function visitPath(elt : FastXML) : SVGPath
    {
        var obj : SVGPath = new SVGPath();
        obj.path = SVGParserCommon.parsePathData(elt.att.d);
        return obj;
    }

    private function visitPolygon(elt : FastXML) : SVGPolygon
    {
        var obj : SVGPolygon = new SVGPolygon();
        obj.points = SVGParserCommon.splitNumericArgs(elt.att.points);
        return obj;
    }
    private function visitPolyline(elt : FastXML) : SVGPolyline
    {
        var obj : SVGPolyline = new SVGPolyline();
        obj.points = SVGParserCommon.splitNumericArgs(elt.att.points);
        return obj;
    }
    private function visitLine(elt : FastXML) : SVGLine
    {
        var obj : SVGLine = new SVGLine();

        obj.svgX1 = elt.att.x1;
        obj.svgY1 = elt.att.y1;

        obj.svgX2 = elt.att.x2;
        obj.svgY2 = elt.att.y2;

        return obj;
    }
    private function visitCircle(elt : FastXML) : SVGCircle
    {
        var obj : SVGCircle = new SVGCircle();

        obj.svgCx = elt.att.cx;
        obj.svgCy = elt.att.cy;

        obj.svgR = elt.att.r;

        return obj;
    }
    private function visitEllipse(elt : FastXML) : SVGEllipse
    {
        var obj : SVGEllipse = new SVGEllipse();

        obj.svgCx = elt.att.cx;
        obj.svgCy = elt.att.cy;
        obj.svgRx = elt.att.rx;
        obj.svgRy = elt.att.ry;

        return obj;
    }
    private function visitG(elt : FastXML) : SVGG
    {
        var obj : SVGG = new SVGG();
        return obj;
    }

    private function visitA(elt : FastXML) : SVGA
    {
        var obj : SVGA = new SVGA();

        var xlink : Namespace = new Namespace("http://www.w3.org/1999/xlink");
        //var link:String = elt.@xlink::href;
        var link : String = null;  //todo
        link = StringUtil.ltrim(link, "#");

        obj.svgHref = link;

        return obj;
    }

    private function visitClipPath(elt : FastXML) : SVGClipPath
    {
        var obj : SVGClipPath = new SVGClipPath();
        return obj;
    }

    private function visitSymbol(elt : FastXML) : SVGSymbol
    {
        return new SVGSymbol();
    }

    private function visitMarker(elt : FastXML) : SVGMarker
    {
        var obj : SVGMarker = new SVGMarker();
        obj.svgRefX = elt.att.refX;
        obj.svgRefY = elt.att.refY;
        obj.svgMarkerWidth = elt.att.markerWidth;
        obj.svgMarkerHeight = elt.att.markerHeight;
        obj.svgOrient = elt.att.orient;

        return obj;
    }

    private function visitMask(elt : FastXML) : SVGMask
    {
        var obj : SVGMask = new SVGMask();
        return obj;
    }

    private function visitText(elt : FastXML, childVisits : Array<Dynamic>) : SVGText
    {
        var obj : SVGText = new SVGText();

        obj.svgX = ((Lambda.has(elt, "@x"))) ? elt.att.x : "0";
        obj.svgY = ((Lambda.has(elt, "@y"))) ? elt.att.y : "0";

        var numChildrenToVisit : Int = 0;
        var visitNumber : Int = 0;
        //for each(var childElt:XML in elt.*) {
        for (childElt in []) {

        //todo{

            numChildrenToVisit++;
            childVisits.push(new VisitDefinition(childElt, function(child : Dynamic) : Void
                    {
                        if (child != null)
                        {
                            if (Std.is(child, String))
                            {
                                var str : String = Std.string(child);
                                str = SVGUtil.prepareXMLText(str);

                                if (visitNumber == 0)
                                {
                                    str = StringUtil.ltrim(str);
                                }
                                else if (visitNumber == numChildrenToVisit - 1)
                                {
                                    str = StringUtil.rtrim(str);
                                }

                                if (StringTools.trim(str) != "")
                                {
                                    obj.addTextElement(str);
                                }
                            }
                            else
                            {
                                obj.addTextElement(child);
                            }
                        }
                        visitNumber++;
                    }));
        }
        return obj;
    }

    private function visitTspan(elt : FastXML, childVisits : Array<Dynamic>) : SVGTSpan
    {
        var obj : SVGTSpan = new SVGTSpan();
        obj.svgX = ((Lambda.has(elt, "@x"))) ? elt.att.x : null;
        obj.svgY = ((Lambda.has(elt, "@y"))) ? elt.att.y : null;
        obj.svgDx = ((Lambda.has(elt, "@dx"))) ? elt.att.dx : "0";
        obj.svgDy = ((Lambda.has(elt, "@dy"))) ? elt.att.dy : "0";

        var numChildrenToVisit : Int = 0;
        var visitNumber : Int = 0;
        //for each(var childElt:XML in elt.*) {
        for (childElt in []) {

        //todo{

            numChildrenToVisit++;
            childVisits.push(new VisitDefinition(childElt, function(child : Dynamic) : Void
                    {
                        if (child != null)
                        {
                            if (Std.is(child, String))
                            {
                                var str : String = Std.string(child);
                                str = SVGUtil.prepareXMLText(str);

                                if (StringTools.trim(str) != "")
                                {
                                    obj.addTextElement(str);
                                }
                            }
                            else
                            {
                                obj.addTextElement(child);
                            }
                        }
                        visitNumber++;
                    }));
        }

        return obj;
    }

    private function visitImage(elt : FastXML) : SVGImage
    {
        var obj : SVGImage = new SVGImage();
        obj.svgX = ((Lambda.has(elt, "@x"))) ? elt.att.x : null;
        obj.svgY = ((Lambda.has(elt, "@y"))) ? elt.att.y : null;
        obj.svgWidth = ((Lambda.has(elt, "@width"))) ? elt.att.width : null;
        obj.svgHeight = ((Lambda.has(elt, "@height"))) ? elt.att.height : null;

        var xlink : Namespace = new Namespace("http://www.w3.org/1999/xlink");
        //var href:String = elt.@xlink::href;
        var href : String = null;  //elt.@xlink::href; todo
        obj.svgHref = StringTools.trim(href);

        return obj;
    }

    private function visitUse(elt : FastXML) : SVGUse
    {
        var obj : SVGUse = new SVGUse();
        obj.svgX = ((Lambda.has(elt, "@x"))) ? elt.att.x : null;
        obj.svgY = ((Lambda.has(elt, "@y"))) ? elt.att.y : null;
        obj.svgWidth = ((Lambda.has(elt, "@width"))) ? elt.att.width : null;
        obj.svgHeight = ((Lambda.has(elt, "@height"))) ? elt.att.height : null;

        var xlink : Namespace = new Namespace("http://www.w3.org/1999/xlink");
        //var href:String = elt.@xlink::href;
        var href : String = null;  //todo: elt.@xlink::href;
        obj.svgHref = StringTools.trim(href);

        return obj;
    }

    private function visitPattern(elt : FastXML) : SVGPattern
    {
        var obj : SVGPattern = new SVGPattern();
        obj.svgX = ((Lambda.has(elt, "@x"))) ? elt.att.x : null;
        obj.svgY = ((Lambda.has(elt, "@y"))) ? elt.att.y : null;
        obj.svgWidth = ((Lambda.has(elt, "@width"))) ? elt.att.width : null;
        obj.svgHeight = ((Lambda.has(elt, "@height"))) ? elt.att.height : null;
        obj.patternTransform = ((Lambda.has(elt, "@patternTransform"))) ? elt.att.patternTransform : null;
        var xlink : Namespace = new Namespace("http://www.w3.org/1999/xlink");
        //var href:String = elt.@xlink::href;
        var href : String = null;  //todo: elt.@xlink::href;
        obj.svgHref = StringTools.trim(href);
        return obj;
    }

    private function visitSwitch(elt : FastXML) : SVGSwitch
    {
        var obj : SVGSwitch = new SVGSwitch();
        return obj;
    }

    private function parseStyles(elt : FastXML) : Void
    //var stylesTexts:XMLList = (elt..*::style.text());
    {

        var stylesTexts : FastXMLList = null;  //todo: (elt..*::style.text());

        for (styleString in stylesTexts)
        {
            var content : String = SVGUtil.prepareXMLText(styleString);

            var parts : Array<Dynamic> = content.split("}");
            for (s in parts)
            {
                s = StringTools.trim(s);
                if (s.indexOf("{") > -1)
                {
                    var subparts : Array<Dynamic> = s.split("{");

                    var names : Array<Dynamic> = StringTools.trim(subparts[0]).split(" ");
                    for (n in names)
                    {
                        var style_text : String = StringTools.trim(subparts[1]);
                        _target.addStyleDeclaration(n, StyleDeclaration.createFromString(style_text));
                    }
                }
            }
        }
    }

    private function parseGradients(svg : FastXML) : Void
    //var nodes:XMLList = svg..*::*;
    {

        var nodes : FastXMLList = null;  //todo: svg..*::*;
        for (node in nodes)
        {
            if (node != null && (Std.string(node.node.localName.innerData()).toLowerCase() == "lineargradient" || Std.string(node.node.localName.innerData()).toLowerCase() == "radialgradient"))
            {
                parseGradient(node.att.id, svg);
            }
        }
    }

    private function parseGradient(id : String, svg : FastXML) : SVGGradient
    {
        id = StringUtil.ltrim(id, "#");

        if (_target.hasDefinition(id))
        {
            return try cast(_target.getDefinition(id), SVGGradient) catch(e:Dynamic) null;
        }

        //var xml_grad:XML = svg..*.(attribute("id")==id)[0];
        var xml_grad : FastXML = null;  //todo: svg..*.(attribute("id")==id)[0];

        if (xml_grad == null)
        {
            return null;
        }

        var grad : SVGGradient;

        switch (xml_grad.node.localName.innerData().toLowerCase())
        {
            case "lineargradient":
                grad = new SVGLinearGradient();
            case "radialgradient":
                grad = new SVGRadialGradient();
        }

        //Inherits the href reference
        var xlink : Namespace = new Namespace("http://www.w3.org/1999/xlink");
        //if(xml_grad.@xlink::href.length() > 0){
        if (xml_grad.att.xlink.href.length() > 0) {

        //todo{

            //var baseGradient:SVGGradient = parseGradient(xml_grad.@xlink::href, svg);
            var baseGradient : SVGGradient = null;  //todo: parseGradient(xml_grad.@xlink::href, svg);
            if (baseGradient != null)
            {
                baseGradient.copyTo(grad);
            }
        }
        //

        if (Lambda.has(xml_grad, "@gradientUnits"))
        {
            grad.gradientUnits = xml_grad.att.gradientUnits;
        }
        else
        {
            grad.gradientUnits = "objectBoundingBox";
        }

        if (Lambda.has(xml_grad, "@gradientTransform"))
        {
            grad.transform = SVGParserCommon.parseTransformation(xml_grad.att.gradientTransform);
        }

        var _sw0_ = (grad.type);

        switch (_sw0_)
        {
            case GradientType.LINEAR:{
                var linearGrad : SVGLinearGradient = try cast(grad, SVGLinearGradient) catch(e:Dynamic) null;

                if (Lambda.has(xml_grad, "@x1"))
                {
                    linearGrad.x1 = xml_grad.att.x1;
                }
                else if (linearGrad.x1 == null)
                {
                    linearGrad.x1 = "0%";
                }

                if (Lambda.has(xml_grad, "@y1"))
                {
                    linearGrad.y1 = xml_grad.att.y1;
                }
                else if (linearGrad.y1 == null)
                {
                    linearGrad.y1 = "0%";
                }

                if (Lambda.has(xml_grad, "@x2"))
                {
                    linearGrad.x2 = xml_grad.att.x2;
                }
                else if (linearGrad.x2 == null)
                {
                    linearGrad.x2 = "100%";
                }

                if (Lambda.has(xml_grad, "@y2"))
                {
                    linearGrad.y2 = xml_grad.att.y2;
                }
                else if (linearGrad.y2 == null)
                {
                    linearGrad.y2 = "0%";
                }
            }
            case GradientType.RADIAL:{
                var radialGrad : SVGRadialGradient = try cast(grad, SVGRadialGradient) catch(e:Dynamic) null;

                if (Lambda.has(xml_grad, "@cx"))
                {
                    radialGrad.cx = xml_grad.att.cx;
                }
                else if (radialGrad.cx == null)
                {
                    radialGrad.cx = "50%";
                }

                if (Lambda.has(xml_grad, "@cy"))
                {
                    radialGrad.cy = xml_grad.att.cy;
                }
                else if (radialGrad.cy == null)
                {
                    radialGrad.cy = "50%";
                }

                if (Lambda.has(xml_grad, "@r"))
                {
                    radialGrad.r = xml_grad.att.r;
                }
                else if (radialGrad.r == null)
                {
                    radialGrad.r = "50%";
                }

                if (Lambda.has(xml_grad, "@fx"))
                {
                    radialGrad.fx = xml_grad.att.fx;
                }
                else if (radialGrad.fx == null)
                {
                    radialGrad.fx = radialGrad.cx;
                }

                if (Lambda.has(xml_grad, "@fy"))
                {
                    radialGrad.fy = xml_grad.att.fy;
                }
                else if (radialGrad.fy == null)
                {
                    radialGrad.fy = radialGrad.cy;
                }
            }
        }

        var _sw1_ = (xml_grad.att.spreadMethod);

        switch (_sw1_)
        {
            case "pad":grad.spreadMethod = SpreadMethod.PAD;
            case "reflect":grad.spreadMethod = SpreadMethod.REFLECT;
            case "repeat":grad.spreadMethod = SpreadMethod.REPEAT;
            default:grad.spreadMethod = SpreadMethod.PAD;
        }

        if (grad.colors == null)
        {
            grad.colors = new Array<Dynamic>();
        }

        if (grad.alphas == null)
        {
            grad.alphas = new Array<Dynamic>();
        }

        if (grad.ratios == null)
        {
            grad.ratios = new Array<Dynamic>();
        }

        //for each(var stop:XML in xml_grad.*::stop){
        for (stop in xml_grad.nodes.stop) {

        //todo:{

            var stopStyle : StyleDeclaration = new StyleDeclaration();

            if (Lambda.has(stop, "@stop-opacity"))
            {
                stopStyle.setProperty("stop-opacity", stop.att.stop-opacity);
            }

            if (Lambda.has(stop, "@stop-color"))
            {
                stopStyle.setProperty("stop-color", stop.att.stop-color);
            }

            if (Lambda.has(stop, "@style"))
            {
                stopStyle.fromString(stop.att.style);
            }

            grad.colors.push(SVGColorUtils.parseToUint(stopStyle.getPropertyValue("stop-color")));
            grad.alphas.push((stopStyle.getPropertyValue("stop-opacity") != null) ? as3hx.Compat.parseFloat(stopStyle.getPropertyValue("stop-opacity")) : 1);

            var offset : Float = as3hx.Compat.parseFloat(StringUtil.rtrim(stop.att.offset, "%"));
            if (Std.string(stop.att.offset).indexOf("%") > -1)
            {
                offset /= 100;
            }
            grad.ratios.push(offset * 255);
        }

        //Save the gradient definition
        _target.addDefinition(id, grad);

        return grad;
    }

    private function parseFilters(svg : FastXML) : Void
    //var nodes:XMLList = svg..*::*;
    {

        var nodes : FastXMLList = null;  //todo: svg..*::*;
        for (node in nodes)
        {
            if (node != null && (Std.string(node.node.localName.innerData()).toLowerCase() == "filter"))
            {
                parseFilterCollection(node);
            }
        }
    }

    private function parseFilterCollection(node : FastXML) : Void
    {
        var filterCollection : SVGFilterCollection = new SVGFilterCollection();
        for (childNode/* AS3HX WARNING could not determine type for var: childNode exp: ECall(EField(EIdent(node),elements),[]) type: null */ in node.nodes.elements())
        {
            var filter : ISVGFilter = parseFilter(childNode);
            if (filter != null)
            {
                filterCollection.svgFilters.push(filter);
            }
        }

        var id : String = StringUtil.ltrim(node.att.id, "#");
        _target.addDefinition(id, filterCollection);
    }

    private function parseFilter(node : FastXML) : ISVGFilter
    {
        var localName : String = Std.string(node.node.localName.innerData()).toLowerCase();

        switch (localName)
        {
            case "fegaussianblur":return parseFilterGaussianBlur(node);
            case "fecolormatrix":return parseFilterColorMatrix(node);
        }

        return null;
    }

    private function parseFilterGaussianBlur(node : FastXML) : SVGGaussianBlur
    {
        var obj : SVGGaussianBlur = new SVGGaussianBlur();

        if ((Lambda.has(node, "@stdDeviation")))
        {
            var parts : Array<Dynamic> = Std.string(node.att.stdDeviation).split(new as3hx.Compat.Regex('[\\s,]+', ""));
            obj.stdDeviationX = as3hx.Compat.parseFloat(parts[0]);
            obj.stdDeviationY = (parts.length > 1) ? as3hx.Compat.parseFloat(parts[1]) : as3hx.Compat.parseFloat(parts[0]);
        }

        return obj;
    }

    private function parseFilterColorMatrix(node : FastXML) : SVGColorMatrix
    {
        var obj : SVGColorMatrix = new SVGColorMatrix();


//        obj.type = ((Lambda.has(node, "@type"))) ? node.att.type : "matrix";
        obj.type = node.has.resolve("type") ? node.att.resolve("type") : "matrix";

        var valuesString : String = ((node.has.resolve("values"))) ? node.att.resolve("values") : "";
        var values : Array<Dynamic> = [];
        for (v in SVGParserCommon.splitNumericArgs(valuesString))
        {
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

