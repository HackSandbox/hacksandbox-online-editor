<!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <title>HackSandbox Editor</title>
        <link href="bootstrap-3.3.7-dist/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
        <link href="less/main.less?v=0002" type="text/less" rel="stylesheet" />
        <link href="https://ssl.jackzh.com/file/css/font-awesome-4.4.0/css/font-awesome.min.css" type="text/css" rel="stylesheet" />
        <script src="js/jquery-3.1.1.min.js"></script>
        <script src="js/processing.min.js"></script>
        <script src="bootstrap-3.3.7-dist/js/bootstrap.min.js"></script>
        <script src="https://ssl.jackzh.com/file/js/ace/ace-builds-1.2.2/src-min/ace.js"></script>
        <script src="https://ssl.jackzh.com/file/js/less-js/less.min.js"></script>
        <script src="https://unpkg.com/babel-standalone@6/babel.min.js"></script>
    </head>

    <body>
        <?php for ($i = 0; $i < 6; $i++){ ?>
            <div class="row">
            <?php for ($k = 0; $k < 6; $k++){ ?>
                <div id="showcase-<?php echo ($i*4) + ($k); ?>" class="col-md-2" style="position:relative;">
                    <canvas class="showcase-canvas" id="canvas-<?php echo ($i*6) + ($k); ?>" style="width:100%; height:100%; max-height:100%; max-width:100%; margin:20px;"><canvas>
                </div>
            <?php } ?>
            </div>
        <?php } ?>
    </body>

</html>
<script type="text/javascript">
    var jsCode = [];
    var processingInstances = [];
    $.ajax({
        url:"api/sketches",
        type:"GET",
        dataType:"json",
        success:function(data){
            for(i = 0; i < data.data.length; i++){
                var javaCode = "";
                for(key in data.data[i].files){
                    javaCode += data.data[i].files[key];
                }
                jsCode[jsCode.length] = Processing.compile(javaCode).sourceCode;
                var canvas = document.getElementById("canvas-" + i);
                processingInstances[processingInstances.length] = new Processing(canvas, eval(jsCode[jsCode.length - 1]));
                processingInstances[processingInstances.length - 1].noLoop();
            }

            console.log(jsCode);
        },
        error:function(e){
            console.log(e);
        }
    });
</script>