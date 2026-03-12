# การดูแลและใช้งานระบบ

## คาสั่งเริ่มและหยุดระบบ

เริ่มระบบ

```bash
docker compose up -d
```

หยุดระบบ

```bash
docker compose down
```

เริ่มผ่าน script

```bash
./scripts/start.sh
```

หยุดผ่าน script

```bash
./scripts/stop.sh
```

## การตรวจสอบสถานะ

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

## การทดสอบ MQTT เบื้องต้น

ติดตั้ง MQTT client

```bash
sudo apt install -y mosquitto-clients
```

subscribe

```bash
mosquitto_sub -h localhost -p 1883 -t test/topic
```

publish

```bash
mosquitto_pub -h localhost -p 1883 -t test/topic -m "hello"
```

## การใช้งาน InfluxDB เบื้องต้น

- URL เริ่มต้นคือ `http://IP-ADDRESS-OF-PI:8086`
- ค่า `org`, `bucket`, `username` และ `token` ดูได้จากไฟล์ `.env`
- ใน Grafana ให้เพิ่ม data source ประเภท `InfluxDB`
- ใน Node-RED สามารถใช้ node ของ InfluxDB เพื่อเขียนข้อมูล sensor ลง bucket ได้

## การสารองข้อมูล

```bash
./scripts/backup.sh
```

## การอัปเดต image

```bash
docker compose pull
docker compose up -d
```

## แนวทางแก้ปัญหาเบื้องต้น

1. ตรวจสอบไฟล์ `.env`
2. ตรวจสอบ port ที่ใช้งาน
3. ตรวจสอบ log ของ service
4. ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตตอนดึง image ครั้งแรก
