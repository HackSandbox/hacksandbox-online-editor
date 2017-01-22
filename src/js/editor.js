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
                files:new_files
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
                if(data.data.is_owner){
                    $(".right-label").html("you are the owner of " + data.data.uuid.substring(0,5) + " <- <a href='#" + data.data.forked_from + "'>" + data.data.forked_from.substring(0,5) + "</a>");
                    $("#save-button").show();
                    $("#fork-button").hide();
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
                $("#fork-button").hide();
                self.deleteAllFiles();
                for (var key in data.data.files){
                    self.addTab(key);
                    self.codeEditorInstance.setValue(data.data.files[key]);
                }
                self.switchToTab(0);
                $(".right-label").html(data.data.uuid);
                self.uuid = data.data.uuid;
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