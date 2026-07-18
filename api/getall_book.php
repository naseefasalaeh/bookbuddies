<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

include 'db.php';

$query = "SELECT * FROM books";
$result = $conn->query($query);

$books = [];

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $books[] = $row;
    }
}

echo json_encode($books, JSON_UNESCAPED_UNICODE);

$conn->close();
?>