<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: PUT, POST");
header("Content-Type: application/json");

include 'db.php';

$data = json_decode(file_get_contents("php://input"), true);

$id = intval($data["id"]);
$title = $conn->real_escape_string($data["title"]);
$author = $conn->real_escape_string($data["author"]);
$publisher = $conn->real_escape_string($data["publisher"]);
$price = floatval($data["price"]);
$description = $conn->real_escape_string($data["description"]);
$imageUrl = $conn->real_escape_string($data["imageUrl"]);
$category = intval($data["category_id"]);

$sql = "UPDATE books SET
title='$title',
author='$author',
publisher='$publisher',
price='$price',
description='$description',
imageUrl='$imageUrl',
category_id='$category'
WHERE id=$id";

if($conn->query($sql)){
    echo json_encode([
        "status"=>"success",
        "message"=>"Book Updated"
    ]);
}else{
    echo json_encode([
        "status"=>"error",
        "message"=>$conn->error
    ]);
}

$conn->close();
?>