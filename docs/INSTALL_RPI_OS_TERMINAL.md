# การติดตั้ง Raspberry Pi OS แบบ Terminal

คู่มือนี้อธิบายขั้นตอนเริ่มต้นสำหรับเตรียม Raspberry Pi 5 ให้พร้อมเป็น Local IoT Server โดยเน้นการติดตั้งแบบไม่มี desktop และออกแบบให้พร้อมใช้งานกับ Docker, MQTT, Node-RED, InfluxDB และ Grafana

## สเปกที่แนะนำ

- บอร์ด: Raspberry Pi 5
- RAM: 4 GB ขั้นต่ำ, 8 GB จะยืดหยุ่นกว่าเมื่อมี dashboard และ flow มากขึ้น
- storage: microSD อย่างน้อย 32 GB, แนะนำ 64 GB ถ้าจะเก็บข้อมูลนาน
- power supply: ควรใช้ของที่รองรับ Raspberry Pi 5 อย่างเหมาะสม
- network: แนะนำ Ethernet สำหรับ server ภายใน

## วิเคราะห์เรื่อง RAM และทรัพยากรเครื่อง

สำหรับ stack นี้บน Raspberry Pi 5 โดยใช้ Mosquitto, Node-RED, InfluxDB และ Grafana พร้อม Docker Compose

- RAM 4 GB เพียงพอสำหรับงาน local IoT ขนาดเล็กถึงกลาง
- ถ้ามี sensor ไม่มาก, dashboard ไม่หนัก, และ flow ของ Node-RED ไม่ซับซ้อน ระบบจะทำงานได้ดี
- service ที่ใช้ RAM มากที่สุดมักเป็น InfluxDB และ Grafana โดยเฉพาะตอน query ข้อมูลย้อนหลังหรือเปิดหลาย panel
- Node-RED จะใช้ RAM เพิ่มขึ้นตามจำนวน flow, node เสริม และ payload ที่ประมวลผล
- Mosquitto ใช้ทรัพยากรน้อยที่สุดเมื่อเทียบกับ service อื่นในระบบ

## แนวทาง sizing แบบใช้งานจริง

- งานทดลองหรือห้องปฏิบัติการขนาดเล็ก: Raspberry Pi 5 RAM 4 GB ใช้งานได้
- งานที่มีหลาย dashboard, query ข้อมูลย้อนหลังบ่อย, หรือมีอุปกรณ์หลายจุด: แนะนำ RAM 8 GB
- ถ้าใช้ microSD เป็น storage หลัก ควรระวังการเขียนข้อมูลถี่มากจาก InfluxDB
- ถ้าจะเก็บข้อมูลระยะยาว แนะนำใช้ SSD ผ่าน USB 3.0 หรือ NVMe case แทน microSD

## เรื่อง Swap และหน่วยความจำเสมือน

Raspberry Pi OS มักมี swap อยู่แล้ว แต่ในการใช้งานเป็น server ควรพิจารณาอย่างระมัดระวัง

- swap ช่วยลดโอกาสระบบค้างเมื่อ RAM ตึง
- แต่ swap บน microSD อาจทำให้การ์ดสึกเร็วขึ้นถ้ามีการใช้งานหนัก
- ถ้าใช้ microSD เป็นหลัก ให้คง swap ระดับพอประมาณ
- ถ้าใช้ SSD เป็น storage หลัก การมี swap 1-2 GB จะปลอดภัยกว่าในช่วง peak load

ตรวจสอบ RAM และ swap

```bash
free -h
swapon --show
```

ตรวจสอบแรงกดดันของหน่วยความจำ

```bash
vmstat 1 5
```

## ระบบปฏิบัติการที่แนะนำ

ใช้ `Raspberry Pi OS Lite (64-bit)` เพราะเหมาะกับงาน server และใช้ทรัพยากรน้อยกว่าแบบ desktop

## ขั้นตอนเตรียม microSD ด้วย Raspberry Pi Imager

1. ติดตั้ง Raspberry Pi Imager บนคอมพิวเตอร์
2. เลือก OS เป็น `Raspberry Pi OS Lite (64-bit)`
3. เลือก microSD card
4. เข้าเมนู advanced options ก่อน write image
5. ตั้ง hostname เช่น `rpi-iot`
6. เปิด `Enable SSH`
7. ตั้ง username และ password
8. ตั้ง timezone เป็น `Asia/Bangkok`
9. ถ้าจะใช้ Wi-Fi ให้กรอก SSID และ password
10. บันทึกค่าและเขียน image ลง microSD

## Boot ครั้งแรก

1. ใส่ microSD ลง Raspberry Pi 5
2. ต่อสาย LAN หรือเตรียม Wi-Fi
3. จ่ายไฟเข้าเครื่อง
4. รอระบบ boot 1-3 นาที
5. ตรวจสอบว่าเครื่องขึ้นในเครือข่ายแล้ว

## การเชื่อมต่อผ่าน SSH

ตัวอย่าง

```bash
ssh pi@rpi-iot.local
```

หรือถ้ารู้ IP

```bash
ssh pi@192.168.1.50
```

## ตั้งค่าหลังเข้าเครื่อง

```bash
sudo raspi-config
```

หัวข้อที่ควรตรวจสอบ

- hostname
- timezone
- locale
- SSH
- memory split ให้เน้น RAM ฝั่งระบบ ถ้าไม่ได้ใช้ desktop

## อัปเดตระบบ

```bash
sudo apt update
sudo apt full-upgrade -y
sudo reboot
```

## ติดตั้งเครื่องมือพื้นฐานให้ครบ

เอกสารนี้ตั้งใจให้เครื่องพร้อมใช้งานจริง และลดโอกาสเจอปัญหาเรียกคำสั่งแล้วไม่มีโปรแกรม

ติดตั้ง `git` ก่อนเพื่อให้ clone โปรเจกต์และเรียกใช้ script จากใน repo ได้

```bash
sudo apt update
sudo apt install -y git
```

clone โปรเจกต์และเข้าไปที่โฟลเดอร์งาน

```bash
git clone https://github.com/NKSR22/rpi-server-iot.git
cd ~/rpi-server-iot
```

ติดตั้งเครื่องมือพื้นฐานด้วย script จากโฟลเดอร์โปรเจกต์

```bash
cd ~/rpi-server-iot
chmod +x scripts/install-base-tools.sh
./scripts/install-base-tools.sh
```

ชุดเครื่องมือที่ได้ เช่น

- `git` สำหรับ clone และ version control
- `curl`, `wget` สำหรับดึงไฟล์
- `gnupg` และ `ca-certificates` สำหรับจัดการ key และการเชื่อมต่อแบบปลอดภัย
- `nano` และ `nvim` สำหรับแก้ไขไฟล์
- `jq` สำหรับอ่าน JSON
- `ripgrep` สำหรับค้นหาไฟล์หรือข้อความเร็ว
- `htop`, `btop` สำหรับดูทรัพยากรเครื่อง
- `tree` สำหรับดูโครงสร้างโฟลเดอร์
- `mosquitto-clients` สำหรับทดสอบ MQTT
- `avahi-daemon` สำหรับเข้าถึงผ่าน `.local`
- `lsof`, `net-tools`, `dnsutils`, `tcpdump` สำหรับ debug ระบบ

## ติดตั้งและใช้งาน Neovim

ใน script พื้นฐานได้ติดตั้ง `nvim` ไว้แล้ว สามารถใช้งานได้ทันที

```bash
nvim README.md
```

ถ้าต้องการตั้งเป็น editor หลักแบบง่าย

```bash
echo 'export EDITOR=nvim' >> ~/.bashrc
echo 'export VISUAL=nvim' >> ~/.bashrc
source ~/.bashrc
```

## ตรวจสอบว่าเครื่องมือพร้อมจริง

```bash
cd ~/rpi-server-iot
chmod +x scripts/verify-system-tools.sh
./scripts/verify-system-tools.sh
```

ถ้ามีรายการ `[MISSING]` ให้ติดตั้งซ้ำอีกครั้งหรือแก้ปัญหาเฉพาะ package นั้นก่อน deploy ระบบ

## ไปขั้นตอนถัดไป

หลังจากนี้ให้ไปต่อที่ [DEPLOYMENT.md](DEPLOYMENT.md)

---

Copyright (c) 2026 Mr. Nakarin Sripanya  
Department of Electrical Engineering  
Faculty of Industry and Technology  
Rajamangala University of Technology Isan, Sakon Nakhon Campus
