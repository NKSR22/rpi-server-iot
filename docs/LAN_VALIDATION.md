# การทดสอบระบบจากเครื่องลูกข่ายในวง LAN

เอกสารนี้สำหรับทดสอบระบบเมื่อ Raspberry Pi เป็น server และเครื่องที่ใช้ browser หรือคำสั่งทดสอบเป็น "อีกเครื่องหนึ่ง" ที่อยู่ในวง LAN เดียวกัน

## หลักการอ้างอิง host ให้ถูกต้อง

ใช้ host คนละแบบตามบริบท

- จาก browser หรือ terminal บนเครื่องลูกข่ายใน LAN: ใช้ `IP-ADDRESS-OF-PI`
- จาก shell บน Raspberry Pi เอง: ใช้ `localhost`
- จาก container ไปหา container อื่นใน Docker Compose เดียวกัน: ใช้ชื่อ service เช่น `mosquitto`, `influxdb`

ตัวอย่างที่ถูกต้อง

- เปิด Grafana จากคอมพิวเตอร์อีกเครื่องหนึ่ง: `http://IP-ADDRESS-OF-PI:3000`
- เรียก InfluxDB health จากคอมพิวเตอร์อีกเครื่องหนึ่ง: `http://IP-ADDRESS-OF-PI:8086/health`
- ตั้งค่า MQTT broker ใน Node-RED: `mosquitto:1883`
- ตั้งค่า InfluxDB data source ใน Grafana: `http://influxdb:8086`

ตัวอย่างที่มักผิด

- ตั้งค่า InfluxDB ใน Grafana เป็น `http://localhost:8086`
- ตั้งค่า MQTT broker ใน Node-RED เป็น `127.0.0.1` โดยหวังว่าจะชี้ไปที่ Mosquitto container

## ข้อมูลที่ต้องเตรียมก่อนทดสอบ

บน Raspberry Pi ให้ตรวจ IP ก่อน

```bash
hostname -I
```

สมมติ IP ของ Raspberry Pi คือ `192.168.1.50`

บนเครื่องลูกข่ายใน LAN ควรมีเครื่องมืออย่างน้อย

- browser
- `curl`
- `mosquitto_sub` และ `mosquitto_pub` ถ้าจะทดสอบ MQTT แบบ CLI

บน Ubuntu หรือ Debian ของเครื่องลูกข่าย

```bash
sudo apt update
sudo apt install -y curl mosquitto-clients
```

## ตรวจสอบการเข้าถึงเครือข่ายเบื้องต้นจากเครื่องลูกข่าย

```bash
export PI_IP=192.168.1.50
ping -c 4 "$PI_IP"
curl -I "http://$PI_IP:1880"
curl -I "http://$PI_IP:3000"
curl "http://$PI_IP:8086/health"
```

ผลที่ควรได้

- `ping` ตอบกลับได้
- Node-RED และ Grafana ตอบ HTTP กลับ
- InfluxDB ส่ง JSON health กลับและไม่ timeout

ถ้าขั้นตอนนี้ไม่ผ่าน ให้ตรวจ firewall, IP address, DHCP reservation และสถานะ container ก่อน

## การทดสอบ MQTT จากเครื่องลูกข่าย

เปิด terminal แรกบนเครื่องลูกข่าย

```bash
export PI_IP=192.168.1.50
mosquitto_sub -h "$PI_IP" -p 1883 -t lan/test/topic -v
```

เปิดอีก terminal บนเครื่องลูกข่ายเดียวกัน หรืออีกเครื่องในวงเดียวกัน

```bash
export PI_IP=192.168.1.50
mosquitto_pub -h "$PI_IP" -p 1883 -t lan/test/topic -m "hello-from-lan"
```

ผลที่ควรได้

- terminal ฝั่ง subscribe ต้องเห็น `lan/test/topic hello-from-lan`

ถ้าต้องการทดสอบ WebSocket MQTT เพิ่ม

- ใช้โปรแกรมอย่าง MQTTX หรือ MQTT Explorer
- ตั้ง broker เป็น `ws://192.168.1.50:9001`

## การทดสอบ Node-RED จากเครื่องลูกข่าย

### ทดสอบหน้าเว็บ

เปิด browser จากเครื่องลูกข่าย

```text
http://192.168.1.50:1880
```

ผลที่ควรได้

- หน้า editor ของ Node-RED โหลดได้
- กดเมนูและ deploy ได้โดยไม่ค้าง

### ทดสอบ flow พื้นฐาน

1. เปิด Node-RED จาก browser
2. ลาก `inject` 1 ตัว, `debug` 1 ตัว, และ `mqtt out` 1 ตัวลง workspace
3. ต่อสาย `inject -> debug` และ `inject -> mqtt out`
4. ดับเบิลคลิก `mqtt out` แล้วสร้าง broker ใหม่เป็น:
   - Server: `mosquitto`
   - Port: `1883`
   - Topic: `lan/test/from-nodered`
5. กด `Deploy`
6. เปิดแถบ `Debug` ด้านขวา
7. กดปุ่มที่ `inject`

จาก terminal บนเครื่องลูกข่าย ให้ subscribe รอไว้

```bash
export PI_IP=192.168.1.50
mosquitto_sub -h "$PI_IP" -p 1883 -t lan/test/from-nodered -v
```

ผลที่ควรได้

- หน้า Debug ของ Node-RED แสดง message
- terminal ฝั่งลูกข่ายเห็นข้อความจาก topic `lan/test/from-nodered`

ถ้าหน้าเว็บเข้าได้แต่ MQTT node ต่อ broker ไม่ได้ ให้ตรวจว่าใน Node-RED ใช้ `mosquitto` ไม่ใช่ `localhost`

## การทดสอบ InfluxDB จากเครื่องลูกข่าย

### ทดสอบหน้าเว็บและ health endpoint

เปิด browser จากเครื่องลูกข่าย

```text
http://192.168.1.50:8086
```

แล้วทดสอบ health ผ่าน terminal

```bash
export PI_IP=192.168.1.50
curl "http://$PI_IP:8086/health"
```

ผลที่ควรได้

- หน้า InfluxDB โหลดได้
- health endpoint ตอบกลับ JSON และมีสถานะพร้อมใช้งาน

### ทดสอบเขียนและอ่านข้อมูลจริงผ่าน API

ค่า token, org และ bucket ให้อ่านจากไฟล์ `.env` บน Raspberry Pi

```bash
export PI_IP=192.168.1.50
export INFLUX_ORG=local-iot
export INFLUX_BUCKET=sensor-data
export INFLUX_TOKEN=change-this-influxdb-token
```

เขียนข้อมูลตัวอย่างจากเครื่องลูกข่าย

```bash
curl --request POST \
  "http://$PI_IP:8086/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=s" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --data-raw "manual_test,source=lan temperature=25.5 $(date +%s)"
```

อ่านกลับด้วย Flux query

```bash
curl --request POST \
  "http://$PI_IP:8086/api/v2/query?org=$INFLUX_ORG" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Accept: application/csv" \
  --header "Content-type: application/vnd.flux" \
  --data 'from(bucket: "sensor-data") |> range(start: -10m) |> filter(fn: (r) => r._measurement == "manual_test")'
```

ผลที่ควรได้

- คำสั่ง write ไม่คืน error
- คำสั่ง query เห็น measurement `manual_test`

## การทดสอบ Grafana จากเครื่องลูกข่าย

### ทดสอบหน้าเว็บและการ login

เปิด browser จากเครื่องลูกข่าย

```text
http://192.168.1.50:3000
```

ล็อกอินด้วยค่าจาก `.env`

- Username: `admin`
- Password: `admin123`

ผลที่ควรได้

- หน้า login โหลดได้
- ล็อกอินผ่านและเข้า dashboard ได้

### ทดสอบเชื่อม InfluxDB เป็น data source

ใน Grafana ระบบจะ provision data source แบบ `InfluxDB` ให้อัตโนมัติ

ค่าแนะนำ

- Query language: `Flux`
- URL: `http://influxdb:8086`
- Organization: `local-iot`
- Default bucket: `sensor-data`
- Token: ใช้ค่า `INFLUXDB_ADMIN_TOKEN` จากไฟล์ `.env`

กด `Save & test`

ผลที่ควรได้

- Grafana แจ้งว่า data source ใช้งานได้

### ทดสอบสร้าง panel จากข้อมูลที่เขียนไว้

1. สร้าง dashboard ใหม่
2. เพิ่ม panel ใหม่
3. ใช้ Flux query ตัวอย่างนี้

```flux
from(bucket: "sensor-data")
  |> range(start: -10m)
  |> filter(fn: (r) => r._measurement == "manual_test")
```

ผลที่ควรได้

- panel แสดงข้อมูลที่เพิ่งเขียนจากขั้นตอน InfluxDB

ถ้า Grafana เปิดจาก browser ได้ แต่ `Save & test` ไม่ผ่าน ให้ตรวจว่า URL data source ใช้ `http://influxdb:8086` ไม่ใช่ `http://localhost:8086`

หมายเหตุ

- ระบบมี dashboard ตัวอย่าง `IoT System Overview` ให้ตั้งแต่เริ่มต้น
- ถ้ายังไม่เห็น dashboard ให้รอ provisioning สักครู่หรือ refresh หน้าเว็บ

## ตารางสรุปการทดสอบ

| Service | ทดสอบจากเครื่องลูกข่าย | ผลที่ควรได้ |
| --- | --- | --- |
| MQTT | `mosquitto_sub` และ `mosquitto_pub` ไปที่ `IP-ADDRESS-OF-PI:1883` | รับข้อความได้ |
| Node-RED | เปิด `http://IP-ADDRESS-OF-PI:1880` และ deploy flow | หน้าเว็บโหลดและ flow ทำงาน |
| InfluxDB | เปิด `http://IP-ADDRESS-OF-PI:8086` และเรียก `/health` | health ผ่านและ query ได้ |
| Grafana | เปิด `http://IP-ADDRESS-OF-PI:3000` และ `Save & test` data source | login ได้และ data source ใช้งานได้ |

## เมื่อเจอปัญหา

เช็กบน Raspberry Pi

```bash
cd ~/rpi-server-iot
docker compose ps
docker compose logs --tail=200 mosquitto
docker compose logs --tail=200 nodered
docker compose logs --tail=200 influxdb
docker compose logs --tail=200 grafana
ss -tulpn | grep -E '1880|1883|3000|8086|9001'
```

ถ้าเข้าจากเครื่องลูกข่ายไม่ได้ แต่ `curl http://127.0.0.1:3000` หรือ `curl http://127.0.0.1:8086/health` บน Raspberry Pi ใช้งานได้ ปัญหามักอยู่ที่ firewall, IP ไม่ถูก, หรือ client ไม่ได้อยู่ในวง LAN เดียวกัน
