# สถาปัตยกรรมระบบ

## ภาพรวมระบบ

ระบบนี้ออกแบบให้ Raspberry Pi 5 ทาหน้าที่เป็น Local IoT Server ภายในเครือข่ายเดียวกัน โดยใช้ Docker Compose เป็นตัวจัดการ service หลัก

## Service หลักในระบบ

- `Mosquitto` เป็น MQTT broker ใช้รับและกระจายข้อความจากอุปกรณ์ IoT
- `Node-RED` ใช้สร้าง flow, automation, data routing และ integration ต่าง ๆ
- `InfluxDB` ใช้เก็บข้อมูล time-series เช่น ค่า sensor, telemetry และ event
- `Grafana` ใช้แสดงผล dashboard และ monitoring

## การไหลของข้อมูล

```text
อุปกรณ์ IoT -> MQTT Broker -> Node-RED -> InfluxDB -> Grafana
```

## หลักการเข้าถึง service จากแต่ละจุด

- เครื่องลูกข่ายในวง LAN เข้าใช้งานผ่าน IP ของ Raspberry Pi เช่น `http://192.168.1.50:3000`
- shell บน Raspberry Pi สามารถตรวจ service ผ่าน `localhost`
- container ภายในระบบเดียวกันควรคุยกันผ่านชื่อ service ของ Docker Compose

ตัวอย่างที่สาคัญ

- Node-RED ต่อ MQTT broker ใช้ `mosquitto:1883`
- Grafana ต่อ InfluxDB ใช้ `http://influxdb:8086`
- เครื่องลูกข่ายเปิด Node-RED ใช้ `http://192.168.1.50:1880`

## อธิบายการทางาน

1. อุปกรณ์ IoT ส่งข้อมูลเข้ามายัง MQTT topic
2. Node-RED subscribe ข้อมูลจาก topic ที่เกี่ยวข้อง
3. Node-RED สามารถแปลงข้อมูล กรองข้อมูล หรือส่งต่อไปยังบริการอื่น
4. Node-RED สามารถเขียนข้อมูลลง InfluxDB ได้โดยตรง
5. Grafana ใช้แสดงผลข้อมูลจาก InfluxDB หรือแหล่งข้อมูลอื่นที่ผูกไว้

## โครงสร้างการเก็บข้อมูลถาวร

- `docker/mosquitto/data/` เก็บข้อมูล persistence ของ MQTT broker
- `docker/mosquitto/log/` เก็บ log ของ Mosquitto
- `docker/nodered/data/` เก็บ flow และ config ของ Node-RED
- `docker/influxdb/data/` เก็บข้อมูลของ InfluxDB
- `docker/influxdb/config/` เก็บ config ของ InfluxDB
- `docker/grafana/data/` เก็บข้อมูลภายในของ Grafana

## ข้อแนะนาในการขยายระบบ

- หากต้องการใช้งานใน production ควรเพิ่ม MQTT authentication และระบบ reverse proxy
- หากต้องการแยกภาระงานในอนาคต สามารถย้าย InfluxDB หรือ Grafana ไปอีกเครื่องได้
---

Copyright (c) 2026 Mr. Nakarin Sripanya  
Department of Electrical Engineering  
Faculty of Industry and Technology  
Rajamangala University of Technology Isan, Sakon Nakhon Campus
