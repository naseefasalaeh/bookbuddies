<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

require_once "db.php";

$data = json_decode(file_get_contents("php://input"), true);
$name = trim($data['name'] ?? '');

if ($name === '') {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Category name is required"]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO categories (name) VALUES (?)");
$stmt->bind_param("s", $name);
$success = $stmt->execute();

echo json_encode(["status" => $success ? "success" : "error"]);
$stmt->close();
$conn->close();
