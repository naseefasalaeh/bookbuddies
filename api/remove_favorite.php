<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit;
}

require_once "db.php";

$user_id = $_POST['user_id'] ?? null;
$book_id = $_POST['book_id'] ?? null;

if (!$user_id || !$book_id) {
    echo json_encode([
        "status" => "error",
        "message" => "Missing user_id or book_id"
    ]);
    exit;
}

$stmt = $conn->prepare("DELETE FROM favorites WHERE user_id=? AND book_id=?");
$stmt->bind_param("ii", $user_id, $book_id);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Removed"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => $stmt->error
    ]);
}

$stmt->close();
$conn->close();