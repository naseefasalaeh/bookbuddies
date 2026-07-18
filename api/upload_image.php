<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$response = [];

$targetDir = "../images/";

if (!file_exists($targetDir)) {
    mkdir($targetDir, 0777, true);
}

if (!isset($_FILES["image"])) {
    echo json_encode([
        "status" => "error",
        "message" => "No image uploaded"
    ]);
    exit;
}

$image = $_FILES["image"];

$fileName = time() . "_" . basename($image["name"]);
$targetFile = $targetDir . $fileName;

if (move_uploaded_file($image["tmp_name"], $targetFile)) {

    $url = "http://127.0.0.1/final032/images/" . $fileName;

    echo json_encode([
        "status" => "success",
        "imageUrl" => $url
    ]);
} else {

    echo json_encode([
        "status" => "error",
        "message" => "Upload failed"
    ]);
}
?>