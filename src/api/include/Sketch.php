<?php
    class Sketch {
        function __construct($app){
            $this->app = $app;
        }

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

        function create(){
            $this->uuid = $this->gen_uuid();
            $file_list = array(
                "Main"=>file_get_contents("engine/default_main.pde"),
                "Engine"=>file_get_contents("engine/lib.pde")
            );
            $this->file_list = $file_list;
            $this->forked_from = "base";
            $stmt = $this->app->db->prepare("INSERT INTO sketches (uuid, files, forked_from, owner, title) VALUES (?,?,?,?,?)");
            $new_uuid = $this->uuid;
            $new_files = json_encode($this->file_list);
            $new_forked_from = "base";
            $new_title = "untitled hack";
            $this->title = $new_title;
            
            $new_owner = $this->owner;
            $stmt->bind_param("sssss", $new_uuid, $new_files, $new_forked_from, $new_owner, $new_title);
            if($stmt->execute()){
                $this->id = $stmt->insert_id;
                return true;
            } else {
                return false;
            }
        }

        function update($uuid, $files, $title){
            $stmt = $this->app->db->prepare("UPDATE sketches SET files=?, title=? WHERE uuid=?");
            $stmt->bind_param("sss", $files, $title, $uuid);
            if($stmt->execute()){
                return true;
            } else {
                return false;
            }
        }

        function fork($uuid, $owner){
            if($this->fetch($uuid)){
                $stmt = $this->app->db->prepare("INSERT INTO sketches (uuid, files, forked_from, owner, title) VALUES (?,?,?,?,?)");
                $new_uuid = $this->gen_uuid();
                $new_files = json_encode($this->file_list);
                $new_forked_from = $this->uuid;
                $new_owner = $owner;
                $new_title = "forked hack " . substr($this->forked_from, 0 , 5);
                $stmt->bind_param("sssss", $new_uuid, $new_files, $new_forked_from, $new_owner, $new_title);
                if($stmt->execute()){
                    $this->id = $stmt->insert_id;
                    $this->uuid = $new_uuid;
                    $this->owner = $owner;
                    $this->title = $new_title;
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }

        }

        function fetch($uuid){
            $stmt = $this->app->db->prepare("SELECT id, uuid, files, forked_from, owner, title FROM sketches WHERE uuid=?");
            $stmt->bind_param("s", $uuid);
            $stmt->execute();
            $stmt->store_result();
            if($stmt->num_rows == 0){
                return false;
            } else {
                $stmt->bind_result($result_id, $result_uuid, $result_files, $result_forked_from, $result_owner, $result_title);
                $stmt->fetch();
                $this->id = $result_id;
                $this->uuid = $result_uuid;
                $this->file_list = json_decode($result_files, true);
                $this->forked_from = $result_forked_from;
                $this->owner = $result_owner;
                $this->title = $result_title;
                return true;
            }
        }

        function fork_from(){

        }
    }


?>