<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit;
}

require_once "db.php";

$user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;

if ($user_id <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Missing or invalid user_id"
    ]);
    exit;
}

$sql = "
SELECT
    b.id,
    b.title,
    b.author,
    b.publisher,
    b.price,
    b.description,
    b.imageUrl,
    b.category_id
FROM favorites f
INNER JOIN books b
ON f.book_id = b.id
WHERE f.user_id = ?
";

$stmt = $conn->prepare($sql);

$stmt->bind_param("i", $user_id);
$stmt->execute();

$result = $stmt->get_result();

$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

$conn->close();
