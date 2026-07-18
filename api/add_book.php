<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

include 'db.php';

// รับ JSON
$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode([
        "status" => "error",
        "message" => "No data received"
    ]);
    exit;
}

$title = $conn->real_escape_string($data['title']);
$author = $conn->real_escape_string($data['author']);
$publisher = $conn->real_escape_string($data['publisher']);
$price = $data['price'];
$description = $conn->real_escape_string($data['description']);
$imageUrl = $conn->real_escape_string($data['imageUrl']);
$category_id = isset($data['category_id']) ? intval($data['category_id']) : 1;

// เพิ่มข้อมูล
$sql = "INSERT INTO books
(title, author, publisher, price, description, imageUrl, category_id)
VALUES
('$title','$author','$publisher','$price','$description','$imageUrl','$category_id')";

if ($conn->query($sql)) {

    echo json_encode([
        "status" => "success",
        "message" => "Book added successfully"
    ]);

} else {

    echo json_encode([
        "status" => "error",
        "message" => $conn->error
    ]);

}

$conn->close();
?>