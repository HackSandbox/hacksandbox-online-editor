<?php
   /* Copyright Jun (Jack) Zheng All Rights Reserved.
    * Licenced under MIT
    */

    class Router {
        private $routes = array(
            "GET"=>array(),
            "POST"=>array(),
            "PUT"=>array(),
            "GET"=>array()
        );
       /* __construct() -> Router
        * Initialize router instance
        */
        function __construct($app){
            $this->app = $app;
        }

        /* getRequestPath() -> string
         * Get current request path, for example:
         * http://localhost/haumea_framework/test/something/user
         * Will return
         * something/user
         */
        public function getRequestPath(){
            $request_uri = explode('/', trim($_SERVER['REQUEST_URI'], '/'));
            $script_name = explode('/', trim($_SERVER['SCRIPT_NAME'], '/'));
            $parts = array_diff_assoc($request_uri, $script_name);
            if (empty($parts))
            {
                return '/';
            }
            $path = implode('/', $parts);
            if (($position = strpos($path, '?')) !== FALSE)
            {
                $path = substr($path, 0, $position);
            }
            return $path;
        }

        /* getRequestMethod() -> string
         * Get current request method, or http verb
         */
        public function getRequestMethod(){
            return $_SERVER['REQUEST_METHOD'];
        }

        /* getRequestHeaders() -> array of string
         * Get request headers, returns an array of string containing all request headers
         */
        public function getRequestHeaders(){
            return getallheaders();
        }

        /* getRequestBody() -> array of string
         * Get request body, or raw payload.
         */
        public function getRequestBody(){
            if(empty($this->requestBody)){
                parse_str(file_get_contents("php://input"),$body);
                $this->requestBody = $body;
            }
            return $this->requestBody;
        }

        /* get(string, function) -> null
         * Add a new get route to application.
         * Route expression and callback format: refer to app->get method
         */
        public function get($path,$callback){
            $this->routes["GET"][$path] = $callback;
        }

        /* post(string, function) -> null
         * Add a new post route to application.
         * Route expression and callback format: refer to app->get method
         */
        public function post($path,$callback){
            $this->routes["POST"][$path] = $callback;
        }

        /* put(string, function) -> null
         * Add a new put route to application.
         * Route expression and callback format: refer to app->get method
         */
        public function put($path,$callback){
            $this->routes["PUT"][$path] = $callback;
        }

        /* delete(string, function) -> null
         * Add a new delete route to application.
         * Route expression and callback format: refer to app->get method
         */
        public function delete($path,$callback){
            $this->routes["DELETE"][$path] = $callback;
        }

        /* routeExists(array of routes, string) -> false or array
         * Takes in an array of routes, and a path string
         * Check if a route exists, if a route exist return array(path expression, arguments parsed from path)
         * If route does not exist, return false
         */
        public static function routeExists($arr,$path){
            foreach($arr as $k=>$v){
                $routeArgs = self::matchPath($k,$path);
                if($routeArgs){
                    return array($k,$routeArgs[1]);
                }
            }
            return false;
        }

        /* matchPath(string, string) -> false or array
         * Takes in a route expression and a path string, return array(1, arguments parsed from path) if match
         * If they does not match, return false
         */
        public static function matchPath($exp,$path){
            $exp = explode("/",$exp);
            $path = explode("/",$path);
            $variables = array();
            if(count($exp) == count($path)){
                for ($i = 0; $i < count($exp); $i++){
                    if(!empty($exp[$i][0]) && $exp[$i][0] == "%"){
                        $variables[substr($exp[$i],1,strlen($exp[$i]) - 1)] = $path[$i];
                    } else {
                        if($exp[$i] != $path[$i]){
                            return false;
                        }
                    }
                }
            } else {
                return false;
            }
            return array(1,$variables);
        }

        /* reroute(string, string) -> null
         * Reroute to another route.
         * Throws an exception if route is not found.
         */
        public function reroute($method,$route){
            $routeCheck = $this->routeExists($this->routes[$method],$route);
            if($routeCheck){
                $this->routes[$method][$routeCheck[0]]($routeCheck[1],$this,$this->app);
            } else {
                throw new \Exception(ErrorCodes\ROUTE_NOT_EXIST_ERROR);
            }
        }

        /* route() -> null
         * Do an automatic routing, it is recommended to only call this once.
         */
        public function route(){
            $route_check = $this->routeExists($this->routes[self::getRequestMethod()],$this->getRequestPath());
            if($route_check){
                $this->routes[self::getRequestMethod()][$route_check[0]]($route_check[1],$this,$this->app);
            } else {
                // If not found route is also not found. Then respond with default not found behavior
                if(empty($this->routes[self::getRequestMethod()]["notfound"])){
                    $this->app->setResponseStatus(ResponseStatus::$notFound);
                    $this->app->setResponseMessage("This is a default not found message from haumea framework.");
                    $this->app->respond();
                } else {
                    $this->routes[self::getRequestMethod()]["notfound"](array(),$this,$this->app);
                }
            }
        }
    }
?>
