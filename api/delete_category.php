<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: DELETE, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

require_once "db.php";

$id = intval($_GET['id'] ?? 0);

if ($id <= 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Invalid category id"]);
    exit;
}

$check = $conn->prepare("SELECT COUNT(*) AS total FROM books WHERE category_id=?");
$check->bind_param("i", $id);
$check->execute();
$total = intval($check->get_result()->fetch_assoc()['total']);

if ($total > 0) {
    http_response_code(409);
    echo json_encode([
        "status" => "error",
        "message" => "Move or delete books in this category first"
    ]);
    exit;
}

$stmt = $conn->prepare("DELETE FROM categories WHERE id=?");
$stmt->bind_param("i", $id);
$success = $stmt->execute();

echo json_encode(["status" => $success ? "success" : "error"]);
$stmt->close();
$check->close();
$conn->close();
