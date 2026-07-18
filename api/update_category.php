<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: PUT, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

require_once "db.php";

$data = json_decode(file_get_contents("php://input"), true);
$id = intval($data['id'] ?? 0);
$name = trim($data['name'] ?? '');

if ($id <= 0 || $name === '') {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Invalid category data"]);
    exit;
}

$stmt = $conn->prepare("UPDATE categories SET name=? WHERE id=?");
$stmt->bind_param("si", $name, $id);
$success = $stmt->execute();

echo json_encode(["status" => $success ? "success" : "error"]);
$stmt->close();
$conn->close();
