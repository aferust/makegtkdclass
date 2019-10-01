module gladeparser;

import std.stdio;
import std.file;
import std.exception;

import dxml.dom;

private {
    void checkAppWindow(DOMEntity!string root){
        bool isAppIdFound = false;
        bool isAppClassFound = false;
        
        foreach(i; 0..root.children.length){
            auto child = root.children[i];
            if(child.name == "object"){
                if(child.hasAttr("id"))
                    isAppIdFound = true;
                if (child.hasAttr("class")){
                    foreach(attr; child.attributes)
                        if((attr.value == "GtkApplicationWindow") || (attr.value == "GtkWindow"))
                            isAppClassFound = true;
                    
                }
            }
        }
        
        if((!isAppClassFound) || (!isAppIdFound))
            throw new Exception("root element must contain an object field with attributes of class and id.");
    }


    bool hasAttr(DOMEntity!string entity, string aname){
        if(entity.attributes.length == 0)
            return false;
        foreach(attr; entity.attributes){
            if(attr.name == aname ) return true;
        }
        return false;
    }
}

auto getWidgetObjects(string gstr){
    auto dom = parseDOM(gstr);
    
    DOMEntity!string iroot;

    foreach(i; 0 .. dom.children.length)
        if(dom.children[i].type != EntityType.comment)
            if(dom.children[i].name == "interface")
                iroot = dom.children[i];
    
    checkAppWindow(iroot);

    string[string][] objects;

    void parseObjects(DOMEntity!string root){
        try{
            if((root.type == EntityType.elementEmpty) || (root.type == EntityType.text)) return;
            foreach(i; 0 .. root.children.length){
                auto child = root.children[i];
                if((child.type == EntityType.elementEmpty) || (child.type == EntityType.text)) continue;
                if ((child.name == "object") && (child.hasAttr("id"))){
                    string id = "";
                    string cname = "";
                    foreach(attr; child.attributes){
                        if(attr.name == "id")
                            id = attr.value;
                        if(attr.name == "class")
                            cname = attr.value;
                    }
                    auto el = ["class": cname, "id": id];
                    el.writeln;
                    objects ~= el;
                }
                
                parseObjects(child);
            }
        } catch (Exception exc) {
            return;
        }
    }

    parseObjects(iroot);
    return objects;
}