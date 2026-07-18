<?php
$host = "localhost";
$user = "root";  // ใช้ root หรือ username ของ MySQL
$pass = "";  // ใส่รหัสผ่านถ้ามี
$dbname = "final032";  // เปลี่ยนชื่อฐานข้อมูลเป็น api_movie

$conn = new mysqli($host, $user, $pass, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
