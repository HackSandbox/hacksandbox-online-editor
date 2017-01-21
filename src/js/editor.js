class HackSandBoxEditor {

    constructor(){
        this.consoleContainer = $("#console-container");
        this.leftContainer = $(".left-container");
        this.rightContainer = $(".right-container");
        this.codeEditor = $("#code-editor");
        this.codeEditorInstance = ace.edit("code-editor");
        this.codeEditorInstance.setTheme("ace/theme/monokai");
        this.codeEditorInstance.getSession().setMode("ace/mode/java");
        this.javaCode = [];
        this.libCode = null;
        this.jsCode = "";
        this.processingInstance = null;
        this.sketchStopped = true;
        this.loadLibCode();
        this.currentTab = 0;
        this.tabNames = [];
        this.addTab("Main");
        this.updateCode();
    }

    loadLibCode(){
        var self = this;
        $.ajax({
            url:"engine/lib.pde",
            type:"GET",
            success:function(data){
                self.libCode = data;
            }
        });
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
            for (i=0; i < Processing.instances.length; (i++)) {
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
    }

    switchToStopState(){
        this.processingInstance.noLoop();
        this.sketchStopped = true;
        $("#stop-button").addClass("disable");
        $("#control-bar").removeClass("running");
        $("#control-bar .left-label").html("STOP");
    }

    switchToErrorState(){
        this.switchToStopState();
        $("#control-bar").addClass("error");
        $("#control-bar .left-label").html("ERROR");
    }

    // Update code stored in memory
    updateCode(){
        this.javaCode[this.currentTab] = this.codeEditorInstance.getValue();
        console.log(this.javaCode[this.currentTab]);
    }

    resize(){
        $(this.consoleContainer).height(160);
        $(this.consoleContainer).width($(this.leftContainer).width() + 18);
        $(this.leftContainer).height(window.innerHeight - 50);
        $(this.rightContainer).height(window.innerHeight - 50);
        $(this.codeEditor).height(window.innerHeight - 280);
    }
}

var editor;

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
        editor.addTab(prompt("Enter a name: "));
    });

    var loadAwait = setInterval(function(){
        if(editor.libCode != null){
            editor.addTab("Engine");
            editor.codeEditorInstance.setValue(editor.libCode);
            editor.switchToTab(0);
            $("#full-screen-loading").fadeOut();
            clearInterval(loadAwait);
        }
    }, 100);
});