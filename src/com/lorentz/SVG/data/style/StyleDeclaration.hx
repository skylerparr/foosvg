package com.lorentz.sVG.data.style;

import com.lorentz.sVG.events.StyleDeclarationEvent;
import com.lorentz.sVG.utils.ICloneable;
import com.lorentz.sVG.utils.StringUtil;
import flash.events.EventDispatcher;

@:meta(Event(name="propertyChange",type="com.lorentz.SVG.events.StyleDeclarationEvent"))

class StyleDeclaration extends EventDispatcher implements ICloneable
{
    public var length(get, never) : Int;

    private var _propertiesValues : Dynamic = { };
    private var _indexedProperties : Array<Dynamic> = [];
    
    public function getPropertyValue(propertyName : String) : String
    {
        return Reflect.field(_propertiesValues, propertyName);
    }
    
    public function setProperty(propertyName : String, value : String) : Void
    {
        if (Reflect.field(_propertiesValues, propertyName) != value)
        {
            var oldValue : String = Reflect.field(_propertiesValues, propertyName);
            
            Reflect.setField(_propertiesValues, propertyName, value);
            indexProperty(propertyName);
            
            dispatchEvent(new StyleDeclarationEvent(StyleDeclarationEvent.PROPERTY_CHANGE, propertyName, oldValue, value));
        }
    }
    
    public function removeProperty(propertyName : String) : String
    {
        var oldValue : String = Reflect.field(_propertiesValues, propertyName);
        Reflect.deleteField(_propertiesValues, propertyName);
        unindexProperty(propertyName);
        
        dispatchEvent(new StyleDeclarationEvent(StyleDeclarationEvent.PROPERTY_CHANGE, propertyName, oldValue, null));
        
        return oldValue;
    }
    
    public function hasProperty(propertyName : String) : Bool
    {
        var index : Int = Lambda.indexOf(_indexedProperties, propertyName);
        return index != -1;
    }
    
    private function get_length() : Int
    {
        return _indexedProperties.length;
    }
    
    public function item(index : Int) : String
    {
        return _indexedProperties[index];
    }
    
    public function fromString(styleString : String) : Void
    {
        styleString = StringTools.trim(styleString);
        styleString = StringUtil.rtrim(styleString, ";");
        
        for (prop/* AS3HX WARNING could not determine type for var: prop exp: ECall(EField(EIdent(styleString),split),[EConst(CString(;))]) type: null */ in styleString.split(";"))
        {
            var split : Array<Dynamic> = prop.split(":");
            if (split.length == 2)
            {
                setProperty(StringTools.trim(split[0]), StringTools.trim(split[1]));
            }
        }
    }
    
    public static function createFromString(styleString : String) : StyleDeclaration
    {
        var styleDeclaration : StyleDeclaration = new StyleDeclaration();
        styleDeclaration.fromString(styleString);
        return styleDeclaration;
    }
    
    override public function toString() : String
    {
        var styleString : String = "";
        
        for (propertyName in _indexedProperties)
        {
            styleString += propertyName + ":" + Reflect.field(_propertiesValues, Std.string(propertyName)) + "; ";
        }
        
        return styleString;
    }
    
    public function clear() : Void
    {
        while (length > 0)
        {
            removeProperty(item(0));
        }
    }
    
    private static var nonInheritableProperties : Array<Dynamic> = [
        "display", 
        "opacity", 
        "clip", 
        "filter", 
        "overflow", 
        "clip-path"
    ];
    public function copyStyles(target : StyleDeclaration, onlyInheritable : Bool = false) : Void
    {
        for (propertyName in _indexedProperties)
        {
            if (!onlyInheritable || Lambda.indexOf(nonInheritableProperties, propertyName) == -1)
            {
                target.setProperty(propertyName, getPropertyValue(propertyName));
            }
        }
    }
    
    public function cloneOn(target : StyleDeclaration) : Void
    {
        var propertyName : String;
        
        for (propertyName in _indexedProperties)
        {
            target.setProperty(propertyName, getPropertyValue(propertyName));
        }
        
        var i : Int = 0;
        while (i < target.length)
        {
            propertyName = target.item(i);
            if (!hasProperty(propertyName))
            {
                target.removeProperty(propertyName);
            }
            i++;
        }
    }
    
    private function indexProperty(propertyName : String) : Void
    {
        if (Lambda.indexOf(_indexedProperties, propertyName) == -1)
        {
            _indexedProperties.push(propertyName);
        }
    }
    
    private function unindexProperty(propertyName : String) : Void
    {
        var index : Int = Lambda.indexOf(_indexedProperties, propertyName);
        if (index != -1)
        {
            _indexedProperties.splice(index, 1);
        }
    }
    
    public function clone() : Dynamic
    {
        var c : StyleDeclaration = new StyleDeclaration();
        cloneOn(c);
        return c;
    }

    public function new()
    {
        super();
    }
}
