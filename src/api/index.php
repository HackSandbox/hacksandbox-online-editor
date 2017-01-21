<?php
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
    require_once "include/App.php";
    require_once "include/Router.php";
    require_once "include/User.php";
    require_once "include/Sketch.php";
    $app = new App();
    if(!$app->initDatabase(
        "localhost",
        "root",
        "",
        "build_a_game"
    )){
        $app->setResponseStatus(500)
            ->setResponseMessage("Fatal error, cannot connect to database")
            ->respond();
        die();
    }
    
    // Default get request
    $app->get("/", function($args, $router, $app){
        $app->setRspStat(200)
            ->setRspMsg("Welcome to Gold Hack API")
            ->respond();
    });

    $app->post("users", function($args, $router, $app){
        $user = new User($app);
        $body = $app->router->getRequestBody();
        $result = $user->create($body["email"], $body["password"]);
        if($result === "OK"){
            $app->setRspStat(200)
                ->setRspMsg("ok")
                ->respond();
        } else if($result === "EMAIL_NOT_VALID"){
            $app->setRspStat(500)
                ->setRspMsg("email not valid")
                ->respond();
        } else {
            $app->setRspStat(500)
                ->setRspMsg("error")
                ->respond();
        }
    });

    $app->post("sketches", function($args, $router, $app){
        $sketch = new Sketch($app);
        $sketch->owner = $router->getRequestHeaders()["client-id"];
        if($sketch->create()){
            $app->setRspStat(200)
                ->setRspMsg("ok")
                ->setRspData(array(
                    "id"=>$sketch->id,
                    "uuid"=>$sketch->uuid,
                    "files"=>$sketch->file_list,
                    "forked_from"=>$sketch->forked_from,
                    "owner"=>$sketch->owner
                ))
                ->respond();
        } else {
            $app->setRspStat(500)
                ->setRspMsg("failed to create sketch")
                ->respond();
        }
    });

    $app->put("sketches/%uuid", function($args, $router, $app){
        $sketch = new Sketch($app);
        $sketch->owner = $router->getRequestHeaders()["client-id"];
        $new_files = json_encode($app->router->getRequestBody()['files']);
        if($sketch->update($args["uuid"], $new_files)){
            $app->setRspStat(200)
                ->setRspMsg("ok")
                ->respond();
        } else {
            $app->setRspStat(500)
                ->setRspMsg("failed to update sketch")
                ->respond();
        }
    });

    $app->get("sketches/%uuid", function($args, $router, $app){
        $sketch = new Sketch($app);
        $sketch->owner = $router->getRequestHeaders()["client-id"];
        if($sketch->fetch($args["uuid"])){
            $app->setRspStat(200)
                ->setRspMsg("ok")
                ->setRspData(array(
                    "id"=>$sketch->id,
                    "uuid"=>$sketch->uuid,
                    "files"=>$sketch->file_list,
                    "forked_from"=>$sketch->forked_from
                ))
                ->respond();
        } else {
            $app->setRspStat(404)
                ->setRspMsg("sketch not found")
                ->respond();
        }
    });

    $app->router->route();
?>