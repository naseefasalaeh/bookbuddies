<?php
header("Content-Type: application/json; charset=UTF-8");

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

$check = $conn->prepare("SELECT id FROM favorites WHERE user_id=? AND book_id=?");
$check->bind_param("ii", $user_id, $book_id);
$check->execute();
$result = $check->get_result();

if ($result->num_rows > 0) {
    echo json_encode([
        "status" => "success",
        "message" => "Already favorite"
    ]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO favorites(user_id, book_id) VALUES (?, ?)");
$stmt->bind_param("ii", $user_id, $book_id);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Added"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => $stmt->error
    ]);
}

$stmt->close();
$check->close();
$conn->close();