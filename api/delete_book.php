<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: DELETE, GET");
header("Content-Type: application/json");

include 'db.php';

$id = isset($_GET["id"]) ? intval($_GET["id"]) : 0;

if ($id == 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid ID"
    ]);
    exit;
}

$sql = "DELETE FROM books WHERE id=$id";

if ($conn->query($sql)) {
    echo json_encode([
        "status" => "success",
        "message" => "Book Deleted"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => $conn->error
    ]);
}

$conn->close();
?>