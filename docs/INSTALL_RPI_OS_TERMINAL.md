# การติดตั้ง Raspberry Pi OS แบบ Terminal

คู่มือนี้อธิบายขั้นตอนเริ่มต้นสาหรับเตรียม Raspberry Pi 5 ให้พร้อมเป็น Local IoT Server

## สิ่งที่ต้องเตรียม

- Raspberry Pi 5
- microSD card อย่างน้อย 32 GB
- power supply ที่รองรับ Raspberry Pi 5
- สาย LAN หรือ Wi-Fi
- คอมพิวเตอร์สาหรับ flash ระบบปฏิบัติการ

## ระบบปฏิบัติการที่แนะนา

ใช้ `Raspberry Pi OS Lite (64-bit)` เพราะเหมาะกับงาน server และใช้ทรัพยากรน้อย

## ขั้นตอนเตรียม microSD

1. ติดตั้ง Raspberry Pi Imager
2. เลือก OS เป็น `Raspberry Pi OS Lite (64-bit)`
3. เลือก microSD card
4. ตั้งค่า hostname เช่น `rpi-iot`
5. เปิด `Enable SSH`
6. ตั้ง username และ password
7. ตั้ง timezone เป็น `Asia/Bangkok`
8. ถ้าจะใช้ Wi-Fi ให้กรอก SSID และ password
9. เขียน image ลง microSD

## Boot ครั้งแรก

1. ใส่ microSD ลง Raspberry Pi 5
2. ต่อสาย LAN หรือเตรียม Wi-Fi
3. จ่ายไฟเข้าเครื่อง
4. รอระบบ boot 1-3 นาที

## การเชื่อมต่อผ่าน SSH

ตัวอย่าง

```bash
ssh pi@rpi-iot.local
```

หรือถ้ารู้ IP

```bash
ssh pi@192.168.1.50
```

## ตั้งค่าหลังเข้าเครื่อง

```bash
sudo raspi-config
```

หัวข้อที่ควรตรวจสอบ

- hostname
- timezone
- locale
- SSH

## อัปเดตระบบ

```bash
sudo apt update
sudo apt full-upgrade -y
sudo reboot
```

## ติดตั้งเครื่องมือพื้นฐาน

```bash
sudo apt install -y git curl ca-certificates gnupg nano
```

หลังจากนี้ให้ไปต่อที่ [DEPLOYMENT.md](/c:/DEV/rpi_server_iot/docs/DEPLOYMENT.md)
