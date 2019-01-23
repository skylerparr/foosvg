package com.lorentz.svg.display.base;

import flash.display.GradientType;
import flash.filters.BitmapFilter;
import flash.errors.Error;
import haxe.Constraints.Function;
import com.lorentz.svg.data.filters.SVGFilterCollection;
import com.lorentz.svg.data.style.StyleDeclaration;
import com.lorentz.svg.display.SVGClipPath;
import com.lorentz.svg.display.SVGDocument;
import com.lorentz.svg.display.SVGPattern;
import com.lorentz.svg.events.SVGEvent;
import com.lorentz.svg.events.StyleDeclarationEvent;
import com.lorentz.svg.parser.SVGParserCommon;
import com.lorentz.svg.utils.ICloneable;
import com.lorentz.svg.utils.MathUtils;
import com.lorentz.svg.utils.SVGUtil;
import com.lorentz.svg.utils.SVGViewPortUtils;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.geom.Rectangle;

@:meta(Event(name = "invalidate", type = "com.lorentz.svg.events.SVGEvent"))

@:meta(Event(name = "syncValidated", type = "com.lorentz.svg.events.SVGEvent"))

@:meta(Event(name = "asyncValidated", type = "com.lorentz.svg.events.SVGEvent"))

@:meta(Event(name = "validated", type = "com.lorentz.svg.events.SVGEvent"))

class SVGElement extends Sprite implements ICloneable {
    public var type(get, never): String;
    public var id(get, set): String;
    public var svgClass(get, set): String;
    public var svgClipPath(get, set): String;
    public var svgMask(get, set): String;
    public var svgTransform(get, set): String;
    public var style(get, never): StyleDeclaration;
    public var finalStyle(get, never): StyleDeclaration;
    public var parentElement(get, never): SVGElement;
    public var document(get, never): SVGDocument;
    public var viewPortElement(get, never): ISVGViewPort;
    public var validationInProgress(get, never): Bool;
    private var numInvalidElements(get, set): Int;
    private var numRunningAsyncValidations(get, set): Int;
    private var shouldApplySvgTransform(get, never): Bool;
    public var currentFontSize(get, never): Float;
    public var viewPortWidth(get, never): Float;
    public var viewPortHeight(get, never): Float;

    private var content: Sprite;
    private static var _staticId: Int;

    private var _mask: DisplayObject;
    private static var _maskRgbToLuminanceFilter: ColorMatrixFilter = new ColorMatrixFilter([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.2125, 0.7154, 0.0721, 0, 0]);

    private var _currentFontSize: Float = Math.NaN;

    private var _type: String;
    private var _id: String;
    private var memberId: Int;

    private var _svgClipPathChanged: Bool = false;
    private var _svgMaskChanged: Bool = false;
    private var _svgFilterChanged: Bool = false;

    private var _style: StyleDeclaration;
    private var _finalStyle: StyleDeclaration;

    private var _parentElement: SVGElement;
    private var _viewPortElement: ISVGViewPort;
    private var _document: SVGDocument;
    private var _numInvalidElements: Int = 0;
    private var _numRunningAsyncValidations: Int = 0;
    private var _runningAsyncValidations: Dynamic = { };
    private var _invalidFlag: Bool = false;
    private var _invalidStyleFlag: Bool = false;
    private var _invalidPropertiesFlag: Bool = false;
    private var _invalidTransformFlag: Bool = false;
    private var _displayChanged: Bool = false;
    private var _opacityChanged: Bool = false;
    private var _attributes: Dynamic = { };

    private var _elementsAttached: Array<SVGElement> = new Array<SVGElement>();

    private var _viewPortWidth: Float;
    private var _viewPortHeight: Float;

    public function new(tagName: String) {
        memberId = ++_staticId;
        super();
        _type = tagName;
        initialize();
    }

    private function initialize(): Void {
        _style = new StyleDeclaration();
        _style.addEventListener(StyleDeclarationEvent.PROPERTY_CHANGE, style_propertyChangeHandler, false, 0, true);
        _finalStyle = new StyleDeclaration();
        _finalStyle.addEventListener(StyleDeclarationEvent.PROPERTY_CHANGE, finalStyle_propertyChangeHandler, false, 0, true);

        content = new Sprite();
        addChild(content);
    }

    private function get_type(): String {
        return _type;
    }

    private function get_id(): String {
        return _id;
    }

    private function set_id(value: String): String {
        _id = value;
        return value;
    }

    private function get_svgClass(): String {
        return Std.string(getAttribute("class"));
    }

    private function set_svgClass(value: String): String {
        setAttribute("class", value);
        return value;
    }

    private function get_svgClipPath(): String {
        return Std.string(getAttribute("clip-path"));
    }

    private function set_svgClipPath(value: String): String {
        setAttribute("clip-path", value);
        return value;
    }

    private function get_svgMask(): String {
        return Std.string(getAttribute("mask"));
    }

    private function set_svgMask(value: String): String {
        setAttribute("mask", value);
        return value;
    }

    private function get_svgTransform(): String {
        return Std.string(getAttribute("transform"));
    }

    private function set_svgTransform(value: String): String {
        setAttribute("transform", value);
        return value;
    }

    public function getAttribute(name: String): Dynamic {
        return Reflect.field(_attributes, name);
    }

    public function setAttribute(name: String, value: Dynamic): Void {
        if (Reflect.field(_attributes, name) != value) {
            var oldValue: Dynamic = Reflect.field(_attributes, name);

            Reflect.setField(_attributes, name, value);

            onAttributeChanged(name, oldValue, value);
        }
    }

    public function removeAttribute(name: String): Void {
        Reflect.deleteField(_attributes, name);
    }

    public function hasAttribute(name: String): Bool {
        return Lambda.has(_attributes, name);
    }

    private function onAttributeChanged(attributeName: String, oldValue: Dynamic, newValue: Dynamic): Void {
        switch (attributeName)
        {
            case "class":
                invalidateStyle(true);
            case "clip-path":
                _svgClipPathChanged = true;
                invalidateProperties();
            case "mask":
                _svgMaskChanged = true;
                invalidateProperties();
            case "transform":
                _invalidTransformFlag = true;
                invalidateProperties();
        }
    }

    /////////////////////////////
    // Stores a list of elements that are attached to this element
    /////////////////////////////
    private function attachElement(element: SVGElement): Void {
        if (Lambda.indexOf(_elementsAttached, element) == -1) {
            _elementsAttached.push(element);
            element.setParentElement(this);
        }
    }

    private function detachElement(element: SVGElement): Void {
        var index: Int = Lambda.indexOf(_elementsAttached, element);
        if (index != -1) {
            _elementsAttached.splice(index, 1);
            element.setParentElement(null);
        }
    }

    ///////////////////////////////////////
    // Style manipulation
    ///////////////////////////////////////
    private function get_style(): StyleDeclaration {
        return _style;
    }

    private function get_finalStyle(): StyleDeclaration {
        return _finalStyle;
    }
    ///////////////////////////////////////

    public function isInClipPath(): Bool {
        if (Std.is(this, SVGClipPath)) {
            return true;
        }

        if (parentElement == null) {
            return false;
        }

        return parentElement.isInClipPath();
    }

    private function get_parentElement(): SVGElement {
        return _parentElement;
    }

    private function setParentElement(value: SVGElement): Void {
                if (_parentElement != value) {
            if (_parentElement != null) {
                                                _parentElement.numInvalidElements -= _numInvalidElements;
                _parentElement.numRunningAsyncValidations -= _numRunningAsyncValidations;
            }

            _parentElement = value;

                        if (_parentElement != null) {
                                                _parentElement.numInvalidElements += _numInvalidElements;
                _parentElement.numRunningAsyncValidations += _numRunningAsyncValidations;
            }

            setSVGDocument((_parentElement != null) ? _parentElement.document : null);
            setViewPortElement((_parentElement != null) ? _parentElement.viewPortElement : null);

            invalidateStyle();
        }
    }

    private function setSVGDocument(value: SVGDocument): Void {
        if (_document != value) {
            if (_document != null) {
                _document.onElementRemoved(this);
            }

            _document = value;

            if (_document != null) {
                _document.onElementAdded(this);
            }

            invalidateStyle(true);

            for (element in _elementsAttached) {
                element.setSVGDocument(value);
            }
        }
    }

    private function setViewPortElement(value: ISVGViewPort): Void {
        if (_viewPortElement != value) {
            _viewPortElement = value;

            for (element in _elementsAttached) {
                element.setViewPortElement(value);
            }
        }
    }

    private function get_document(): SVGDocument {
        return (Std.is(this, SVGDocument)) ? try cast(this, SVGDocument) catch (e: Dynamic) null : _document;
    }

    private function get_viewPortElement(): ISVGViewPort {
        return (Std.is(this, ISVGViewPort)) ? try cast(this, ISVGViewPort) catch (e: Dynamic) null : _viewPortElement;
    }

    private function get_validationInProgress(): Bool {
        return numInvalidElements != 0 || numRunningAsyncValidations != 0;
    }

    private function get_numInvalidElements(): Int {
        return _numInvalidElements;
    }

    private function set_numInvalidElements(value: Int): Int {
                        var d: Int = as3hx.Compat.parseInt(value - _numInvalidElements);

        _numInvalidElements = value;

                if (_parentElement != null) {
                                    _parentElement.numInvalidElements += d;
        }

                        if (_numInvalidElements == 0 && d != 0) {
                        if (hasEventListener(SVGEvent.SYNC_VALIDATED)) {
                                dispatchEvent(new SVGEvent(SVGEvent.SYNC_VALIDATED));
            }
            onPartialyValidated();
        }
        return value;
    }

    private function get_numRunningAsyncValidations(): Int {
        return _numRunningAsyncValidations;
    }

    private function set_numRunningAsyncValidations(value: Int): Int {
        var d: Int = as3hx.Compat.parseInt(value - _numRunningAsyncValidations);

        _numRunningAsyncValidations = value;

        if (_numRunningAsyncValidations == 0 && d != 0) {
            if (hasEventListener(SVGEvent.ASYNC_VALIDATED)) {
                dispatchEvent(new SVGEvent(SVGEvent.ASYNC_VALIDATED));
            }
            onPartialyValidated();
        }

        if (_parentElement != null) {
            _parentElement.numRunningAsyncValidations += d;
        }
        return value;
    }

    private function onPartialyValidated(): Void {
                if (Std.is(this, ISVGViewPort) && document != null) {
                        adjustContentToViewPort();
        }

                if (!validationInProgress) {
                        if (hasEventListener(SVGEvent.VALIDATED)) {
                                dispatchEvent(new SVGEvent(SVGEvent.VALIDATED));
            }
                        onValidated();
        }
    }

    private function onValidated(): Void {
    }

    private function _invalidate(): Void {
                if (!_invalidFlag) {
                        _invalidFlag = true;

            numInvalidElements += 1;

            if (hasEventListener(SVGEvent.INVALIDATE)) {
                dispatchEvent(new SVGEvent(SVGEvent.INVALIDATE));
            }
        }
    }

    public function invalidateStyle(recursive: Bool = true): Void {
        if (!_invalidStyleFlag) {
            _invalidStyleFlag = true;
            _invalidate();
        }
        if (recursive) {
            for (element in _elementsAttached) {
                element.invalidateStyle(recursive);
            }
        }
    }

    public function invalidateProperties(): Void {
        if (!_invalidPropertiesFlag) {
            _invalidPropertiesFlag = true;
            _invalidate();
        }
    }

    public function validate(): Void {
        if (_invalidStyleFlag) {
            updateStyles();
        }

        updateCurrentFontSize();

        if (_invalidPropertiesFlag) {
            commitProperties();
        }

                        if (_invalidFlag) {
                        _invalidFlag = false;
            numInvalidElements -= 1;
        }

                if (numInvalidElements > 0) {
            for (element in _elementsAttached) {
                element.validate();
            }
        }
    }

    public function beginASyncValidation(validationId: String): Void {
        if (Reflect.field(_runningAsyncValidations, validationId) == null) {
            Reflect.setField(_runningAsyncValidations, validationId, true);
            numRunningAsyncValidations++;
        }
    }

    public function endASyncValidation(validationId: String): Void {
        if (Reflect.field(_runningAsyncValidations, validationId) != null) {
            numRunningAsyncValidations--;
            Reflect.deleteField(_runningAsyncValidations, validationId);
        }
    }

    private function getElementToInheritStyles(): SVGElement {
        if (Std.is(this, SVGPattern)) {
            return null;
        }

        return parentElement;
    }

    private function updateStyles(): Void {
        _invalidStyleFlag = false;

        var newFinalStyle: StyleDeclaration = new StyleDeclaration();

        var inheritFrom: SVGElement = getElementToInheritStyles();
        if (inheritFrom != null) {
            inheritFrom.finalStyle.copyStyles(newFinalStyle, true);
        }

        var typeStyle: StyleDeclaration = document.getStyleDeclaration(_type);
        if (typeStyle != null) {

            typeStyle.copyStyles(newFinalStyle);
        }

        if (svgClass != null) {

            for (className in svgClass.split(" ")) {
                var classStyle: StyleDeclaration = document.getStyleDeclaration("." + className);
                if (classStyle != null) {
                    classStyle.copyStyles(newFinalStyle);
                }
            }
        }

        //Merge all styles with the style attribute
        _style.copyStyles(newFinalStyle);

        //Apply new finalStyle
        newFinalStyle.cloneOn(_finalStyle);
    }

    private function style_propertyChangeHandler(e: StyleDeclarationEvent): Void {
        invalidateStyle();
    }

    private function finalStyle_propertyChangeHandler(e: StyleDeclarationEvent): Void {
        onStyleChanged(e.propertyName, e.oldValue, e.newValue);
    }

    private function onStyleChanged(styleName: String, oldValue: String, newValue: String): Void {
        switch (styleName)
        {
            case "display":
                _displayChanged = true;
                invalidateProperties();
            case "opacity":
                _opacityChanged = true;
                invalidateProperties();
            case "filter":
                _svgFilterChanged = true;
                invalidateProperties();
            case "clip-path":
                _svgClipPathChanged = true;
                invalidateProperties();
        }
    }

    private function get_shouldApplySvgTransform(): Bool {
        return true;
    }

    private function computeTransformMatrix(): Matrix {
        var mat: Matrix = null;

        if (transform.matrix != null) {
            mat = transform.matrix;
            mat.identity();
        }
        else {
            mat = new Matrix();
        }

        mat.scale(scaleX, scaleY);
        mat.rotate(MathUtils.radiusToDegress(rotation));
        mat.translate(x, y);

        if (shouldApplySvgTransform && svgTransform != null) {
            var svgTransformMat: Matrix = SVGParserCommon.parseTransformation(svgTransform);
            if (svgTransformMat != null) {
                mat.concat(svgTransformMat);
            }
        }

        return mat;
    }

    private function get_currentFontSize(): Float {
        return _currentFontSize;
    }

    private function updateCurrentFontSize(): Void {
        _currentFontSize = Math.NaN;

        if (parentElement != null) {
            _currentFontSize = parentElement.currentFontSize;
        }

        var fontSize: String = finalStyle.getPropertyValue("font-size");
        if (fontSize != null) {
            _currentFontSize = SVGUtil.getFontSize(fontSize, _currentFontSize, viewPortWidth, viewPortHeight);
        }

        if (Math.isNaN(_currentFontSize)) {
            _currentFontSize = SVGUtil.getFontSize("medium", currentFontSize, viewPortWidth, viewPortHeight);
        }
    }

    private function commitProperties(): Void {
        _invalidPropertiesFlag = false;


        if (_invalidTransformFlag) {
            _invalidTransformFlag = false;
            transform.matrix = computeTransformMatrix();
        }

        if (_svgClipPathChanged || _svgMaskChanged) {
            _svgClipPathChanged = false;
            _svgMaskChanged = false;

            if (_mask != null) {
                content.mask = null;
                content.cacheAsBitmap = false;
                removeChild(_mask);
                if (Std.is(_mask, SVGElement)) {
                    detachElement(try cast(_mask, SVGElement) catch (e: Dynamic) null);
                }
                else if (Std.is(_mask, Bitmap)) {
                    (try cast(_mask, Bitmap) catch (e: Dynamic) null).bitmapData.dispose();
                    (try cast(_mask, Bitmap) catch (e: Dynamic) null).bitmapData = null;
                }
                _mask = null;
            }

            var mask: SVGElement = null;
            var clip: SVGElement = null;
            var validateN: Int = 0;

            var onClipOrMaskValidated: SVGEvent->Void = function(e: SVGEvent): Void {
//                e.target.removeEventListener(SVGEvent.VALIDATED, onClipOrMaskValidated);

                --validateN;

                if (validateN == 0) {
                    if (mask != null) {
                        if (clip != null) {
                            mask.mask = clip;
                            clip.cacheAsBitmap = false;
                        }

                        var maskRc: Rectangle = mask.getBounds(mask);
                        if (maskRc.width > 0 && maskRc.height > 0) {
                            var matrix: Matrix = new Matrix();
                            matrix.translate(-maskRc.left, -maskRc.top);

                            var bmd: BitmapData = new BitmapData(Std.int(maskRc.width), Std.int(maskRc.height), true, 0);
                            bmd.draw(mask, matrix, null, null, null, true);

                            mask.filters = [_maskRgbToLuminanceFilter];
                            bmd.draw(mask, matrix, null, BlendMode.ALPHA, null, true);

                            _mask = new Bitmap(bmd);
                            _mask.x = maskRc.left;
                            _mask.y = maskRc.top;

                            addChild(_mask);
                            _mask.cacheAsBitmap = true;
                            content.cacheAsBitmap = true;
                            content.mask = _mask;
                        }

                        detachElement(mask);
                        if (clip != null) {
                            detachElement(clip);
                            mask.mask = null;
                        }
                    }
                    else if (clip != null /*&& !mask*/) {
                        _mask = clip;
                        _mask.cacheAsBitmap = false;
                        content.cacheAsBitmap = false;
                        addChild(_mask);
                        content.mask = _mask;
                    }
                }
            }

            if (svgMask != null && svgMask != "" && svgMask != "none") {
                var maskId: String = SVGUtil.extractUrlId(svgMask);

                mask = try cast(document.getDefinitionClone(maskId), SVGElement) catch (e: Dynamic) null;

                if (mask != null) {
                    attachElement(mask);
                    mask.addEventListener(SVGEvent.VALIDATED, onClipOrMaskValidated);
                    validateN++;
                }
            }

            var clipPathValue: String = finalStyle.getPropertyValue("clip-path");
            if(clipPathValue == null) {
                clipPathValue = svgClipPath;
            }
            if (clipPathValue != null && clipPathValue != "" && clipPathValue != "none") {

                var clipPathId: String = SVGUtil.extractUrlId(clipPathValue);

                clip = try cast(document.getDefinitionClone(clipPathId), SVGElement) catch (e: Dynamic) null;

                if (clip != null) {
                    attachElement(clip);
                    clip.addEventListener(SVGEvent.VALIDATED, onClipOrMaskValidated);
                    validateN++;
                }
            }
        }

        if (_displayChanged) {
            _displayChanged = false;
            visible = finalStyle.getPropertyValue("display") != "none" && finalStyle.getPropertyValue("visibility") != "hidden";
        }

        if (_opacityChanged) {
            _opacityChanged = false;

            content.alpha = 1;
            if(finalStyle.getPropertyValue("opacity") != null) {
                content.alpha = finalStyle.getPropertyValue("opacity");
            }

            if (content.alpha != 1 && Std.is(this, SVGContainer)) {
                content.blendMode = BlendMode.LAYER;
            }
            else {
                content.blendMode = BlendMode.NORMAL;
            }
        }

        if (_svgFilterChanged) {
            _svgFilterChanged = false;

            var filters: Array<BitmapFilter> = [];

            var filterLink: String = finalStyle.getPropertyValue("filter");
            if (filterLink != null) {
                var filterId: String = SVGUtil.extractUrlId(filterLink);
                var filterCollection: SVGFilterCollection = try cast(document.getDefinition(filterId), SVGFilterCollection) catch (e: Dynamic) null;
                if (filterCollection != null) {
                    filters = filterCollection.getFlashFilters();
                }
            }

            this.filters = filters;
        }

        if (Std.is(this, ISVGViewPort)) {
            updateViewPortSize();
        }
    }

    private function getViewPortUserUnit(s: String, reference: String): Float {
        var viewPortWidth: Float = 0;
        var viewPortHeight: Float = 0;

        if (parentElement == document) {
            viewPortWidth = document.availableWidth;
            viewPortHeight = document.availableHeight;
        }
        else if (viewPortElement != null) {
            viewPortWidth = viewPortElement.viewPortWidth;
            viewPortHeight = viewPortElement.viewPortHeight;
        }

        return SVGUtil.getUserUnit(s, _currentFontSize, viewPortWidth, viewPortHeight, reference);
    }

    public function clone(): Dynamic {
        var clazz: Class<Dynamic> = Type.getClass(this);

        var copy: SVGElement = Type.createInstance(clazz, []);

        copy.svgClass = svgClass;
        copy.svgClipPath = svgClipPath;
        copy.svgMask = svgMask;
        _style.cloneOn(copy.style);

        copy.id = "????  Clone of \"" + id + "\"";

        copy.svgTransform = svgTransform;

        if (Std.is(this, ISVGViewBox)) {
            (try cast(copy, ISVGViewBox) catch (e: Dynamic) null).svgViewBox = (try cast(this, ISVGViewBox) catch (e: Dynamic) null).svgViewBox;
        }

        if (Std.is(this, ISVGPreserveAspectRatio)) {
            (try cast(copy, ISVGPreserveAspectRatio) catch (e: Dynamic) null).svgPreserveAspectRatio = (try cast(this, ISVGPreserveAspectRatio) catch (e: Dynamic) null).svgPreserveAspectRatio;
        }

        if (Std.is(this, ISVGViewPort)) {
            var thisViewPort: ISVGViewPort = try cast(this, ISVGViewPort) catch (e: Dynamic) null;
            var cViewPort: ISVGViewPort = try cast(copy, ISVGViewPort) catch (e: Dynamic) null;

            cViewPort.svgX = thisViewPort.svgX;
            cViewPort.svgY = thisViewPort.svgY;
            cViewPort.svgWidth = thisViewPort.svgWidth;
            cViewPort.svgHeight = thisViewPort.svgHeight;
            cViewPort.svgOverflow = thisViewPort.svgOverflow;
        }

        return copy;
    }

/////////////////////////////////////////////////
// ViewPort
/////////////////////////////////////////////////
    private function get_viewPortWidth(): Float {
        return _viewPortWidth;
    }

    private function get_viewPortHeight(): Float {
        return _viewPortHeight;
    }

    private function updateViewPortSize(): Void {
        var viewPort: ISVGViewPort = try cast(this, ISVGViewPort) catch (e: Dynamic) null;

        if (viewPort == null) {
            throw new Error("Element '" + type + "' isn't a viewPort.");
        }

        if (Std.is(this, ISVGViewBox) && (try cast(this, ISVGViewBox) catch (e: Dynamic) null).svgViewBox != null) {
            _viewPortWidth = (try cast(this, ISVGViewBox) catch (e: Dynamic) null).svgViewBox.width;
            _viewPortHeight = (try cast(this, ISVGViewBox) catch (e: Dynamic) null).svgViewBox.height;
        }
        else {
            if (viewPort.svgWidth != null) {
                _viewPortWidth = getViewPortUserUnit(viewPort.svgWidth, SVGUtil.WIDTH);
            }
            if (viewPort.svgHeight != null) {
                _viewPortHeight = getViewPortUserUnit(viewPort.svgHeight, SVGUtil.HEIGHT);
            }
        }
    }

    private function adjustContentToViewPort(): Void {
        var viewPort: ISVGViewPort = try cast(this, ISVGViewPort) catch (e: Dynamic) null;

        if (viewPort == null) {
            throw new Error("Element '" + type + "' isn't a viewPort.");
        }

        scrollRect = null;
        content.scaleX = 1;
        content.scaleY = 1;
        content.x = 0;
        content.y = 0;

        var viewBoxRect: Rectangle = getViewBoxRect();
        var viewPortRect: Rectangle = getViewPortRect();
        var svgPreserveAspectRatio: String = getPreserveAspectRatio();

        if (viewBoxRect != null && viewPortRect != null) {
            if (svgPreserveAspectRatio != "none") {

                var preserveAspectRatio: Dynamic = "";
                if(svgPreserveAspectRatio != null) {
                    preserveAspectRatio = SVGParserCommon.parsePreserveAspectRatio(svgPreserveAspectRatio);
                }

                var viewPortContentMetrics: Dynamic = SVGViewPortUtils.getContentMetrics(viewPortRect, viewBoxRect, preserveAspectRatio.align, preserveAspectRatio.meetOrSlice);

                if (preserveAspectRatio.meetOrSlice == "slice") {
                    this.scrollRect = viewPortRect;
                }

                content.x = viewPortContentMetrics.contentX;
                content.y = viewPortContentMetrics.contentY;
                content.scaleX = viewPortContentMetrics.contentScaleX;
                content.scaleY = viewPortContentMetrics.contentScaleY;
            }
            else {
                content.x = viewPortRect.x;
                content.y = viewPortRect.y;
                content.scaleX = viewPortRect.width / content.width;
                content.scaleY = viewPortRect.height / content.height;
            }
        }
    }

    private function getViewBoxRect(): Rectangle {
        if (Std.is(this, ISVGViewBox)) {
            return (try cast(this, ISVGViewBox) catch (e: Dynamic) null).svgViewBox;
        }
        else {
            return getContentBox();
        }
    }

    private function getContentBox(): Rectangle {
        return null;
    }

    private function getViewPortRect(): Rectangle {
        var viewPort: ISVGViewPort = try cast(this, ISVGViewPort) catch (e: Dynamic) null;

        if (viewPort != null && viewPort.svgWidth != null && viewPort.svgHeight != null) {
            var x: Float = (viewPort.svgX != null) ? getViewPortUserUnit(viewPort.svgX, SVGUtil.WIDTH) : 0;
            var y: Float = (viewPort.svgY != null) ? getViewPortUserUnit(viewPort.svgY, SVGUtil.HEIGHT) : 0;
            var w: Float = getViewPortUserUnit(viewPort.svgWidth, SVGUtil.WIDTH);
            var h: Float = getViewPortUserUnit(viewPort.svgHeight, SVGUtil.HEIGHT);

            return new Rectangle(x, y, w, h);
        }

        return null;
    }

    private function getPreserveAspectRatio(): String {
        var viewPort: ISVGViewPort = try cast(this, ISVGViewPort) catch (e: Dynamic) null;

        if (viewPort != null) {
            return viewPort.svgPreserveAspectRatio;
        }

        return null;
    }

/**
		 * metadata of the related svg node as defined in the
		 * original svg document
		 * @default null
		 **/
    public var metadata: FastXML;
}
