package com.lorentz.sVG.text;

import com.lorentz.sVG.data.text.SVGDrawnText;
import com.lorentz.sVG.data.text.SVGTextToDraw;

interface ISVGTextDrawer
{

    function start() : Void
    ;
    
    function drawText(data : SVGTextToDraw) : SVGDrawnText
    ;
    
    function end() : Void
    ;
}
