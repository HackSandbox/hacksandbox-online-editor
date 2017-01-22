<?php
if(!(function_exists("base64_decode") &&
   function_exists("imagecreatefromjpeg") &&
   function_exists("imageSX") &&
   function_exists("imageSY") &&
   function_exists("ImageCreateTrueColor")&&
   function_exists("imagecopyresampled")&&
   function_exists("imagepng")&&
   function_exists("imagejpeg")&&
   function_exists("imagedestroy"))){
     echo "system error";
     die();
   }
?>