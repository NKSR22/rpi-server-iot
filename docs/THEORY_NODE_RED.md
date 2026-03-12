# ทฤษฎี Node-RED

## Node-RED คืออะไร

Node-RED เป็นเครื่องมือแบบ flow-based programming ใช้เชื่อมโยงอุปกรณ์ บริการ และตรรกะต่าง ๆ ผ่านหน้าเว็บ โดยเหมาะมากกับงาน IoT, integration และ automation

## หลักการทางาน

Node-RED ใช้แนวคิดว่า data จะไหลผ่าน node แต่ละตัวตามลาดับที่ออกแบบไว้ใน flow

ตัวอย่าง node ที่ใช้บ่อย

- input node รับข้อมูลจาก MQTT, HTTP, serial หรือ schedule
- function node ใช้เขียน JavaScript เพื่อแปลงข้อมูล
- switch node ใช้ตัดสินใจตามเงื่อนไข
- output node ส่งข้อมูลออกไปยัง MQTT, database, API หรือ dashboard

## ข้อดีของ Node-RED

- พัฒนาเร็ว
- เหมาะกับงาน prototype และระบบจริงขนาดเล็กถึงกลาง
- อ่าน flow ได้ง่ายกว่าการเขียน service ทั้งหมดด้วยโค้ด
- เชื่อมต่อกับ MQTT และฐานข้อมูลได้สะดวก

## แนวคิด message object

ข้อมูลใน Node-RED มักถูกส่งผ่านตัวแปร `msg` เช่น

- `msg.payload` เก็บค่าหลัก
- `msg.topic` เก็บหัวข้อหรือชื่อ topic
- `msg.timestamp` อาจใช้เก็บเวลา

## กรณีใช้งานในระบบนี้

- subscribe ข้อมูลจาก MQTT broker
- แปลงข้อมูลให้อยู่ในรูปแบบที่เก็บลง InfluxDB ได้
- ตั้งเงื่อนไขแจ้งเตือน
- ส่งต่อข้อมูลไปยังระบบอื่น

## หลักการออกแบบ flow ที่ดี

- แยก flow ตามหน้าที่
- ตั้งชื่อ node และ tab ให้ชัดเจน
- ลด logic ซับซ้อนใน function node เดียว
- เก็บค่าคงที่และ credential อย่างปลอดภัย
- บันทึก flow และสารองข้อมูลเป็นประจา
---

Copyright (c) 2026 Mr. Nakarin Sripanya  
Department of Electrical Engineering  
Faculty of Industry and Technology  
Rajamangala University of Technology Isan, Sakon Nakhon Campus
