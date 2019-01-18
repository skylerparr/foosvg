package com.lorentz.svg.data.gradients;

import flash.display.GradientType;
import com.lorentz.svg.utils.ICloneable;
import flash.geom.Matrix;

class SVGGradient implements ICloneable
{
    public var type(get, never) : GradientType;

    public function new(type : String)
    {
        _type = type;
    }
    
    private var _type : GradientType;
    private function get_type() : GradientType
    {
        return _type;
    }
    
    public var gradientUnits : String;
    public var transform : Matrix;
    public var spreadMethod : String;
    
    public var colors : Array<UInt>;
    public var alphas : Array<Float>;
    public var ratios : Array<Int>;
    
    public function clone() : Dynamic
    {
        var clazz : Class<Dynamic> = Type.getClass(Type.resolveClass(Type.getClassName(Type.getClass(this))));
        var copy : SVGGradient = Type.createInstance(clazz, []);
        copyTo(copy);
        return copy;
    }
    
    public function copyTo(target : SVGGradient) : Void
    {
        target.gradientUnits = gradientUnits;
        target.transform = (transform == null) ? null : transform.clone();
        target.spreadMethod = spreadMethod;
        target.colors = (colors == null) ? null : colors.copy();
        target.alphas = (alphas == null) ? null : alphas.copy();
        target.ratios = (ratios == null) ? null : ratios.copy();
    }
}
