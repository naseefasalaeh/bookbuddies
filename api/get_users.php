<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

require_once "db.php";

$admin_id = intval($_POST['admin_id'] ?? 0);
$admin = $conn->prepare("SELECT role FROM users WHERE id=?");
$admin->bind_param("i", $admin_id);
$admin->execute();
$admin_user = $admin->get_result()->fetch_assoc();

if (!$admin_user || $admin_user['role'] !== 'admin') {
    http_response_code(403);
    echo json_encode(["status" => "error", "message" => "Admin access required"]);
    exit;
}

$result = $conn->query(
    "SELECT id, username, email, role FROM users ORDER BY username ASC"
);
$users = [];

while ($row = $result->fetch_assoc()) {
    $users[] = $row;
}

echo json_encode($users, JSON_UNESCAPED_UNICODE);
$admin->close();
$conn->close();
