<?php
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
    require_once "include/App.php";
    require_once "include/Router.php";
    require_once "include/User.php";
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

    $app->router->route();
?>