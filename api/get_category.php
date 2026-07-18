<?php
header("Content-Type: application/json; charset=UTF-8");

// เชื่อมต่อฐานข้อมูล
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "final032";

$conn = new mysqli($servername, $username, $password, $dbname);
$conn->set_charset("utf8mb4");

// ตรวจสอบการเชื่อมต่อ
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// ดึงข้อมูลหมวดหมู่ทั้งหมด
$sql_category = "SELECT id, name FROM categories";
$result_category = $conn->query($sql_category);

$categories = [];

if ($result_category->num_rows > 0) {
    while ($category = $result_category->fetch_assoc()) {
        $category_id = $category['id'];
        
        // ดึงข้อมูลหนังสือที่อยู่ในหมวดหมู่นี้
        $sql_books = "SELECT id, title, imageUrl, author, publisher, price, description FROM books WHERE category_id = $category_id";

        $result_books = $conn->query($sql_books);

        $books = [];

        while ($book = $result_books->fetch_assoc()) {
            if (!filter_var($book['imageUrl'], FILTER_VALIDATE_URL)) {
                $book['imageUrl'] = 'http://localhost/final032/uploads/' . $book['imageUrl'];
            }
            $books[] = $book; // ส่งข้อมูลทั้งหมด
        }

        $categories[] = [
            'category_id' => $category['id'],
            'category_name' => $category['name'],
            'books' => $books, // รวมรายการหนังสือเข้าไป
        ];
    }
}

// ส่งข้อมูลเป็น JSON
echo json_encode(
    $categories,
    JSON_UNESCAPED_UNICODE |
    JSON_UNESCAPED_SLASHES |
    JSON_PRETTY_PRINT
);

$conn->close();
?>
