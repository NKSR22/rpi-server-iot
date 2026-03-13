# คู่มือ Deployment

## เครื่องเป้าหมาย

- บอร์ด: Raspberry Pi 5
- หน่วยความจา: 4 GB RAM หรือมากกว่า
- ระบบปฏิบัติการที่แนะนา: Raspberry Pi OS Lite 64-bit
- แนะนา Ethernet และ storage ที่เชื่อถือได้สาหรับงานต่อเนื่อง

## ภาพรวมการติดตั้ง

1. ติดตั้ง Raspberry Pi OS แบบ terminal
2. SSH เข้าเครื่อง
3. อัปเดตระบบและ firmware ที่จาเป็น
4. ตรวจสอบ RAM, swap, disk และ network ให้พร้อม
5. ติดตั้ง `git` ถ้ายังไม่มี
6. clone โปรเจกต์จาก GitHub
7. ติดตั้งเครื่องมือพื้นฐาน รวมถึง `nvim`
8. สร้างไฟล์ `.env`
9. ติดตั้ง Docker Engine และ Docker Compose plugin
10. เริ่มระบบด้วย Docker Compose
11. ทดสอบ Node-RED, MQTT, InfluxDB และ Grafana
12. ตรวจสอบ log และ backup strategy

## ขั้นตอนที่ 1 อัปเดตระบบ

```bash
sudo apt update
sudo apt full-upgrade -y
sudo reboot
```

## ขั้นตอนที่ 2 ตรวจสอบทรัพยากรเครื่องก่อนติดตั้ง

ตรวจสอบ RAM, swap และพื้นที่ว่าง

```bash
free -h
swapon --show
df -h
```

ตรวจสอบ IP และ network

```bash
ip a
ip r
ping -c 4 8.8.8.8
```

หลักคิด

- ถ้า RAM เหลือน้อยมากตั้งแต่ก่อนติดตั้ง ควรทบทวน service ที่จะเปิดพร้อมกัน
- ถ้า storage เหลือน้อย InfluxDB และ Grafana จะมีปัญหาในระยะยาว
- ถ้าใช้ Wi-Fi และสัญญาณไม่นิ่ง การ subscribe/publish ของ MQTT อาจสะดุด

## ขั้นตอนที่ 3 ติดตั้ง `git` ถ้ายังไม่มี

```bash
sudo apt update
sudo apt install -y git
```

## ขั้นตอนที่ 4 clone โปรเจกต์

```bash
git clone https://github.com/NKSR22/rpi-server-iot.git
cd ~/rpi-server-iot
```

## ขั้นตอนที่ 5 ติดตั้งเครื่องมือพื้นฐาน

ให้รันคาสั่งต่อไปนี้จากโฟลเดอร์โปรเจกต์ `rpi-server-iot`

```bash
cd ~/rpi-server-iot
chmod +x scripts/install-base-tools.sh
./scripts/install-base-tools.sh
```

ตรวจสอบว่าเครื่องมือพร้อมจริง

```bash
cd ~/rpi-server-iot
chmod +x scripts/verify-system-tools.sh
./scripts/verify-system-tools.sh
```

## ขั้นตอนที่ 6 ติดตั้ง Docker

```bash
cd ~/rpi-server-iot
chmod +x scripts/install-docker.sh
./scripts/install-docker.sh
```

หลังติดตั้งเสร็จ แนะนาให้ออกจากระบบแล้ว login ใหม่

ตรวจสอบเวอร์ชัน

```bash
docker --version
docker compose version
```

## ขั้นตอนที่ 7 สร้างไฟล์ `.env`

```bash
cp .env.example .env
nvim .env
```

ค่าที่ควรตรวจสอบเพิ่มเติมสาหรับ InfluxDB

- `INFLUXDB_PORT=8086`
- `INFLUXDB_USERNAME=admin`
- `INFLUXDB_PASSWORD=admin12345`
- `INFLUXDB_ORG=local-iot`
- `INFLUXDB_BUCKET=sensor-data`
- `INFLUXDB_ADMIN_TOKEN=change-this-influxdb-token`

ข้อแนะนา

- เปลี่ยน password เริ่มต้นก่อนใช้งานจริง
- token ของ InfluxDB ควรเปลี่ยนให้ยาวและคาดเดายาก
- ถ้าจะเปิดใช้จากหลายเครื่องในวง LAN ให้ตรวจสอบ firewall และ port ด้วย

## ขั้นตอนที่ 8 เริ่มระบบ

```bash
cd ~/rpi-server-iot
chmod +x scripts/start.sh
./scripts/start.sh
```

หรือ

```bash
docker compose up -d
```

## ขั้นตอนที่ 8 ตรวจสอบสถานะ

```bash
docker compose ps
docker compose logs -f
```

ดู log แยกตาม service

```bash
docker compose logs -f mosquitto
docker compose logs -f nodered
docker compose logs -f influxdb
docker compose logs -f grafana
```

## ขั้นตอนที่ 9 หา IP ของเครื่อง

```bash
hostname -I
```

สมมติได้ IP เป็น `192.168.1.50`

- Node-RED: `http://192.168.1.50:1880`
- InfluxDB: `http://192.168.1.50:8086`
- Grafana: `http://192.168.1.50:3000`
- MQTT: `192.168.1.50:1883`

## ขั้นตอนที่ 10 ทดสอบระบบปลายทาง

ทดสอบ MQTT

```bash
mosquitto_sub -h localhost -p 1883 -t test/topic
```

เปิดอีก terminal แล้วส่งค่า

```bash
mosquitto_pub -h localhost -p 1883 -t test/topic -m "hello"
```

ทดสอบว่า InfluxDB ตอบสนอง

```bash
curl http://localhost:8086/health
```

## ขั้นตอนที่ 11 หยุดระบบ

```bash
cd ~/rpi-server-iot
chmod +x scripts/stop.sh
./scripts/stop.sh
```

หรือ

```bash
cd ~/rpi-server-iot
docker compose down
```

## การสารองข้อมูล

```bash
cd ~/rpi-server-iot
chmod +x scripts/backup.sh
./scripts/backup.sh
```

## โฟลเดอร์สาคัญที่ต้องสารอง

- `docker/mosquitto/data/`
- `docker/mosquitto/log/`
- `docker/nodered/data/`
- `docker/influxdb/data/`
- `docker/influxdb/config/`
- `docker/grafana/data/`

## จุดที่ควรตรวจซ้าในงานจริง

- เวลาของระบบตรงกับ timezone จริงหรือไม่
- Raspberry Pi มี IP คงที่หรือ DHCP reservation หรือไม่
- password และ token ถูกเปลี่ยนจากค่าเริ่มต้นแล้วหรือยัง
- backup ถูกทดสอบกู้คืนได้หรือยัง
- storage มีพื้นที่พอสาหรับ InfluxDB ในระยะยาวหรือไม่

---

Copyright (c) 2026 Mr. Nakarin Sripanya  
Department of Electrical Engineering  
Faculty of Industry and Technology  
Rajamangala University of Technology Isan, Sakon Nakhon Campus
