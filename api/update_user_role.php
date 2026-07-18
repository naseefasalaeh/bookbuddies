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
$user_id = intval($_POST['user_id'] ?? 0);
$role = $_POST['role'] ?? '';

if ($admin_id <= 0 || $user_id <= 0 || !in_array($role, ['user', 'admin'], true)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Invalid request"]);
    exit;
}

$admin = $conn->prepare("SELECT role FROM users WHERE id=?");
$admin->bind_param("i", $admin_id);
$admin->execute();
$admin_user = $admin->get_result()->fetch_assoc();

if (!$admin_user || $admin_user['role'] !== 'admin') {
    http_response_code(403);
    echo json_encode(["status" => "error", "message" => "Admin access required"]);
    exit;
}

if ($admin_id === $user_id) {
    http_response_code(409);
    echo json_encode(["status" => "error", "message" => "You cannot change your own role"]);
    exit;
}

$target = $conn->prepare("SELECT role FROM users WHERE id=?");
$target->bind_param("i", $user_id);
$target->execute();
$target_user = $target->get_result()->fetch_assoc();

if (!$target_user) {
    http_response_code(404);
    echo json_encode(["status" => "error", "message" => "User not found"]);
    exit;
}

if ($target_user['role'] === 'admin' && $role === 'user') {
    $count = $conn->query("SELECT COUNT(*) AS total FROM users WHERE role='admin'");
    if (intval($count->fetch_assoc()['total']) <= 1) {
        http_response_code(409);
        echo json_encode(["status" => "error", "message" => "At least one admin is required"]);
        exit;
    }
}

$stmt = $conn->prepare("UPDATE users SET role=? WHERE id=?");
$stmt->bind_param("si", $role, $user_id);
$success = $stmt->execute();

echo json_encode(["status" => $success ? "success" : "error"]);
$stmt->close();
$target->close();
$admin->close();
$conn->close();
