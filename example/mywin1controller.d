/+
d code generated with makegtkdclass. 
PLEASE DO "NOT" EDIT THIS FILE!
CREATE A DERIVED CLASS INSTEAD!
+/
module mywin1controller;

import app;

import core.stdc.stdlib;

import std.functional;
import std.experimental.logger;

import gtk.Builder, gtk.Widget, gdk.Event;
import gtk.ApplicationWindow;
import gtk.Box;
import gtk.Label;
import gtk.Entry;
import gtk.Button;


class Mywin1Controller: ApplicationWindow {
    Builder builder;
    
    Box vbox1;
    Label label1;
    Box hbox1;
    Label label2;
    Entry text1;
    Button button1;
    
    
    this(gtk.Application.Application application){
        
        builder = new Builder();

        import mywin1bytes: mywin1_bytearray;
        if(!builder.addFromString(cast(string)mywin1_bytearray)){
            critical("Window resource cannot be found!");
        }
        
        auto s = builder.getObject("mywindow1");
        auto win = cast(GtkApplicationWindow*)s.getObjectGStruct();
        super(win);
        this.setApplication(application);
        
        vbox1 = cast(Box)builder.getObject("vbox1");
        label1 = cast(Label)builder.getObject("label1");
        hbox1 = cast(Box)builder.getObject("hbox1");
        label2 = cast(Label)builder.getObject("label2");
        text1 = cast(Entry)builder.getObject("text1");
        button1 = cast(Button)builder.getObject("button1");
        

        button1.addOnClicked(toDelegate(&button1OnClicked));
        
        
        this.addOnDelete(delegate bool(Event e, Widget w) {
            exit(0);
            return true;
        });
    }

    void button1OnClicked(Button aux){
        // please override me in your derived class!
    }    


}
