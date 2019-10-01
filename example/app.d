module app;

import std.stdio;
import std.experimental.logger: trace;

import gio.Application : GApplication = Application;
import gtk.Main;
import gtk.Application;

import mywin1controller;

class GtkDApp : Application {

public:
    this(){   
        ApplicationFlags flags = ApplicationFlags.FLAGS_NONE;
        super("org.gnome.projectname", flags);
        this.addOnActivate(&onAppActivate);
        this.window = null;
    }

private:

    Mywin1Controller window;

    void onAppActivate(GApplication app){
        trace("Activate App Signal");
        if (!app.getIsRemote()){
            this.window = new Mywin1Controller(this);
        }

        this.window.present();
    }
}		
		
void main(string[] args) {
    Main.init(args);
    auto app = new GtkDApp();
    app.run(args);
}  