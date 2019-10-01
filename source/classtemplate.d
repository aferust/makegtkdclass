module classtemplate;

__gshared const string class_template = "/+
d code generated with makegtkdclass. 
PLEASE DO \"NOT\" EDIT THIS FILE!
CREATE A DERIVED CLASS INSTEAD!
+/
{{modNameAndimportApp}}

import core.stdc.stdlib;

import std.functional;
import std.experimental.logger;

import gtk.Builder, gtk.Widget, gdk.Event;
{{gtk_imports}}

class {{class_name}}: {{ApplicationWindow_or_Window}} {
    Builder builder;
    
    {{declWidgets}}
    
    this({{title_or_app}}){
        
        builder = new Builder();

        import {{gladeName}}bytes: {{gladeName}}_bytearray;
        if(!builder.addFromString(cast(string){{gladeName}}_bytearray)){
            critical(\"Window resource cannot be found!\");
        }
        
        auto s = builder.getObject(\"{{windowID}}\");
        auto win = cast(Gtk{{ApplicationWindow_or_Window}}*)s.getObjectGStruct();
        super(win);
        {{setAppCtx}}
        
        {{{implWidgets}}}

        {{{butOnClickedHandlers}}}
        
        this.addOnDelete(delegate bool(Event e, Widget w) {
            {{exit_0}}
            return true;
        });
    }

    {{butClickedFunctions}}
}
";