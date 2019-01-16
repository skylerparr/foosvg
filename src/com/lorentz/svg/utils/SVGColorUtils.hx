/* Author: Lucas Lorentz Lara - 25/09/2008
*/

package com.lorentz.svg.utils;


class SVGColorUtils
{
    private static var colors : Dynamic = { };
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public static function getColorByName(name : String) : Int
    {
        return Reflect.field(colors, Std.string(name.toLowerCase()));
    }
    
    public static function parseToUint(s : String) : Int
    {
        if (s == null)
        {
            return 0x000000;
        }
        
        s = StringTools.trim(s);
        
        if (s == "none" || s == "")
        {
            return 0x000000;
        }
        else if (s.charAt(0) == "#")
        {
            s = s.substring(1);
            if (s.length < 6)
            {
                s = s.charAt(0) + s.charAt(0) + s.charAt(1) + s.charAt(1) + s.charAt(2) + s.charAt(2);
            }
            return new Int("0x" + s);
        }
        else
        {
            var rgb : Array<Dynamic> = (new as3hx.Compat.Regex('\\s*rgb\\s*\\(\\s*(.*?)\\s*,\\s*(.*?)\\s*,\\s*(.*?)\\s*\\)', "g")).exec(s);
            
            if (rgb != null)
            {
                var r : Int = rgbColorPartToUint(rgb[1]);
                var g : Int = rgbColorPartToUint(rgb[2]);
                var b : Int = rgbColorPartToUint(rgb[3]);
                return as3hx.Compat.parseInt(r << 16 | g << 8 | b);
            }
            else
            {
                return getColorByName(s);
            }
        }
    }
    
    private static function rgbColorPartToUint(s : String) : Int
    {
        if (s.indexOf("%") != -1)
        {
            return as3hx.Compat.parseInt(as3hx.Compat.parseFloat(StringTools.replace(s, "%", "")) / 100 * 255);
        }
        else
        {
            return as3hx.Compat.parseInt(s);
        }
    }
    
    public static function uintToSVG(color : Int) : String
    {
        var colorText : String = Std.string(color);
        while (colorText.length < 6)
        {
            colorText = "0" + colorText;
        }
        return "#" + colorText;
    }

    public function new()
    {
    }
    private static var SVGColorUtils_static_initializer = {
        Reflect.setField(colors, "aliceblue", 0xF0F8FF);
        Reflect.setField(colors, "antiquewhite", 0xFAEBD7);
        Reflect.setField(colors, "aqua", 0x00FFFF);
        Reflect.setField(colors, "aquamarine", 0x7FFFD4);
        Reflect.setField(colors, "azure", 0xF0FFFF);
        Reflect.setField(colors, "beige", 0xF5F5DC);
        Reflect.setField(colors, "bisque", 0xFFE4C4);
        Reflect.setField(colors, "black", 0x000000);
        Reflect.setField(colors, "blanchedalmond", 0xFFEBCD);
        Reflect.setField(colors, "blue", 0x0000FF);
        Reflect.setField(colors, "blueviolet", 0x8A2BE2);
        Reflect.setField(colors, "brown", 0xA52A2A);
        Reflect.setField(colors, "burlywood", 0xDEB887);
        Reflect.setField(colors, "cadetblue", 0x5F9EA0);
        Reflect.setField(colors, "chartreuse", 0x7FFF00);
        Reflect.setField(colors, "chocolate", 0xD2691E);
        Reflect.setField(colors, "coral", 0xFF7F50);
        Reflect.setField(colors, "cornflowerblue", 0x6495ED);
        Reflect.setField(colors, "cornsilk", 0xFFF8DC);
        Reflect.setField(colors, "crimson", 0xDC143C);
        Reflect.setField(colors, "cyan", 0x00FFFF);
        Reflect.setField(colors, "darkblue", 0x00008B);
        Reflect.setField(colors, "darkcyan", 0x008B8B);
        Reflect.setField(colors, "darkgoldenrod", 0xB8860B);
        Reflect.setField(colors, "darkgray", 0xA9A9A9);
        Reflect.setField(colors, "darkgrey", 0xA9A9A9);
        Reflect.setField(colors, "darkgreen", 0x006400);
        Reflect.setField(colors, "darkkhaki", 0xBDB76B);
        Reflect.setField(colors, "darkmagenta", 0x8B008B);
        Reflect.setField(colors, "darkolivegreen", 0x556B2F);
        Reflect.setField(colors, "darkorange", 0xFF8C00);
        Reflect.setField(colors, "darkorchid", 0x9932CC);
        Reflect.setField(colors, "darkred", 0x8B0000);
        Reflect.setField(colors, "darksalmon", 0xE9967A);
        Reflect.setField(colors, "darkseagreen", 0x8FBC8F);
        Reflect.setField(colors, "darkslateblue", 0x483D8B);
        Reflect.setField(colors, "darkslategray", 0x2F4F4F);
        Reflect.setField(colors, "darkslategrey", 0x2F4F4F);
        Reflect.setField(colors, "darkturquoise", 0x00CED1);
        Reflect.setField(colors, "darkviolet", 0x9400D3);
        Reflect.setField(colors, "deeppink", 0xFF1493);
        Reflect.setField(colors, "deepskyblue", 0x00BFFF);
        Reflect.setField(colors, "dimgray", 0x696969);
        Reflect.setField(colors, "dimgrey", 0x696969);
        Reflect.setField(colors, "dodgerblue", 0x1E90FF);
        Reflect.setField(colors, "firebrick", 0xB22222);
        Reflect.setField(colors, "floralwhite", 0xFFFAF0);
        Reflect.setField(colors, "forestgreen", 0x228B22);
        Reflect.setField(colors, "fuchsia", 0xFF00FF);
        Reflect.setField(colors, "gainsboro", 0xDCDCDC);
        Reflect.setField(colors, "ghostwhite", 0xF8F8FF);
        Reflect.setField(colors, "gold", 0xFFD700);
        Reflect.setField(colors, "goldenrod", 0xDAA520);
        Reflect.setField(colors, "gray", 0x808080);
        Reflect.setField(colors, "grey", 0x808080);
        Reflect.setField(colors, "green", 0x008000);
        Reflect.setField(colors, "greenyellow", 0xADFF2F);
        Reflect.setField(colors, "honeydew", 0xF0FFF0);
        Reflect.setField(colors, "hotpink", 0xFF69B4);
        Reflect.setField(colors, "indianred", 0xCD5C5C);
        Reflect.setField(colors, "indigo", 0x4B0082);
        Reflect.setField(colors, "ivory", 0xFFFFF0);
        Reflect.setField(colors, "khaki", 0xF0E68C);
        Reflect.setField(colors, "lavender", 0xE6E6FA);
        Reflect.setField(colors, "lavenderblush", 0xFFF0F5);
        Reflect.setField(colors, "lawngreen", 0x7CFC00);
        Reflect.setField(colors, "lemonchiffon", 0xFFFACD);
        Reflect.setField(colors, "lightblue", 0xADD8E6);
        Reflect.setField(colors, "lightcoral", 0xF08080);
        Reflect.setField(colors, "lightcyan", 0xE0FFFF);
        Reflect.setField(colors, "lightgoldenrodyellow", 0xFAFAD2);
        Reflect.setField(colors, "lightgray", 0xD3D3D3);
        Reflect.setField(colors, "lightgrey", 0xD3D3D3);
        Reflect.setField(colors, "lightgreen", 0x90EE90);
        Reflect.setField(colors, "lightpink", 0xFFB6C1);
        Reflect.setField(colors, "lightsalmon", 0xFFA07A);
        Reflect.setField(colors, "lightseagreen", 0x20B2AA);
        Reflect.setField(colors, "lightskyblue", 0x87CEFA);
        Reflect.setField(colors, "lightslategray", 0x778899);
        Reflect.setField(colors, "lightslategrey", 0x778899);
        Reflect.setField(colors, "lightsteelblue", 0xB0C4DE);
        Reflect.setField(colors, "lightyellow", 0xFFFFE0);
        Reflect.setField(colors, "lime", 0x00FF00);
        Reflect.setField(colors, "limegreen", 0x32CD32);
        Reflect.setField(colors, "linen", 0xFAF0E6);
        Reflect.setField(colors, "magenta", 0xFF00FF);
        Reflect.setField(colors, "maroon", 0x800000);
        Reflect.setField(colors, "mediumaquamarine", 0x66CDAA);
        Reflect.setField(colors, "mediumblue", 0x0000CD);
        Reflect.setField(colors, "mediumorchid", 0xBA55D3);
        Reflect.setField(colors, "mediumpurple", 0x9370D8);
        Reflect.setField(colors, "mediumseagreen", 0x3CB371);
        Reflect.setField(colors, "mediumslateblue", 0x7B68EE);
        Reflect.setField(colors, "mediumspringgreen", 0x00FA9A);
        Reflect.setField(colors, "mediumturquoise", 0x48D1CC);
        Reflect.setField(colors, "mediumvioletred", 0xC71585);
        Reflect.setField(colors, "midnightblue", 0x191970);
        Reflect.setField(colors, "mintcream", 0xF5FFFA);
        Reflect.setField(colors, "mistyrose", 0xFFE4E1);
        Reflect.setField(colors, "moccasin", 0xFFE4B5);
        Reflect.setField(colors, "navajowhite", 0xFFDEAD);
        Reflect.setField(colors, "navy", 0x000080);
        Reflect.setField(colors, "oldlace", 0xFDF5E6);
        Reflect.setField(colors, "olive", 0x808000);
        Reflect.setField(colors, "olivedrab", 0x6B8E23);
        Reflect.setField(colors, "orange", 0xFFA500);
        Reflect.setField(colors, "orangered", 0xFF4500);
        Reflect.setField(colors, "orchid", 0xDA70D6);
        Reflect.setField(colors, "palegoldenrod", 0xEEE8AA);
        Reflect.setField(colors, "palegreen", 0x98FB98);
        Reflect.setField(colors, "paleturquoise", 0xAFEEEE);
        Reflect.setField(colors, "palevioletred", 0xD87093);
        Reflect.setField(colors, "papayawhip", 0xFFEFD5);
        Reflect.setField(colors, "peachpuff", 0xFFDAB9);
        Reflect.setField(colors, "peru", 0xCD853F);
        Reflect.setField(colors, "pink", 0xFFC0CB);
        Reflect.setField(colors, "plum", 0xDDA0DD);
        Reflect.setField(colors, "powderblue", 0xB0E0E6);
        Reflect.setField(colors, "purple", 0x800080);
        Reflect.setField(colors, "red", 0xFF0000);
        Reflect.setField(colors, "rosybrown", 0xBC8F8F);
        Reflect.setField(colors, "royalblue", 0x4169E1);
        Reflect.setField(colors, "saddlebrown", 0x8B4513);
        Reflect.setField(colors, "salmon", 0xFA8072);
        Reflect.setField(colors, "sandybrown", 0xF4A460);
        Reflect.setField(colors, "seagreen", 0x2E8B57);
        Reflect.setField(colors, "seashell", 0xFFF5EE);
        Reflect.setField(colors, "sienna", 0xA0522D);
        Reflect.setField(colors, "silver", 0xC0C0C0);
        Reflect.setField(colors, "skyblue", 0x87CEEB);
        Reflect.setField(colors, "slateblue", 0x6A5ACD);
        Reflect.setField(colors, "slategray", 0x708090);
        Reflect.setField(colors, "slategrey", 0x708090);
        Reflect.setField(colors, "snow", 0xFFFAFA);
        Reflect.setField(colors, "springgreen", 0x00FF7F);
        Reflect.setField(colors, "steelblue", 0x4682B4);
        Reflect.setField(colors, "tan", 0xD2B48C);
        Reflect.setField(colors, "teal", 0x008080);
        Reflect.setField(colors, "thistle", 0xD8BFD8);
        Reflect.setField(colors, "tomato", 0xFF6347);
        Reflect.setField(colors, "turquoise", 0x40E0D0);
        Reflect.setField(colors, "violet", 0xEE82EE);
        Reflect.setField(colors, "wheat", 0xF5DEB3);
        Reflect.setField(colors, "white", 0xFFFFFF);
        Reflect.setField(colors, "whitesmoke", 0xF5F5F5);
        Reflect.setField(colors, "yellow", 0xFFFF00);
        Reflect.setField(colors, "yellowgreen", 0x9ACD32);
        true;
    }

}
