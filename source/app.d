import std.stdio, std.file, std.path, std.format, std.conv;

import gladeparser;

string[string][] objects;
string gstr;

auto getByteStr(string gladeStr){
	import std.typecons;

    string arraystr; 
    arraystr ~= "[";
    arraystr ~= "\n";
    uint i = 0;
    foreach (dchar ch; gladeStr) {
        arraystr ~= to!string(cast(ubyte)ch);
        arraystr ~= ",";
        if ((i % 12 == 0) && (i != 0)) arraystr ~= "\n";
        i ++;
    }
    arraystr = arraystr[0..$-1];
    arraystr ~= "]";

    return tuple(arraystr, gladeStr.length);
}

string genByteStrModule(string gladeName){
	import mustache;
	import bytestrtemplate;

	alias Mustache = MustacheEngine!(string);
	Mustache ms;

	auto bytearrayStr_and_arrLen = getByteStr(gstr);
	string bytearrayStr = bytearrayStr_and_arrLen[0];
	ulong arrLen = bytearrayStr_and_arrLen[1];
	
    auto context = new Mustache.Context;
	context["gladeName"] = gladeName;
	context["bytearrayStr"] = bytearrayStr;
	context["arrLen"] = arrLen;

	return ms.renderString(bytestr_template, context);
}

bool isAppWindow(){
	if(objects[0]["class"] == "GtkApplicationWindow")
		return true;
	return false;
}

void genClass(string gladeFileName){
	import std.uni;

    import classtemplate;
	import mustache;

	alias Mustache = MustacheEngine!(string);
	Mustache ms;

    string a_gtk_import = "import gtk.%s;\n";
    string gtk_imports;

    foreach(ob; objects){
        auto cname = ob["class"][3..$];
        gtk_imports ~= format(a_gtk_import, cname);
    }
    
    string class_name = gladeFileName[0].toUpper.to!string ~ gladeFileName[1..$] ~ "Controller";

    string modNameAndimportApp = "module " ~ gladeFileName ~ "controller;";
	if(isAppWindow()) modNameAndimportApp ~= "\n\nimport app;";

	const string ApplicationWindow_or_Window = isAppWindow()?"ApplicationWindow":"Window";
	const string title_or_app = isAppWindow()?"gtk.Application.Application application":format("%s", class_name);
	const string setAppCtx = isAppWindow()?"this.setApplication(application);":"";
	
	const string templateDeclWidgets = "%s %s";
    const string templateImplWidgets = "%s = cast(%s)builder.getObject(\"%s\")";
	const string butOnClickedHandlerTempl = "%s.addOnClicked(toDelegate(&%sOnClicked))";
	const string butClickedFunctionTempl = "void %sOnClicked(%s aux){
        // please override me in your derived class!
    }";

	string declWidgets;
	string implWidgets;
	string butOnClickedHandlers = "";
	string butClickedFunctions = "";

	foreach(i; 1..objects.length){
		declWidgets ~= format(templateDeclWidgets, objects[i]["class"][3..$], objects[i]["id"]) ~ ";\n    ";
		implWidgets ~= format(templateImplWidgets, objects[i]["id"], objects[i]["class"][3..$], objects[i]["id"]) ~ ";\n        ";
		if(objects[i]["class"] == "GtkButton"){
			butOnClickedHandlers ~= format(butOnClickedHandlerTempl, objects[i]["id"], objects[i]["id"]) ~ ";\n        ";
			butClickedFunctions ~= format(butClickedFunctionTempl, objects[i]["id"], objects[i]["class"][3..$]) ~ "    \n\n";
		}
	}

	const exit_0 = isAppWindow()?"exit(0);":"";

	auto context = new Mustache.Context;
	context["windowID"] = objects[0]["id"];
	context["modNameAndimportApp"] = modNameAndimportApp;
	context["gtk_imports"] = gtk_imports;
	context["gladeName"] = gladeFileName;
	context["class_name"] = class_name;
	context["ApplicationWindow_or_Window"] = ApplicationWindow_or_Window;
	context["setAppCtx"] = setAppCtx;
	context["title_or_app"] = title_or_app;
	context["declWidgets"] = declWidgets;
	context["implWidgets"] = implWidgets;
	context["butOnClickedHandlers"] = butOnClickedHandlers;
	context["butClickedFunctions"] = butClickedFunctions;
	context["exit_0"] = exit_0;
	
	auto classStr = ms.renderString(class_template, context);
	classStr.toFile(folderName ~ dirSeparator ~ format("%scontroller.d", gladeFileName));
}

string folderName;

int main(string[] args){
	if(args.length < 2) {
		writefln("Please provide full name of your glade file like: %s /home/user/mygladefile.glade", args[0]);
		return -1;
	}

	const gldFileFullPath = args[1];
	const gladeName = baseName(stripExtension(gldFileFullPath));
	folderName = dirName(gldFileFullPath);
	
	gstr = readText(gldFileFullPath);

	auto bstrmod = genByteStrModule(gladeName);
	bstrmod.toFile(folderName ~ dirSeparator ~ format("%sbytes.d", gladeName));

	objects = getWidgetObjects(gstr);
	genClass(gladeName);

	return 0;
}
