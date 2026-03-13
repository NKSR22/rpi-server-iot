# การดูแลและใช้งานระบบ

## คำสั่งเริ่มและหยุดระบบ

เริ่มระบบ

```bash
cd ~/rpi-server-iot
docker compose up -d
```

หยุดระบบ

```bash
cd ~/rpi-server-iot
docker compose down
```

เริ่มผ่าน script

```bash
cd ~/rpi-server-iot
./scripts/start.sh
```

หยุดผ่าน script

```bash
cd ~/rpi-server-iot
./scripts/stop.sh
```

## การตรวจสอบสถานะระบบปฏิบัติการ

ตรวจสอบการใช้ RAM, CPU และ load

```bash
free -h
htop
```

ตรวจสอบ disk

```bash
df -h
```

ตรวจสอบ service และ port

```bash
ss -tulpn
lsof -i -P -n
```

## การตรวจสอบสถานะ container

```bash
cd ~/rpi-server-iot
docker compose ps
docker compose logs -f
```

ดู log แยกตาม service

```bash
cd ~/rpi-server-iot
docker compose logs -f mosquitto
docker compose logs -f nodered
docker compose logs -f influxdb
docker compose logs -f grafana
```

## การทดสอบ MQTT เบื้องต้น

subscribe

```bash
mosquitto_sub -h localhost -p 1883 -t test/topic
```

publish

```bash
mosquitto_pub -h localhost -p 1883 -t test/topic -m "hello"
```

ถ้าทดสอบจากคอมพิวเตอร์อีกเครื่องหนึ่งในวง LAN ให้ใช้ IP ของ Raspberry Pi แทน `localhost` และดูขั้นตอนแบบละเอียดใน [LAN_VALIDATION.md](LAN_VALIDATION.md)

## การใช้งาน InfluxDB เบื้องต้น

- URL เริ่มต้นคือ `http://IP-ADDRESS-OF-PI:8086`
- ค่า `org`, `bucket`, `username` และ `token` ดูได้จากไฟล์ `.env`
- ใน Grafana ให้เพิ่ม data source ประเภท `InfluxDB`
- ใน Node-RED สามารถใช้ node ของ InfluxDB เพื่อเขียนข้อมูล sensor ลง bucket ได้
- เมื่อ config จาก Grafana ให้ใช้ URL `http://influxdb:8086`
- เมื่อ config จาก Node-RED ที่รันใน container เดียวกัน ให้หลีกเลี่ยง `localhost` ถ้าหมายถึง service อื่น

## การใช้งาน Neovim ในเครื่อง server

เปิดแก้ไฟล์ `.env`

```bash
nvim .env
```

เปิดแก้ compose

```bash
nvim compose.yaml
```

## การสำรองข้อมูล

```bash
cd ~/rpi-server-iot
./scripts/backup.sh
```

สคริปต์นี้สำรอง `.env`, `compose.yaml`, Mosquitto config/data/log, Node-RED data, InfluxDB data/config และ Grafana data/provisioning ไปยังโฟลเดอร์ `backup-YYYYMMDD-HHMMSS`

## การอัปเดต image

```bash
cd ~/rpi-server-iot
docker compose pull
docker compose up -d
```

## การตรวจสอบว่าเครื่องมือพร้อมใช้งาน

```bash
cd ~/rpi-server-iot
./scripts/verify-system-tools.sh
```

ถ้าพบ `[MISSING]` ให้ติดตั้งเครื่องมือชุดพื้นฐานใหม่อีกครั้ง

## แนวทางตรวจ Grafana เมื่อ container รันแต่หน้าเว็บเข้าไม่ได้

เช็กก่อนว่า port ถูกเปิดจริงบนเครื่อง host

```bash
ss -tulpn | grep 3000
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

ดู log ของ Grafana โดยตรง

```bash
cd ~/rpi-server-iot
docker compose logs --tail=200 grafana
```

ตรวจสิทธิ์ของโฟลเดอร์ข้อมูล Grafana

```bash
cd ~/rpi-server-iot
ls -ld docker/grafana/data
ls -l docker/grafana/data
```

ถ้า log มีลักษณะใกล้เคียง `permission denied`, `database is locked`, `failed to open sqlite database` หรือ browser ขึ้น `This site can't be reached` ทั้งที่ container รันอยู่ ให้เตรียมสิทธิ์ใหม่แล้วเริ่มระบบอีกครั้ง

```bash
cd ~/rpi-server-iot
chmod +x scripts/prepare-data-dirs.sh
./scripts/prepare-data-dirs.sh
docker compose restart grafana
```

ถ้ายังเข้าไม่ได้ ให้ตรวจเพิ่มว่า firewall ของเครื่องปลายทางไม่ได้บล็อก port `3000`

```bash
sudo ufw status
curl -I http://127.0.0.1:3000
curl -I http://$(hostname -I | awk '{print $1}'):3000
```

## แนวทางแก้ปัญหาเบื้องต้น

1. ตรวจสอบไฟล์ `.env`
2. ตรวจสอบ port ที่ใช้งาน
3. ตรวจสอบ log ของ service
4. ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตตอนดึง image ครั้งแรก
5. ตรวจสอบ RAM และพื้นที่เก็บข้อมูลเมื่อระบบเริ่มช้า
6. ตรวจสอบว่า InfluxDB ไม่กินพื้นที่จนเต็ม disk

---

Copyright (c) 2026 Mr. Nakarin Sripanya  
Department of Electrical Engineering  
Faculty of Industry and Technology  
Rajamangala University of Technology Isan, Sakon Nakhon Campus
