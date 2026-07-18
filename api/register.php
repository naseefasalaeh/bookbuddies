<?php

// ===== CORS =====
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

header("Content-Type: application/json");

include('db.php');

// อนุญาตเฉพาะ POST
if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    echo json_encode([
        "message" => "POST only"
    ]);
    exit();
}

// รับค่าจาก POST
$username = $_POST['username'] ?? '';
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';
$role = 'user';

// ตรวจสอบข้อมูลว่าง
if (empty($username) || empty($email) || empty($password)) {
    echo json_encode([
        "message" => "Please fill all fields"
    ]);
    exit();
}

// ตรวจสอบ email หรือ username ซ้ำ
$sql = "SELECT * FROM users WHERE email=? OR username=?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $email, $username);
$stmt->execute();

$result = $stmt->get_result();

if ($result->num_rows > 0) {
    echo json_encode([
        "message" => "Email or Username already exists"
    ]);
    exit();
}

// Hash Password
$passwordHash = password_hash($password, PASSWORD_BCRYPT);

// Insert
$sql = "INSERT INTO users(username,email,password,role)
VALUES(?,?,?,?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param("ssss", $username, $email, $passwordHash, $role);

if ($stmt->execute()) {

    echo json_encode([
        "message"=>"User registered successfully"
    ]);

}else{

    echo json_encode([
        "message"=>$stmt->error
    ]);

}

$stmt->close();
$conn->close();

?>