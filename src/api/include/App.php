<?php
   /* Copyright Jun (Jack) Zheng All Rights Reserved.
    * Licenced under MIT
    */
    class ResponseStatus {
        public static $notFound      = 404;
        public static $ok            = 200;
        public static $internalError = 500;
        public static $notAuthorized = 401;
    }

    class App {
        public $router = null;
        // HTTP response body
        private $responseBody = array(
            "status"  => "not found",
            "message" => "",
            "data"    => null,
            "request_id" => ""
        );
        private $responseSent = false;

        public $db = null;

       /* __construct() -> App
        * Initialize app instance
        */
        function __construct(){
            $this->router = new Router($this);
        }


       /* get(string, function) -> null
        * Add a new get route to application.
        * Route expression format:
        * If referring to root directory, use "/"
        * If referring to sub directories, do not start and/or end with "/", for example "subdir/subsubdir"
        * If want to use variables, do this "subdir/%unknowndir/test/%anotherunknown"
        * Callback format:
        * Callback function must accept three parameters: arguments, router and app
        * Arguments are variables in route expression
        * Router is a router instance
        * App is this object
        */
        public function get($route, $callback){
            $this->router->get($route, $callback);
        }

       /* post(string, function) -> null
        * Add a new post route to application.
        * Route expression and callback format: refer to get method
        */
        public function post($route, $callback){
            $this->router->post($route, $callback);
        }

       /* put(string, function) -> null
        * Add a new put route to application.
        * Route expression and callback format: refer to get method
        */
        public function put($route, $callback){
            $this->router->put($route, $callback);
        }
       /* delete(string, function) -> null
        * Add a new delete route to application.
        * Route expression and callback format: refer to get method
        */
        public function delete($route, $callback){
            $this->router->delete($route, $callback);
        }

       /* setResponseStatus(\HaumeaFramework\ResponseStatus) -> App
        * Set HTTP response status code and message.
        * Return true if http response status is set, false otherwise.
        * Requirement: status must be valid, now only support 404, 200, 500 and 401
        */
        public function setResponseStatus($status){
            if ($status == ResponseStatus::$notFound) {
                \http_response_code(404);
                $this->responseBody["status"] = "not found";
            } else if ($status == ResponseStatus::$ok) {
                \http_response_code(200);
                $this->responseBody["status"] = "ok";
            } else if ($status == ResponseStatus::$internalError) {
                \http_response_code(500);
                $this->responseBody["status"] = "internal error";
            } else if ($status == ResponseStatus::$notAuthorized) {
                \http_response_code(401);
                $this->responseBody["status"] = "not authorized";
            } else {
                \http_response_code(200);
                $this->responseBody["status"] = "ok";
            }
            return $this;
        }

        /* setRspStat(\HaumeaFramework\ResponseStatus) -> App
         * Alias for setResponseStatus()
         */
        public function setRspStat($status){
            return $this->setResponseStatus($status);
        }

        /* setResponseMessage(string) -> App
         * Set HTTP response message.
         */
        public function setResponseMessage($message){
            $this->responseBody["message"] = $message;
            return $this;
        }

        /* setRspMsg(\HaumeaFramework\ResponseStatus) -> App
         * Alias for setResponseMessage()
         */
        public function setRspMsg($message){
            return $this->setResponseMessage($message);
        }

       /* setResponseData(object) -> App
        * Set HTTP response data.
        */
        public function setResponseData($data){
            $this->responseBody["data"] = $data;
            return $this;
        }

        public function setRspData($data){
            return $this->setResponseData($data);
        }

       /* respond() -> null
        * Send HTTP response. This method can only be called once.
        */
        public function respond(){
            if(!$this->responseSent){
                // Set content type to be json
                header('Content-type: application/json');
                echo \json_encode($this->responseBody, \JSON_PRETTY_PRINT);
                $this->responseSent = true;
            }
        }

        /* initDatabase(string, string, string, string) -> boolean
         * Initialize database connection.
         */
        public function initDatabase($host, $username, $password, $name){
            $result = true;
            $this->db = new \MySQLi($host, $username, $password, $name);
            if($this->db->errno){
                $result = false;
            }
            return $result;
        }

        public function initRequest(){
            $this->request = new Request($this);
            $this->responseBody["request_id"] = $this->request->identifier;
        }

    }
?>
