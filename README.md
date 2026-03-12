# rpi-server-iot

คู่มือสาหรับสร้าง Local IoT Server บน Raspberry Pi 5 โดยใช้ Docker Compose เพื่อรันบริการหลักดังนี้

- MQTT Broker ด้วย Eclipse Mosquitto
- Node-RED สาหรับ automation และ data flow
- InfluxDB สาหรับเก็บข้อมูล time-series
- Grafana สาหรับ dashboard

เหมาะสาหรับงานระบบ IoT ภายในบ้าน ห้องทดลอง โรงงานขนาดเล็ก หรือระบบที่ต้องการรันภายในเครือข่าย local

## ใช้โปรเจกต์นี้เมื่อไร

โปรเจกต์นี้เหมาะเมื่อคุณต้องการให้ Raspberry Pi 5 ทาหน้าที่เป็นศูนย์กลางของระบบ IoT ภายในวง LAN โดยรองรับงานดังนี้

- รับส่งข้อความจากอุปกรณ์ IoT ผ่าน MQTT
- ประมวลผลข้อมูลและสร้าง flow ผ่าน Node-RED
- แสดงผล dashboard ผ่าน Grafana
- จัดเก็บ config และ data ไว้เป็นระเบียบในโฟลเดอร์เดียว

## โครงสร้างโฟลเดอร์

```text
rpi-server-iot/
|- compose.yaml
|- .env.example
|- .gitignore
|- README.md
|- docs/
|  |- ARCHITECTURE.md
|  |- DEPLOYMENT.md
|  |- INSTALL_RPI_OS_TERMINAL.md
|  `- OPERATIONS.md
|- scripts/
|  |- install-docker.sh
|  |- start.sh
|  |- stop.sh
|  `- backup.sh
`- docker/
   |- mosquitto/
   |  |- config/
   |  |  `- mosquitto.conf
   |  |- data/
   |  `- log/
   |- nodered/
   |  `- data/
   |- influxdb/
   |  |- config/
   |  `- data/
   `- grafana/
      |- data/
      `- provisioning/
         |- dashboards/
         `- datasources/
```

## หน้าที่ของแต่ละส่วน

- `compose.yaml` ใช้กาหนด service ทั้งหมดของระบบ
- `.env.example` เป็นไฟล์ตัวอย่างสาหรับตั้งค่าพอร์ตและข้อมูลเริ่มต้น
- `docker/mosquitto/config/mosquitto.conf` เป็นไฟล์ config ของ MQTT broker
- `docker/nodered/data/` ใช้เก็บ flow และข้อมูลถาวรของ Node-RED
- `docker/influxdb/data/` ใช้เก็บข้อมูล time-series ของ InfluxDB
- `docker/grafana/data/` ใช้เก็บข้อมูลถาวรของ Grafana
- `scripts/` ใช้เก็บ script ช่วยติดตั้งและจัดการระบบ
- `docs/` ใช้เก็บคู่มือแบบละเอียด

## คู่มือที่ควรอ่านตามลำดับ

1. [การติดตั้ง Raspberry Pi OS แบบ Terminal](/c:/DEV/rpi_server_iot/docs/INSTALL_RPI_OS_TERMINAL.md)
2. [คู่มือ Deployment](/c:/DEV/rpi_server_iot/docs/DEPLOYMENT.md)
3. [การดูแลและใช้งานระบบ](/c:/DEV/rpi_server_iot/docs/OPERATIONS.md)
4. [สถาปัตยกรรมระบบ](/c:/DEV/rpi_server_iot/docs/ARCHITECTURE.md)

## วิธี clone โปรเจกต์จาก GitHub

บน Raspberry Pi หรือเครื่อง Linux ปลายทาง ให้ใช้คาสั่งนี้

```bash
git clone https://github.com/NKSR22/rpi-server-iot.git
cd rpi-server-iot
```

ถ้ายังไม่มี `git` ให้ติดตั้งก่อน

```bash
sudo apt update
sudo apt install -y git
```

## ขั้นตอนติดตั้งแบบย่อ

### 1. สร้างไฟล์ `.env`

```bash
cp .env.example .env
nano .env
```

### 2. ติดตั้ง Docker

```bash
chmod +x scripts/install-docker.sh
./scripts/install-docker.sh
```

หลังติดตั้งเสร็จ ให้ logout แล้ว login ใหม่

### 3. เริ่มระบบ

```bash
chmod +x scripts/start.sh
./scripts/start.sh
```

### 4. ตรวจสอบสถานะ

```bash
docker compose ps
docker compose logs -f
```

## ค่าเริ่มต้นในไฟล์ `.env.example`

```env
TZ=Asia/Bangkok
MQTT_PORT=1883
MQTT_WS_PORT=9001
NODE_RED_PORT=1880
GRAFANA_PORT=3000
INFLUXDB_PORT=8086
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=admin123
INFLUXDB_USERNAME=admin
INFLUXDB_PASSWORD=admin12345
INFLUXDB_ORG=local-iot
INFLUXDB_BUCKET=sensor-data
INFLUXDB_ADMIN_TOKEN=change-this-influxdb-token
```

## ช่องทางเข้าใช้งานหลังติดตั้ง

- MQTT Broker: `mqtt://IP-ADDRESS-OF-PI:1883`
- MQTT WebSocket: `ws://IP-ADDRESS-OF-PI:9001`
- Node-RED: `http://IP-ADDRESS-OF-PI:1880`
- InfluxDB: `http://IP-ADDRESS-OF-PI:8086`
- Grafana: `http://IP-ADDRESS-OF-PI:3000`

ตัวอย่างเช่น ถ้า Raspberry Pi มี IP เป็น `192.168.1.50`

- `mqtt://192.168.1.50:1883`
- `http://192.168.1.50:1880`
- `http://192.168.1.50:8086`
- `http://192.168.1.50:3000`

## คาสั่งสาคัญที่ใช้บ่อย

เริ่มระบบ

```bash
docker compose up -d
```

หยุดระบบ

```bash
docker compose down
```

ดูสถานะ

```bash
docker compose ps
```

ดู log

```bash
docker compose logs -f
```

ดู log แยกตาม service

```bash
docker compose logs -f mosquitto
docker compose logs -f nodered
docker compose logs -f influxdb
docker compose logs -f grafana
```

## ข้อแนะนาเพิ่มเติม

- ควรเปลี่ยนรหัสผ่าน Grafana หลังเข้าใช้งานครั้งแรก
- ในงานจริงควรเพิ่มระบบยืนยันตัวตนของ MQTT
- ควรสารองข้อมูลในโฟลเดอร์ `docker/` เป็นประจา
- ให้ใช้ InfluxDB เป็น data source หลักสาหรับ Grafana ในงาน sensor และ telemetry
- จาก Node-RED สามารถเขียนข้อมูลลง bucket ของ InfluxDB ได้โดยตรง

## Copyright

Copyright (c) 2026 Mr. Nakarin Sripanya  
Department of Electrical Engineering  
Faculty of Industry and Technology  
Rajamangala University of Technology Isan, Sakon Nakhon Campus
