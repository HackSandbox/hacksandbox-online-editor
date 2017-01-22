class HackSandBoxEditor {

    constructor(){
        if(this.getCookie("client-id") != ""){
            this.clientId = this.getCookie("client-id");
        } else {
            this.clientId = this.genUuid();
            this.setCookie("client-id", this.clientId, 356);
        }
        this.consoleContainer = $("#console-container");
        this.leftContainer = $(".left-container");
        this.rightContainer = $(".right-container");
        this.codeEditor = $("#code-editor");
        this.codeEditorInstance = ace.edit("code-editor");
        this.codeEditorInstance.setTheme("ace/theme/monokai");
        this.codeEditorInstance.getSession().setMode("ace/mode/java");
        this.javaCode = [];
        //this.libCode = null;
        this.jsCode = "";
        this.processingInstance = null;
        this.sketchStopped = true;
        //this.loadLibCode();
        this.currentTab = 0;
        this.tabNames = [];
        this.addTab();
        this.updateCode();
    }

    genUuid(){
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
            return v.toString(16);
        });
    }

    getCookie(cname) {
        var name = cname + "=";
        var decodedCookie = decodeURIComponent(document.cookie);
        var ca = decodedCookie.split(';');
        for(var i = 0; i <ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
            }
        }
        return "";
    }

    setCookie(cname, cvalue, exdays) {
        var d = new Date();
        d.setTime(d.getTime() + (exdays*24*60*60*1000));
        var expires = "expires="+ d.toUTCString();
        document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
    }

    saveSketch(callback){
        var self = this;
        var callback = callback;
        var new_files = {};
        for (var i = 0; i < this.tabNames.length; i++){
            new_files[this.tabNames[i]] = this.javaCode[i];
        }
        $.ajax({
            url:"api/sketches/" + this.uuid,
            type:"PUT",
            dataType:"json",
            data:{
                files:new_files,
                title:$("#sketch-title-textbox").val()
            },
            headers:{
                "client-id":this.clientId
            },
            success:function(data){
                console.log(data);
                callback(data);
            },
            error:function(data){
                console.log(data);
                callback(false);
            }
        });
    }

    forkSketch(callback){
        var self = this;
        var callback = callback;
        $.ajax({
            url:"api/sketches/" + this.uuid,
            type:"POST",
            dataType:"json",
            headers:{
                "client-id":this.clientId
            },
            success:function(data){
                console.log(data);
                callback(data);
            },
            error:function(data){
                console.log(data);
                callback(false);
            }
        });
    }

    switchSketch(uuid, callback){
        var callback = callback;
        var self = this;
        $.ajax({
            url:"api/sketches/" + uuid,
            type:"GET",
            dataType:"json",
            headers:{
                "client-id":this.clientId
            },
            success:function(data){
                self.deleteAllFiles();
                for (var key in data.data.files){
                    self.addTab(key);
                    self.codeEditorInstance.setValue(data.data.files[key]);
                }
                self.switchToTab(0);
                window.location.hash = data.data.uuid;
                self.uuid = data.data.uuid;
                $("#sketch-title-textbox").val(data.data.title);
                if(data.data.is_owner){
                    $(".right-label").html("you are the owner of " + data.data.uuid.substring(0,5) + " <- <a href='#" + data.data.forked_from + "'>" + data.data.forked_from.substring(0,5) + "</a>");
                    $("#save-button").show();
                    //$("#fork-button").hide();
                    $(".right-container").removeClass("expanded");
                } else {
                    $(".right-label").html("you are viewing <span class='glyphicon glyphicon-lock'></span> " + data.data.uuid.substring(0,5) + " <- <a href='#" + data.data.forked_from + "'>" + data.data.forked_from.substring(0,5) + "</a>");
                    $("#save-button").hide();
                    $("#fork-button").show();
                    self.compile();
                    self.switchToRunningState();
                    $(".right-container").addClass("expanded");
                }
                callback(data);
            },
            error:function(data){
                callback(false);
            }
        })
    }

    createSketch(callback){
        var callback = callback;
        var self = this;
        $.ajax({
            url:"api/sketches",
            type:"POST",
            dataType:"json",
            headers:{
                "client-id":this.clientId
            },
            success:function(data){
                console.log(data);
                $("#save-button").show();
                //$("#fork-button").hide();
                self.deleteAllFiles();
                for (var key in data.data.files){
                    self.addTab(key);
                    self.codeEditorInstance.setValue(data.data.files[key]);
                }
                self.switchToTab(0);
                $(".right-label").html(data.data.uuid);
                self.uuid = data.data.uuid;
                $("#sketch-title-textbox").val(data.data.title);
                window.location.hash = data.data.uuid;
                callback(data);
            },
            error:function(data){
                console.log(data);
                callback(false);
            }
        })
    }

    addTab(name){
        if(this.tabNames.includes(name)){
            alert("Name already exists!");
        } else {
            var new_id = this.tabNames.length;
            this.tabNames[new_id] = name;
            this.javaCode[new_id] = "// " + name;
            $(".editor-tabs-container ul").append("<li id='tab-indicator-" + new_id + "'><span class=\"glyphicon glyphicon-file\"></span> " + name + "</li>");
            var self = this;
            $("#tab-indicator-" + new_id).click(function(){
                self.switchToTab(new_id);
            });
            
            this.switchToTab(new_id);    
        }
    }

    deleteAllFiles(name){
        this.tabNames = [];
        this.javaCode = [];
        $(".editor-tabs-container ul").html("");
    }

    switchToTab(id){
        print(id);
        for(var i = 0; i < this.tabNames.length; i++){
            $("#tab-indicator-" + i).removeClass("active");
            if(i == id){
                $("#tab-indicator-" + i).addClass("active");
            }
        }
        this.currentTab = id;
        this.codeEditorInstance.setValue(this.javaCode[id], -1);
    }

    compile(){
        var javaCode = "";
        for(var i = 0; i < this.javaCode.length; i++){
            javaCode += this.javaCode[i];
        }
        this.jsCode = Processing.compile(javaCode).sourceCode;
    }

    switchToRunningState(){
        // Clean up previous session
        if (Processing.instances.length > 0) {
            for (var i = 0; i < Processing.instances.length; (i++)) {
              Processing.instances[i].exit();
            }
        }
        var canvas = document.getElementById("render-canvas");
        var context = canvas.getContext('2d');
        context.setTransform(1, 0, 0, 1, 0, 0);
        context.clearRect(0, 0, canvas.width, canvas.height);
        if(this.processingInstance != null){
            this.processingInstance.exit();
        }
        // Bind new processing process
        this.processingInstance = new Processing(canvas, eval(this.jsCode));
        this.processingInstance.print = window.print;
        // Element visual switch
        this.sketchStopped = false;
        $("#stop-button").removeClass("disable");
        $("#control-bar").addClass("running");
        $("#control-bar").removeClass("error");
        $("#control-bar .left-label").html("RUNNING");
        var self = this;
        setTimeout(function(){
            self.captureCanvas();
        },1000);
    }

    switchToStopState(){
        this.processingInstance.noLoop();
        this.sketchStopped = true;
        $("#stop-button").addClass("disable");
        $("#control-bar").removeClass("running");
        $("#control-bar .left-label").html("STANDBY");
    }

    switchToErrorState(){
        this.switchToStopState();
        $("#control-bar").addClass("error");
        $("#control-bar .left-label").html("ERROR");
    }

    // Update code stored in memory
    updateCode(){
        this.javaCode[this.currentTab] = this.codeEditorInstance.getValue();
        //console.log(this.javaCode[this.currentTab]);
    }

    resize(){
        $(this.consoleContainer).height(160);
        $(this.consoleContainer).width($(this.leftContainer).width() + 18);
        $(this.leftContainer).height(window.innerHeight - 50);
        $(this.rightContainer).height(window.innerHeight - 50);
        $(this.codeEditor).height(window.innerHeight - 280);
    }

    expandInfoPanel(){
        $("#app-container").animate({'top':200});
        $("#info-drop-down").animate({'top':0});
    }

    compressInfoPanel(){
        $("#app-container").animate({'top':0});
        $("#info-drop-down").animate({'top':-200});
    }

    closeTut(){ 
        $("#tutorial-popup").animate({'height':0}); 
    } 
 
    openTut(){ 
        $("#tutorial-popup").animate({'height':200}); 
    }

    captureCanvas(){
        var canvas = document.getElementById("render-canvas");
        var img    = canvas.toDataURL("image/png");
        $.ajax({
            url:"api/sketches/" + this.uuid + "/thumbnail",
            type:"POST",
            data:{
                "thumbnail":img
            },
            dataType:"json",
            success:function(data){
                print("thumbnail captured");
            },
            error:function(data){
                console.log(data);
            }
        })
    }
}

var editor;

var tut_content = [ 
    "Click the Next Step button to start learning and continue once you understand the code in the editor after pressing the button.", 
    "The setup function creates a window for you to use, calling the size function edits the size of the window, and creating a Container object makes a container for in-game items.", 
    "The 'void setup()' is the method signature. The 'void' means that the method does not return any value when called, the 'setup' is the name, and '()' means the method has no parameters.", 
    "A function is called by writing its name, like 'size', and then giving arguments to its parameters in brackets.  An object is made by writing a name for it, the 'mainContainer' and then '= new Container' with the 'Container' being the type of the Container object.", 
    "The draw function is responsible for adding a background to the container. It sets a background colour, updates all of the objects in the container, and draws all of the objects in the container.", 
    "Everything created outside the bounds of a function becomes Global. This means that this object can be used in any function in the file, like the created backgroundImage. In the setup function, now the backgroundImage is given a value and added to the main container.", 
    "An actor object can also be added, given an image, have its position set, added to the container. This actor object is now available for you to modify. This can be done by calling its attributes (here the position variables x and y). When creating an Actor object, it needs certain parameters like (50, 50) which are its size in this case.", 
    "More methods can be created to use the actor with mouse and key presses. The methods are able to check what key or mouse button is pressed and allow you to take appropriate action. The monitoring for input and the key and mouseButton variables are from the standard input library that you can look at in the API from the sandbox, and will likely be the same for all your games.", 
    "The setup method can further be expanded to include obstacle objects for our main actor, being initialized just like the actor. The actor this time is a row of walls to which walls are added to as they are initialized as rectangles.", 
    "You've now learned the basics of creating your own game here! Look at other people's games' code and create your own in the Sandbox Creator." 
]; 
var current_tut_page = -1; 
 
function nextTut(){ 
    if(current_tut_page != tut_content.length - 1){ 
        current_tut_page++; 
        $("#tut-content-container").html(tut_content[current_tut_page]); 
    } 
} 
 
function prevTut(){ 
    if(current_tut_page > 0){ 
        current_tut_page--; 
        $("#tut-content-container").html(tut_content[current_tut_page]); 
    } 
}

$(function(){
    editor = new HackSandBoxEditor();
    editor.resize();
    var editor = editor;
    window.onresize = function(){
        editor.resize();
    }
    editor.codeEditorInstance.getSession().on('change',function(){
        editor.updateCode();
    });

    $("#compile-button").click(function(){
        editor.compile();
        editor.switchToRunningState();
    });

    $("#stop-button").click(function(){
        editor.switchToStopState();
    });

    window.onerror = function (errorMsg, url, lineNumber) {
        $("#runtime-exception-window").removeClass("not_visible");
        $("#runtime-exception-window .panel-body").html(errorMsg);
        $("#global-shade").fadeIn();
        editor.switchToErrorState();
        print("<span style='color:red;'>Exception raised. Please check your code.</span>");
        return false;
    }

    $("#global-shade").click(function(){
        $("#runtime-exception-window").addClass("not_visible");
        $("#global-shade").fadeOut();
    });

    $("#add-tab-button").click(function(){
        var result = prompt("Enter a name: ");
        if(result){
            editor.addTab(result);
        }
    });

    $("#save-button").click(function(){
        editor.saveSketch(function(result){
            if(result){
                print("Project saved");
            } else {
                print("failed to save.");
            }
        });
    });

    $("#fork-button").click(function(){
        $("#full-screen-loading").fadeIn();
        editor.forkSketch(function(result){
            if(result){
                editor.switchSketch(result.data.uuid, function(data){
                    $("#full-screen-loading").fadeOut();
                });
            } else {
                print("Failed to fork sketch");
                $("#full-screen-loading").fadeOut();
            }
        });
    });


    $("#hack-your-own-copy").click(function(){
        $("#full-screen-loading").fadeIn();
        editor.forkSketch(function(result){
            if(result){
                editor.switchSketch(result.data.uuid, function(data){
                    $("#full-screen-loading").fadeOut();
                });
            } else {
                print("Failed to fork sketch");
                $("#full-screen-loading").fadeOut();
            }
        });
    });

    $("#expand-button").click(function(){
        editor.expandInfoPanel();
        $(this).hide();
        $("#compress-button").show();
    });


    $("#compress-button").click(function(){
        editor.compressInfoPanel();
        $(this).hide();
        $("#expand-button").show();
    });

    $("#new-button").click(function(){
        window.location.hash = "new";
    });
    
    $("#prev-tut-button").click(function(){ 
        prevTut(); 
    }); 
 
    $("#next-tut-button").click(function(){ 
        nextTut(); 
    }); 
 
    $("#close-tut").click(function(){ 
        editor.closeTut(); 
    }); 
 
    nextTut(); 
     

    function switchSketch(){
        editor.switchSketch(window.location.href.split('#')[1], function(result){
            //console.log(window.location.href.split('#')[1]);
            if(!result){
                editor.createSketch(function(result){
                    //console.log(result);
                });
                $("#full-screen-loading").fadeOut();
            } else {
                console.log(result);
                $("#full-screen-loading").fadeOut();
            }
        });
    }

    switchSketch();

    window.onhashchange = function(){
        switchSketch();
    }
    $.ajax({
        url:'api/sketches',
        type:"GET",
        dataType:"json",
        success:function(data){
            console.log(data);
            for(var i = 0; i < data.data.length; i++){
                $(".showcase-row").append("<a href='#" + data.data[i].uuid + "'><div class=\"showcase-block\"><img src='" + data.data[i]['thumbnail'] + "' /></div></a>");
                $(".showcase-block").click(function(){
                    $("#home-splash").fadeOut();
                });  
            }
        }
    });

    $('[data-toggle="tooltip"]').tooltip();
    
    function getBase64(file, callback) {
        var reader = new FileReader();
        reader.readAsDataURL(file);
        var callback = callback;
        reader.onload = function () {
            callback(reader.result);
        };
        reader.onerror = function (error) {
            callback(false);
        };
    }

    var isAdvancedUpload = function() {
        var div = document.createElement('div');
        return (('draggable' in div) || ('ondragstart' in div && 'ondrop' in div)) && 'FormData' in window && 'FileReader' in window;
    }();
    var $form = $('.box');

    if (isAdvancedUpload) {
        $form.addClass('has-advanced-upload');
        $form.on('drag dragstart dragend dragover dragenter dragleave drop', function(e) {
            e.preventDefault();
            e.stopPropagation();
        })
        .on('dragover dragenter', function() {
            $form.addClass('is-dragover');
        })
        .on('dragleave dragend drop', function() {
            $form.removeClass('is-dragover');
        })
        .on('drop', function(e) {
            var droppedFiles = e.originalEvent.dataTransfer.files;
            console.log(getBase64(droppedFiles[0]));
            getBase64(droppedFiles[0], function(data){
                if(data){
                    $.ajax({
                        url:"api/images_base64",
                        type:"POST",
                        data:{
                            img_file:data
                        },
                        dataType:"json",
                        success:function(data){
                            console.log(data);
                        },
                        error:function(data){
                            console.log(data);
                        }
                    });
                } else {
                    // Error handling
                }
            });
            
        });
    }
});