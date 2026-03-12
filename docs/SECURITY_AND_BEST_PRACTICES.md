# ความปลอดภัยและแนวทางปฏิบัติที่ดี

## แนวคิดพื้นฐาน

แม้ระบบนี้จะออกแบบสาหรับ local network แต่การตั้งค่าความปลอดภัยยังสาคัญมาก เพราะระบบ IoT มักเกี่ยวข้องกับอุปกรณ์จริง ข้อมูลจริง และการควบคุมจริง

## สิ่งที่ควรทาทันทีหลังติดตั้ง

- เปลี่ยน password เริ่มต้นของ Grafana
- เปลี่ยนรหัสผ่านและ token ของ InfluxDB
- ปิด anonymous access ของ MQTT เมื่อเริ่มใช้งานจริง
- ใช้ user ที่มีสิทธิ์เท่าที่จาเป็น
- อัปเดตระบบปฏิบัติการและ Docker image เป็นระยะ

## ความปลอดภัยของ MQTT

- ออกแบบ topic ให้แยก telemetry, command, status
- ใช้ username/password เมื่อเข้าสู่ production
- ถ้าระบบขยายออกนอก LAN ให้พิจารณา TLS
- อย่าเปิด broker ออกอินเทอร์เน็ตตรง ๆ โดยไม่มีการป้องกัน

## ความปลอดภัยของ Node-RED

- ตั้งค่า admin authentication
- ติดตั้ง node เพิ่มเท่าที่จาเป็น
- อย่าเก็บ secret แบบ plain text ใน flow โดยไม่ป้องกัน
- สารอง flow และ credential อย่างสม่าเสมอ

## ความปลอดภัยของ InfluxDB และ Grafana

- ใช้รหัสผ่านที่คาดเดายาก
- แยก token ตามหน้าที่ถ้าเป็นไปได้
- จัดการสิทธิ์ผู้ใช้ตามบทบาท
- อย่าใช้บัญชี admin ร่วมกันหลายคน

## ความปลอดภัยของเครื่อง Raspberry Pi

- ใช้ SSH key หากเป็นไปได้
- ปิดบริการที่ไม่จาเป็น
- ตั้ง hostname ให้ชัดเจน
- ใช้ static IP หรือ DHCP reservation
- ติดตาม log และพื้นที่ disk อย่างสม่าเสมอ

## แนวทาง backup

- สารองข้อมูลก่อนปรับ config ใหญ่
- ทดสอบการ restore จริง ไม่ใช่เพียงแค่มีไฟล์ backup
- กาหนดรอบ backup ให้สอดคล้องกับความสาคัญของข้อมูล

---

Copyright (c) 2026 Mr. Nakarin Sripanya  
Department of Electrical Engineering  
Faculty of Industry and Technology  
Rajamangala University of Technology Isan, Sakon Nakhon Campus
