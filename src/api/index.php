<?php
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
    //phpinfo();
    //require_once "include/system_check/base64.php";
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
            ->setRspMsg("Welcome to HackSandbox API")
            ->respond();
    });

    // Helper function to generate a v4 UUID
    function gen_uuid() {
      return sprintf( '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        // 32 bits for "time_low"
        mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ),
        // 16 bits for "time_mid"
        mt_rand( 0, 0xffff ),
        // 16 bits for "time_hi_and_version",
        // four most significant bits holds version number 4
        mt_rand( 0, 0x0fff ) | 0x4000,
        // 16 bits, 8 bits for "clk_seq_hi_res",
        // 8 bits for "clk_seq_low",
        // two most significant bits holds zero and one for variant DCE1.1
        mt_rand( 0, 0x3fff ) | 0x8000,
        // 48 bits for "node"
        mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff )
      );
    }

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
                    "title"=>$sketch->title
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
        $body = $app->router->getRequestBody();
        $new_files = json_encode($body["files"]);
        if($sketch->update($args["uuid"], $new_files, $body['title'])){
            $app->setRspStat(200)
                ->setRspMsg("ok")
                ->respond();
        } else {
            $app->setRspStat(500)
                ->setRspMsg("failed to update sketch")
                ->respond();
        }
    });

    $app->get("sketches", function($args, $router, $app){
        $stmt = $app->db->prepare("SELECT uuid FROM sketches WHERE thumbnail_base64 IS NOT NULL ORDER BY id DESC LIMIT 36");
        $stmt->execute();
        $stmt->store_result();
        $stmt->bind_result($result_uuid);
        $result = array();
        while($stmt->fetch()){
            $sketch = new Sketch($app);
            $sketch->fetch($result_uuid);
            array_push($result, array(
                "id"=>$sketch->id,
                "uuid"=>$sketch->uuid,
                "files"=>$sketch->file_list,
                "forked_from"=>$sketch->forked_from,
                "title"=>$sketch->title,
                "thumbnail"=>$sketch->thumbnail
            ));
        }
        $app->setRspStat(200)
            ->setRspMsg("ok")
            ->setRspData($result)
            ->respond();
    });

    $app->post("sketches/%uuid/thumbnail", function($args, $router, $app){
        $stmt = $app->db->prepare("UPDATE sketches SET thumbnail_base64=? WHERE uuid=?");
        $thumbnail = $app->router->getRequestBody()["thumbnail"];
        $uuid = $args["uuid"];
        $stmt->bind_param("ss", $thumbnail, $uuid);
        if($stmt->execute()){
            $app->setRspStat(200)
                ->setRspMsg("ok")
                ->respond();
        } else {
            $app->setRspStat(500)
                ->setRspMsg("failed to upload image")
                ->respond();
        }
    });

    $app->get("sketches/%uuid/thumbnail", function($args, $router, $app){
        $stmt = $app->db->prepare("SELECT thumbnail_base64 FROM sketches WHERE uuid=?");
        $uuid = $args["uuid"];
        $stmt->bind_param("s", $uuid);
        if($stmt->execute()){
            $stmt->store_result();
            $stmt->bind_result($result_thumbnail);
            $stmt->fetch();
            $app->setRspStat(200)
                ->setRspMsg("ok")
                ->setRspData($result_thumbnail)
                ->respond();
        } else {
            $app->setRspStat(500)
                ->setRspMsg("failed to upload image")
                ->respond();
        }
    });

    $app->post("sketches/%uuid", function($args, $router, $app){
        $sketch = new Sketch($app);
        $sketch->owner = $router->getRequestHeaders()["client-id"];
        if($sketch->fork($args["uuid"],$router->getRequestHeaders()["client-id"])){
            $app->setRspStat(200)
                ->setRspMsg("ok")
                ->setRspData(array(
                    "id"=>$sketch->id,
                    "uuid"=>$sketch->uuid,
                    "files"=>$sketch->file_list,
                    "forked_from"=>$sketch->forked_from,
                    "title"=>$sketch->title
                ))
                ->respond();
        } else {
            $app->setRspStat(500)
                ->setRspMsg("failed to fork sketch")
                ->respond();
        }
    });

    $app->get("sketches/%uuid", function($args, $router, $app){
        $sketch = new Sketch($app);
        //$sketch->owner = $router->getRequestHeaders()["client-id"];
        
        if($sketch->fetch($args["uuid"])){
            if($sketch->owner === $router->getRequestHeaders()["client-id"]){
                $is_owner = true;
            } else {
                $is_owner = false;
            }
            $app->setRspStat(200)
                ->setRspMsg("ok")
                ->setRspData(array(
                    "id"=>$sketch->id,
                    "uuid"=>$sketch->uuid,
                    "files"=>$sketch->file_list,
                    "forked_from"=>$sketch->forked_from,
                    "is_owner"=>$is_owner,
                    "title"=>$sketch->title
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