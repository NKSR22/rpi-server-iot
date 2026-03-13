# การเตรียมระบบสำหรับใช้งานจริง

เอกสารนี้สรุปขั้นตอน hardening สำหรับกรณีที่ระบบจะถูกนำไปใช้งานจริงในห้องทดลอง โรงงาน หรือระบบ IoT ภายในองค์กร

## เป้าหมายของการ hardening

- ลดความเสี่ยงจากบัญชีเริ่มต้นและค่าตั้งต้นที่เดาได้
- ลดโอกาสที่อุปกรณ์หรือผู้ใช้ในวง LAN จะเข้าถึง service ได้เกินจำเป็น
- เพิ่มความสามารถในการสำรองและกู้คืนระบบ
- ทำให้ระบบดูแลต่อได้ง่ายเมื่อใช้งานระยะยาว

## 1. เปลี่ยนค่าลับทั้งหมดใน `.env`

ไฟล์ `.env` ควรปรับอย่างน้อยรายการต่อไปนี้

- `GRAFANA_ADMIN_PASSWORD`
- `INFLUXDB_PASSWORD`
- `INFLUXDB_ADMIN_TOKEN`

แนวทางที่แนะนำ

- ใช้รหัสผ่านยาวอย่างน้อย 16 ตัวอักษร
- ผสมตัวอักษรใหญ่ ตัวอักษรเล็ก ตัวเลข และอักขระพิเศษ
- ไม่ใช้ค่าซ้ำกันระหว่าง Grafana, InfluxDB, SSH และ MQTT

## 2. กำหนด IP ของ Raspberry Pi ให้คงที่

สำหรับระบบที่ต้องมีเครื่องลูกข่ายในวง LAN เข้ามาใช้งานสม่ำเสมอ ควรใช้วิธีใดวิธีหนึ่ง

- ตั้ง DHCP reservation ที่ router
- ตั้ง static IP บน Raspberry Pi

ถ้า IP เปลี่ยน

- browser ของผู้ใช้จะเข้า Node-RED, InfluxDB และ Grafana ไม่ได้
- อุปกรณ์ MQTT และระบบภายนอกอาจชี้ broker ผิดเครื่อง

## 3. เปิดใช้ MQTT authentication

ค่าเริ่มต้นปัจจุบันของ Mosquitto คือ `allow_anonymous true` เพื่อให้เริ่มต้นใช้งานได้ง่าย แต่ไม่ควรใช้แบบนี้ในระบบจริง

เปิดใช้งาน MQTT authentication ด้วยสคริปต์นี้

```bash
cd ~/rpi-server-iot
chmod +x scripts/enable-mqtt-auth.sh
./scripts/enable-mqtt-auth.sh mqttuser 'change-this-password'
docker compose restart mosquitto
```

สิ่งที่จะเกิดขึ้น

- สร้างไฟล์ `docker/mosquitto/config/passwd`
- สำรองไฟล์ config เดิมเป็น `docker/mosquitto/config/mosquitto.conf.bak`
- ปรับ `mosquitto.conf` ให้ใช้ `password_file`
- ปิด `allow_anonymous`

หลังจากนั้นทุก MQTT client รวมถึง Node-RED ต้องตั้ง username/password ให้ตรงกัน

## 4. ตั้งค่า Node-RED ให้มีการยืนยันตัวตน

ไม่ควรเปิด Node-RED editor โดยไม่มี login หากระบบใช้งานจริง

แนวทาง

1. เปิดไฟล์ `docker/nodered/data/settings.js`
2. ตั้งค่า `adminAuth`
3. ใช้ password hash ไม่ใช้ plain text

ถ้าไฟล์ `settings.js` ยังไม่ถูกสร้าง ให้ start Node-RED หนึ่งครั้งก่อน แล้วค่อยแก้ไขไฟล์ใน `docker/nodered/data/`

## 5. จำกัดการเข้าถึงด้วย firewall

ถ้าใช้ `ufw` ให้เปิดเฉพาะ port ที่จำเป็น

ตัวอย่าง

```bash
sudo ufw allow 22/tcp
sudo ufw allow 1880/tcp
sudo ufw allow 1883/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 8086/tcp
sudo ufw allow 9001/tcp
sudo ufw enable
sudo ufw status
```

ถ้าบาง service ไม่ควรถูกเปิดให้ทุกเครื่องใน LAN ใช้งาน ควรจำกัดตาม subnet หรือ source IP

## 6. วางนโยบายสำรองข้อมูล

ข้อมูลที่ต้องสำรองอย่างน้อย

- `.env`
- `compose.yaml`
- `docker/mosquitto/config/`
- `docker/mosquitto/data/`
- `docker/mosquitto/log/`
- `docker/nodered/data/`
- `docker/influxdb/data/`
- `docker/influxdb/config/`
- `docker/grafana/data/`
- `docker/grafana/provisioning/`

สคริปต์สำรองข้อมูล

```bash
cd ~/rpi-server-iot
./scripts/backup.sh
```

ข้อแนะนำ

- เก็บ backup แยกออกจาก microSD/SSD หลัก
- ทดสอบการกู้คืนจริงเป็นรอบ ๆ
- ถ้าข้อมูลมีความสำคัญสูง ควรตั้ง cron job หรือ systemd timer

## 7. ตรวจสอบการใช้ storage และอายุของสื่อบันทึก

InfluxDB และ Grafana จะสร้างข้อมูลสะสมต่อเนื่อง จึงควรตรวจอย่างสม่ำเสมอ

```bash
df -h
du -sh docker/influxdb/data
du -sh docker/grafana/data
```

ถ้าใช้ microSD และมีการเขียนข้อมูลถี่มาก

- ควรพิจารณา SSD
- ควรออกแบบ retention policy
- ควรลดความละเอียดของข้อมูลที่ไม่จำเป็น

## 8. อัปเดต image อย่างมีขั้นตอน

```bash
cd ~/rpi-server-iot
./scripts/backup.sh
docker compose pull
docker compose up -d
docker compose ps
```

หลังอัปเดต ควรทดสอบ

- MQTT publish/subscribe
- หน้า Node-RED
- InfluxDB health
- Grafana login และ dashboard

## 9. เช็กลิสต์ก่อนใช้งานจริง

- เปลี่ยน password และ token ครบแล้ว
- Raspberry Pi มี IP คงที่แล้ว
- MQTT ปิด anonymous access แล้ว
- Node-RED มีการยืนยันตัวตนแล้ว
- Backup ทำงานและทดสอบกู้คืนแล้ว
- มีการตรวจ disk usage และทรัพยากรเครื่องเป็นประจำ
- ผู้ใช้ปลายทางเข้าผ่าน LAN ได้จริงตามคู่มือใน `LAN_VALIDATION.md`
