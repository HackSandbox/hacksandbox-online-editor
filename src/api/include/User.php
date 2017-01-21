<?php
    class User {
        function __construct($app){
            $this->app = $app;
        }

        function create($email, $password){
            $result = "OK";
            if(filter_var($email, FILTER_VALIDATE_EMAIL)){
                $new_salt = $this->generateRandomString();
                $hashed_password = $this->hashPassword($password, $new_salt);
                $stmt = $this->app->db->prepare("INSERT INTO user (email_address, password, salt) VALUES (?,?,?)");
                $stmt->bind_param("sss", $email, $hashed_password, $new_salt);
                if($stmt->execute()){
                    $result = "OK";
                } else {
                    $result = "DB_FAIL";
                }
            } else {
                $result = "EMAIL_NOT_VALID";
            }
            return $result;
        }

        function hashPassword($password, $salt){
            $hashed_password = hash("sha512", $password . $salt);
            for($i = 0; $i < 999; $i++){
                $hashed_password = hash("sha512", $hashed_password . $salt);
            }
            return $hashed_password;
        }

        function generateRandomString($length = 10) {
            $chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
            $chars_length = strlen($chars);
            $rand_string = '';
            for ($i = 0; $i < $length; $i++) {
                $rand_string .= $chars[rand(0, $chars_length - 1)];
            }
            return $rand_string;
        }


    }

?>