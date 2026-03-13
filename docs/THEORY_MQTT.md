# ทฤษฎี MQTT

## MQTT คืออะไร

MQTT ย่อมาจาก Message Queuing Telemetry Transport เป็นโปรโตคอลรับส่งข้อความแบบเบา เหมาะกับอุปกรณ์ IoT ที่มีทรัพยากรจำกัดหรือเครือข่ายไม่เสถียร

## แนวคิดแบบ Publish and Subscribe

MQTT ใช้รูปแบบ publish-subscribe โดยมี broker เป็นตัวกลาง

- publisher ส่งข้อความไปยัง topic
- broker รับข้อความและกระจายไปยัง subscriber
- subscriber รับเฉพาะ topic ที่ตนสนใจ

ข้อดีคือ publisher และ subscriber ไม่ต้องรู้จักกันโดยตรง

## Topic คืออะไร

topic คือเส้นทางเชิงตรรกะของข้อมูล เช่น

```text
factory/line1/temp
home/livingroom/humidity
lab/device01/status
```

การออกแบบ topic ที่ดีช่วยให้ระบบขยายง่ายและบริหารสิทธิ์ง่ายขึ้น

## Quality of Service

MQTT มี 3 ระดับหลัก

- QoS 0: ส่งแบบอย่างมากหนึ่งครั้ง เร็วที่สุด แต่ไม่รับประกันการส่งถึง
- QoS 1: ส่งอย่างน้อยหนึ่งครั้ง อาจเกิดข้อมูลซ้ำได้
- QoS 2: ส่งอย่างถูกต้องหนึ่งครั้ง มี overhead สูงสุด

## Retained Message

retained message คือข้อความล่าสุดที่ broker เก็บไว้ใน topic เพื่อให้ subscriber ใหม่ได้รับค่าล่าสุดทันที

เหมาะกับข้อมูลสถานะ เช่น online/offline หรือค่าควบคุมล่าสุด

## Last Will and Testament

LWT คือข้อความที่ broker ส่งแทน client หาก client หลุดการเชื่อมต่อแบบผิดปกติ

มักใช้แสดงสถานะอุปกรณ์ เช่น

```text
device/device01/status = offline
```

## เหตุผลที่ MQTT เหมาะกับ IoT

- packet ขนาดเล็ก
- ใช้แบนด์วิดท์น้อย
- เหมาะกับอุปกรณ์ฝั่ง embedded
- รองรับการเชื่อมต่อแบบหลายอุปกรณ์
- รองรับการทำงานแบบ asynchronous

## แนวทางออกแบบ topic เบื้องต้น

- แยกตาม site, line, device, signal
- ใช้ชื่อที่คงที่และอ่านง่าย
- อย่าใส่ความหมายหลายแบบใน topic เดียว
- แยก topic คำสั่งและ topic telemetry ออกจากกัน

## ตัวอย่างการแบ่ง topic

```text
site1/boiler01/telemetry/temperature
site1/boiler01/telemetry/pressure
site1/boiler01/cmd/pump
site1/boiler01/status/online
```
---

Copyright (c) 2026 Mr. Nakarin Sripanya  
Department of Electrical Engineering  
Faculty of Industry and Technology  
Rajamangala University of Technology Isan, Sakon Nakhon Campus
