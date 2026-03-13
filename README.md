# rpi-server-iot

คู่มือสำหรับสร้าง Local IoT Server บน Raspberry Pi 5 โดยใช้ Docker Compose เพื่อรันบริการหลักดังนี้

- MQTT Broker ด้วย Eclipse Mosquitto
- Node-RED สำหรับ automation และ data flow
- InfluxDB สำหรับเก็บข้อมูล time-series
- Grafana สำหรับ dashboard

เหมาะสำหรับงานระบบ IoT ภายในบ้าน ห้องทดลอง โรงงานขนาดเล็ก หรือระบบที่ต้องการรันภายในเครือข่าย local

## ใช้โปรเจกต์นี้เมื่อไร

โปรเจกต์นี้เหมาะเมื่อคุณต้องการให้ Raspberry Pi 5 ทำหน้าที่เป็นศูนย์กลางของระบบ IoT ภายในวง LAN โดยรองรับงานดังนี้

- รับส่งข้อความจากอุปกรณ์ IoT ผ่าน MQTT
- ประมวลผลข้อมูลและสร้าง flow ผ่าน Node-RED
- เก็บข้อมูล time-series ใน InfluxDB
- แสดงผล dashboard ผ่าน Grafana
- จัดเก็บ config และ data ไว้เป็นระเบียบในโฟลเดอร์เดียว

## วิเคราะห์ความเหมาะสมของ Raspberry Pi 5 และ RAM

สำหรับ stack `Mosquitto + Node-RED + InfluxDB + Grafana`

- Raspberry Pi 5 RAM 4 GB ใช้งานได้จริงสำหรับระบบ local IoT ขนาดเล็กถึงกลาง
- ถ้ามี dashboard หลายหน้า, query ข้อมูลย้อนหลังบ่อย, หรือมี flow หนัก แนะนำ RAM 8 GB
- Mosquitto ใช้ RAM น้อยที่สุดในระบบ
- InfluxDB และ Grafana เป็นส่วนที่ใช้ RAM และ storage มากที่สุด
- ถ้าเก็บข้อมูลนานหรือเขียนข้อมูลถี่ ควรใช้ SSD มากกว่า microSD

## โครงสร้างโฟลเดอร์

```text
rpi-server-iot/
|- compose.yaml
|- .env.example
|- .gitignore
|- README.md
|- docs/
|  |- README.md
|  |- ARCHITECTURE.md
|  |- DEPLOYMENT.md
|  |- INSTALL_RPI_OS_TERMINAL.md
|  |- LAN_VALIDATION.md
|  |- OPERATIONS.md
|  |- PRODUCTION_HARDENING.md
|  |- THEORY_IOT_SYSTEM.md
|  |- THEORY_MQTT.md
|  `- THEORY_NODE_RED.md
|- scripts/
|  |- install-base-tools.sh
|  |- install-docker.sh
|  |- enable-mqtt-auth.sh
|  |- prepare-data-dirs.sh
|  |- verify-system-tools.sh
|  |- start.sh
|  |- stop.sh
|  `- backup.sh
`- docker/
   |- mosquitto/
   |- nodered/
   |- influxdb/
   `- grafana/
```

## หน้าที่ของแต่ละส่วน

- `compose.yaml` ใช้กำหนด service ทั้งหมดของระบบ
- `.env.example` เป็นไฟล์ตัวอย่างสำหรับตั้งค่าพอร์ตและข้อมูลเริ่มต้น
- `scripts/install-base-tools.sh` ติดตั้งเครื่องมือพื้นฐานรวม `nvim`
- `scripts/verify-system-tools.sh` ตรวจว่าเครื่องมือสำคัญพร้อมใช้งานจริง
- `docker/` ใช้เก็บข้อมูลถาวรของแต่ละ service บน filesystem ของ Raspberry Pi
- `docs/` ใช้เก็บคู่มือแบบละเอียดและเนื้อหาทฤษฎี

## ข้อมูลถูกบันทึกไว้ที่ไหน

ข้อมูลสำคัญไม่ได้เก็บอยู่แค่ใน container แต่ถูก bind mount ลงมาไว้ในโฟลเดอร์ของโปรเจกต์บน Raspberry Pi โดยตรง ดังนั้นเมื่อ restart container หรือ `docker compose down` ข้อมูลยังคงอยู่ตราบใดที่ไฟล์ในเครื่องยังไม่ถูกลบ

- `docker/mosquitto/data/` และ `docker/mosquitto/log/` สำหรับ MQTT
- `docker/nodered/data/` สำหรับ flow และ credential ของ Node-RED
- `docker/influxdb/data/` และ `docker/influxdb/config/` สำหรับ InfluxDB
- `docker/grafana/data/` และ `docker/grafana/provisioning/` สำหรับ Grafana
- `.env` สำหรับค่าตั้งค่าของระบบ

สิ่งที่ไม่ถือเป็นข้อมูลถาวรคือ container image และ container runtime เอง ซึ่งสามารถสร้างใหม่ได้จาก `compose.yaml`

## คู่มือที่ควรอ่านตามลำดับ

1. [docs/INSTALL_RPI_OS_TERMINAL.md](docs/INSTALL_RPI_OS_TERMINAL.md)
2. [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)
3. [docs/OPERATIONS.md](docs/OPERATIONS.md)
4. [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
5. [docs/LAN_VALIDATION.md](docs/LAN_VALIDATION.md)
6. [docs/PRODUCTION_HARDENING.md](docs/PRODUCTION_HARDENING.md)
7. [docs/README.md](docs/README.md)

## วิธี clone โปรเจกต์จาก GitHub

ถ้ายังไม่มี `git` ให้ติดตั้งก่อน

```bash
sudo apt update
sudo apt install -y git
```

บน Raspberry Pi หรือเครื่อง Linux ปลายทาง ให้ใช้คำสั่งนี้

```bash
git clone https://github.com/NKSR22/rpi-server-iot.git
cd ~/rpi-server-iot
```

## ขั้นตอนติดตั้งแบบย่อ

### 1. ติดตั้งเครื่องมือพื้นฐานให้ครบ

รันคำสั่งต่อไปนี้จากโฟลเดอร์โปรเจกต์ `rpi-server-iot`

```bash
cd ~/rpi-server-iot
chmod +x scripts/install-base-tools.sh
./scripts/install-base-tools.sh
./scripts/verify-system-tools.sh
```

### 2. ติดตั้ง Docker

```bash
cd ~/rpi-server-iot
chmod +x scripts/install-docker.sh
./scripts/install-docker.sh
```

### 3. สร้างไฟล์ `.env`

```bash
cp .env.example .env
nvim .env
```

### 4. เริ่มระบบ

```bash
cd ~/rpi-server-iot
chmod +x scripts/start.sh
./scripts/start.sh
```

### 5. ตรวจสอบสถานะ

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

## หลักการอ้างอิง host ให้ถูกต้อง

- จาก browser หรือ terminal บนเครื่องลูกข่ายในวง LAN ให้ใช้ `IP-ADDRESS-OF-PI`
- จาก shell บน Raspberry Pi เอง ให้ใช้ `localhost`
- จาก service ภายใน Docker Compose ให้ใช้ชื่อ service เช่น `mosquitto` และ `influxdb`

ตัวอย่าง

- เครื่องลูกข่ายเปิด Grafana: `http://IP-ADDRESS-OF-PI:3000`
- Grafana data source ไป InfluxDB: `http://influxdb:8086`
- Node-RED MQTT broker: `mosquitto:1883`

## ข้อแนะนำเพิ่มเติม

- ควรเปลี่ยนรหัสผ่าน Grafana และ InfluxDB หลังติดตั้งครั้งแรก
- ถ้าใช้ RAM 4 GB ควรติดตามการใช้หน่วยความจำในช่วงแรกของการใช้งาน
- ถ้าข้อมูล sensor ถูกเขียนถี่มาก ควรพิจารณา SSD แทน microSD
- ควรสำรองข้อมูลในโฟลเดอร์ `docker/` และไฟล์ `.env` เป็นประจำ

## Copyright

Copyright (c) 2026 Mr. Nakarin Sripanya  
Department of Electrical Engineering  
Faculty of Industry and Technology  
Rajamangala University of Technology Isan, Sakon Nakhon Campus
