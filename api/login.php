<?php

// ===========================
// CORS สำหรับ Flutter Web
// ===========================
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json");

// ตอบกลับ Preflight Request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

include('db.php');

// อนุญาตเฉพาะ POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        "message" => "POST only"
    ]);
    exit();
}

// รับค่าจาก POST อย่างปลอดภัย
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

// ตรวจสอบข้อมูล
if (empty($email) || empty($password)) {
    echo json_encode([
        "message" => "Email and password are required"
    ]);
    exit();
}

// ค้นหาผู้ใช้
$sql = "SELECT * FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode([
        "message" => "Database prepare failed"
    ]);
    exit();
}

$stmt->bind_param("s", $email);
$stmt->execute();

$result = $stmt->get_result();

if ($result->num_rows == 0) {
    echo json_encode([
        "message" => "Invalid email or password"
    ]);
    exit();
}

$user = $result->fetch_assoc();

// ตรวจสอบรหัสผ่าน
if (password_verify($password, $user['password'])) {

    // ไม่ส่ง Password Hash กลับไป
    unset($user['password']);

    echo json_encode([
        "message" => "Login successful",
        "user" => $user
    ]);

} else {

    echo json_encode([
        "message" => "Invalid email or password"
    ]);

}

$stmt->close();
$conn->close();

?>