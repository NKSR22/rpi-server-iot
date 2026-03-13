# ความปลอดภัยและแนวทางปฏิบัติที่ดี

## แนวคิดพื้นฐาน

แม้ระบบนี้จะออกแบบสำหรับเครือข่ายท้องถิ่น แต่การตั้งค่าความปลอดภัยยังสำคัญมาก เพราะระบบ IoT มักเกี่ยวข้องกับอุปกรณ์จริง ข้อมูลจริง และการควบคุมจริง

## สิ่งที่ควรทำทันทีหลังติดตั้ง

- เปลี่ยน password เริ่มต้นของ Grafana
- เปลี่ยนรหัสผ่านและ token ของ InfluxDB
- ปิด anonymous access ของ MQTT เมื่อเริ่มใช้งานจริง
- ใช้ user ที่มีสิทธิ์เท่าที่จำเป็น
- อัปเดตระบบปฏิบัติการและ Docker image เป็นระยะ

## ความปลอดภัยของ MQTT

- ออกแบบ topic ให้แยก telemetry, command, status
- ใช้ username/password เมื่อเข้าสู่ production
- ถ้าระบบขยายออกนอก LAN ให้พิจารณา TLS
- อย่าเปิด broker ออกอินเทอร์เน็ตตรง ๆ โดยไม่มีการป้องกัน

ตัวช่วยในโปรเจกต์นี้

- ใช้ [PRODUCTION_HARDENING.md](PRODUCTION_HARDENING.md) เป็นเช็กลิสต์
- ใช้ `scripts/enable-mqtt-auth.sh` เพื่อเปิด MQTT authentication

## ความปลอดภัยของ Node-RED

- ตั้งค่า admin authentication
- ติดตั้ง node เพิ่มเท่าที่จำเป็น
- อย่าเก็บ secret แบบ plain text ใน flow โดยไม่ป้องกัน
- สำรอง flow และ credential อย่างสม่ำเสมอ

## ความปลอดภัยของ InfluxDB และ Grafana

- ใช้รหัสผ่านที่คาดเดาได้ยาก
- แยก token ตามหน้าที่ถ้าเป็นไปได้
- จัดการสิทธิ์ผู้ใช้ตามบทบาท
- อย่าใช้บัญชี admin ร่วมกันหลายคน

## ความปลอดภัยของเครื่อง Raspberry Pi

- ใช้ SSH key หากเป็นไปได้
- ปิดบริการที่ไม่จำเป็น
- ตั้ง hostname ให้ชัดเจน
- ใช้ static IP หรือ DHCP reservation
- ติดตาม log และพื้นที่ disk อย่างสม่ำเสมอ

## แนวทางสำรองข้อมูล

- สำรองข้อมูลก่อนปรับ config ใหญ่
- ทดสอบการกู้คืนจริง ไม่ใช่เพียงแค่มีไฟล์สำรอง
- กำหนดรอบ backup ให้สอดคล้องกับความสำคัญของข้อมูล

---

Copyright (c) 2026 Mr. Nakarin Sripanya  
Department of Electrical Engineering  
Faculty of Industry and Technology  
Rajamangala University of Technology Isan, Sakon Nakhon Campus
