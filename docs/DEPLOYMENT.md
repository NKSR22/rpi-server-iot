# คู่มือ Deployment

## เครื่องเป้าหมาย

- บอร์ด: Raspberry Pi 5
- หน่วยความจา: 4 GB RAM หรือมากกว่า
- ระบบปฏิบัติการที่แนะนา: Raspberry Pi OS Lite 64-bit

## ลำดับการติดตั้ง

1. ติดตั้ง Raspberry Pi OS แบบ terminal
2. SSH เข้าเครื่อง
3. อัปเดตระบบ
4. ติดตั้ง Git และเครื่องมือพื้นฐาน
5. ติดตั้ง Docker Engine และ Docker Compose plugin
6. clone โปรเจกต์จาก GitHub
7. สร้างไฟล์ `.env`
8. เริ่มระบบด้วย Docker Compose
9. ทดสอบ Node-RED, MQTT และ Grafana

## ขั้นตอนที่ 1 อัปเดตระบบ

```bash
sudo apt update
sudo apt full-upgrade -y
sudo reboot
```

## ขั้นตอนที่ 2 ติดตั้งเครื่องมือพื้นฐาน

```bash
sudo apt install -y git curl ca-certificates gnupg nano
```

## ขั้นตอนที่ 3 clone โปรเจกต์

```bash
git clone https://github.com/NKSR22/rpi-server-iot.git
cd rpi-server-iot
```

## ขั้นตอนที่ 4 ติดตั้ง Docker

```bash
chmod +x scripts/install-docker.sh
./scripts/install-docker.sh
```

หลังติดตั้งเสร็จ แนะนาให้ออกจากระบบแล้ว login ใหม่

ตรวจสอบเวอร์ชัน

```bash
docker --version
docker compose version
```

## ขั้นตอนที่ 5 สร้างไฟล์ `.env`

```bash
cp .env.example .env
nano .env
```

## ขั้นตอนที่ 6 เริ่มระบบ

```bash
chmod +x scripts/start.sh
./scripts/start.sh
```

หรือ

```bash
docker compose up -d
```

## ขั้นตอนที่ 7 ตรวจสอบสถานะ

```bash
docker compose ps
docker compose logs -f
```

## ขั้นตอนที่ 8 หา IP ของเครื่อง

```bash
hostname -I
```

สมมติได้ IP เป็น `192.168.1.50`

- Node-RED: `http://192.168.1.50:1880`
- Grafana: `http://192.168.1.50:3000`
- MQTT: `192.168.1.50:1883`

## ขั้นตอนที่ 9 หยุดระบบ

```bash
chmod +x scripts/stop.sh
./scripts/stop.sh
```

หรือ

```bash
docker compose down
```

## การสารองข้อมูล

```bash
chmod +x scripts/backup.sh
./scripts/backup.sh
```

## โฟลเดอร์สาคัญที่ต้องสารอง

- `docker/mosquitto/data/`
- `docker/mosquitto/log/`
- `docker/nodered/data/`
- `docker/grafana/data/`
