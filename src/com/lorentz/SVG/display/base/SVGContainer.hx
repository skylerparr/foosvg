package com.lorentz.sVG.display.base;


class SVGContainer extends SVGElement
{
    public var numElements(get, never) : Int;

    private var _invalidElements : Bool = false;
    private var _elements : Array<SVGElement> = new Array<SVGElement>();
    
    public function new(tagName : String)
    {
        super(tagName);
    }
    
    private function invalidateElements() : Void
    {
        if (!_invalidElements)
        {
            _invalidElements = true;
            invalidateProperties();
        }
    }
    
    override private function commitProperties() : Void
    {
        super.commitProperties();
        
        if (_invalidElements)
        {
            _invalidElements = false;
            
            while (content.numChildren > 0)
            {
                content.removeChildAt(0);
            }
            
            for (element in _elements)
            {
                content.addChild(element);
            }
        }
    }
    
    public function addElement(element : SVGElement) : Void
    {
        addElementAt(element, numElements);
    }
    
    public function addElementAt(element : SVGElement, index : Int) : Void
    {
        if (Lambda.indexOf(_elements, element) == -1)
        {
            as3hx.Compat.arraySplice(_elements, index, 0, [element]);
            invalidateElements();
            attachElement(element);
        }
    }
    
    public function getElementAt(index : Int) : SVGElement
    {
        return _elements[index];
    }
    
    private function get_numElements() : Int
    {
        return _elements.length;
    }
    
    public function removeElement(element : SVGElement) : Void
    {
        removeElementAt(Lambda.indexOf(_elements, element));
    }
    
    public function removeElementAt(index : Int) : Void
    {
        if (index >= 0 && index < numElements)
        {
            var element : SVGElement = _elements.splice(index, 1)[0];
            invalidateElements();
            detachElement(element);
        }
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGContainer = try cast(super.clone(), SVGContainer) catch(e:Dynamic) null;
        for (i in 0...numElements)
        {
            c.addElement(try cast(getElementAt(i).clone(), SVGElement) catch(e:Dynamic) null);
        }
        return c;
    }
}
