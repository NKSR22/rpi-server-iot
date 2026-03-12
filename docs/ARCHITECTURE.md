# สถาปัตยกรรมระบบ

## ภาพรวมระบบ

ระบบนี้ออกแบบให้ Raspberry Pi 5 ทาหน้าที่เป็น Local IoT Server ภายในเครือข่ายเดียวกัน โดยใช้ Docker Compose เป็นตัวจัดการ service หลัก

## Service หลักในระบบ

- `Mosquitto` เป็น MQTT broker ใช้รับและกระจายข้อความจากอุปกรณ์ IoT
- `Node-RED` ใช้สร้าง flow, automation, data routing และ integration ต่าง ๆ
- `Grafana` ใช้แสดงผล dashboard และ monitoring

## การไหลของข้อมูล

```text
อุปกรณ์ IoT -> MQTT Broker -> Node-RED -> แหล่งเก็บข้อมูล -> Grafana
```

## อธิบายการทางาน

1. อุปกรณ์ IoT ส่งข้อมูลเข้ามายัง MQTT topic
2. Node-RED subscribe ข้อมูลจาก topic ที่เกี่ยวข้อง
3. Node-RED สามารถแปลงข้อมูล กรองข้อมูล หรือส่งต่อไปยังบริการอื่น
4. Grafana ใช้แสดงผลข้อมูลจากแหล่งข้อมูลที่ผูกไว้

## โครงสร้างการเก็บข้อมูลถาวร

- `docker/mosquitto/data/` เก็บข้อมูล persistence ของ MQTT broker
- `docker/mosquitto/log/` เก็บ log ของ Mosquitto
- `docker/nodered/data/` เก็บ flow และ config ของ Node-RED
- `docker/grafana/data/` เก็บข้อมูลภายในของ Grafana

## ข้อแนะนาในการขยายระบบ

- หากต้องการเก็บข้อมูลย้อนหลังเพื่อทากราฟอย่างจริงจัง ควรเพิ่ม InfluxDB หรือ time-series database อื่น
- หากต้องการใช้งานใน production ควรเพิ่ม MQTT authentication และระบบ reverse proxy
