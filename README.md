# makegtkdclass

A small utility for lazily generating gtkd window classes from glade files. It is inspired by wxFormBuilder.

```
./makegtkdclass mywin1.glade
```

## Dependencies
-[dxml](https://github.com/jmdavis/dxml)
-[mustache-d](https://github.com/repeatedly/mustache-d)

## A use case:
- Your glade file must contain only one root widget.
- Your root widget must be either of GtkWindow or GtkApplicationWindow with an assigned id field.
- Only the widgets having an id field will be recursively parsed and put into the controller class.
- I do neither like to use resource compiler of gtk nor like to embed glade strings into the code since they can be easily read in executables and things become more vulnerable. So, glade strings are converted to byte arrays, and are then casted to string during runtime here.
- At the end of the conversion you will get two d source files in the same folder as your glade file. One contains a controller class, the other contains a ubyte array that coded your glade string.
- Note that result of the class generation will be different depending on the root widget (GtkWindow or GtkApplicationWindow).
- If the root widget of your glade file is of GtkApplicationWindow, you can import the generated controller module and use it in your main like:

```
module app;

import std.stdio;
import std.experimental.logger: trace;

import gio.Application : GApplication = Application;
import gtk.Main;
import gtk.Application;

import mywin1controller; // your generated module.

class GtkDApp : Application {

public:
    this(){   
        ApplicationFlags flags = ApplicationFlags.FLAGS_NONE;
        super("org.gnome.projectname", flags);
        this.addOnActivate(&onAppActivate);
        this.window = null;
    }

private:

    Mywin1Controller window; // your generated class.

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
```

Please refer to the example folder to see the resulting files of an example conversion process.
