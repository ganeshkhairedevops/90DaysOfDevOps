# Day 32 – Docker Volumes & Networking (MySQL Focus)

Today I explored data persistence in Docker using a MySQL container.

Containers are ephemeral by default — this experiment demonstrates the problem and the solution using named volumes.

---

# 🧨 Task 1 – The Problem (MySQL Without Volume)

## Step 1: Run MySQL Container
```bash
docker run -d \
  --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=admin \
  -e MYSQL_DATABASE=testdb \
  -p 3306:3306 \
  mysql:latest
```
![run](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/20292d9342f8b58088875c6faf1504061d904fb1/2026/day-32/images/task%201.jpg)

---

## Step 2: Connect to MySQL
```bash
docker exec -it my-mysql mysql -u root -p
```
Password: admin

create table

Inside MySQL:
```bash
USE testdb;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
```
Insert Data
```bash
INSERT INTO users (name) VALUES 
('ganesh'),
('kishor'),
('kumar');
```

Verify Data
```bash
SELECT * FROM users;
```
You should see:
```bash
+----+--------+
| id | name   |
+----+--------+
|  1 | ganesh |
|  2 | kishor |
|  3 | kumar  |
+----+--------+
```
![connect](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/20292d9342f8b58088875c6faf1504061d904fb1/2026/day-32/images/task%201.1.jpg)

![insert data](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/20292d9342f8b58088875c6faf1504061d904fb1/2026/day-32/images/task%201.2.jpg)

---

## Step 3: Stop & Remove Container

docker stop my-mysql
docker rm my-mysql

---

## Step 4: Run New MySQL Container

docker run -d \
  --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=admin \
  -e MYSQL_DATABASE=testdb \
  -p 3306:3306 \
  mysql:latest

Connected again:

docker exec -it my-mysql mysql -u root -p

Checked database:

SHOW TABLES;

❌ The table was gone.

![no data](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/20292d9342f8b58088875c6faf1504061d904fb1/2026/day-32/images/task%201.3.jpg)

---

## Why Did Data Disappear?

Because container storage is temporary.

When a container is removed, its writable layer is deleted.
No persistent storage was attached.

---

# 💾 Task 2 – Named Volume (Persistent Storage)

## Create Named Volume
```bash
docker volume create mysql-data
```
Verify:
```bash
docker volume ls
```
![volume](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/20292d9342f8b58088875c6faf1504061d904fb1/2026/day-32/images/task%202.jpg)

---

## Run MySQL with Volume Attached
```bash
docker run -d \
  --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=admin \
  -e MYSQL_DATABASE=testdb \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  mysql:latest
```
---

## Insert Data Again
```bash
docker exec -it my-mysql mysql -u root -p
```

Password: admin

create table

Inside MySQL:
```bash
USE testdb;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
```
Insert Data
```bash
INSERT INTO users (name) VALUES 
('ganesh'),
('kishor'),
('kumar');
```

Verify Data
```bash
SELECT * FROM users;
```
You should see:
```bash
+----+--------+
| id | name   |
+----+--------+
|  1 | ganesh |
|  2 | kishor |
|  3 | kumar  |
+----+--------+
```

Verified data exists.

---

## Stop & Remove Container
```bash
docker stop my-mysql
```
```bash
docker rm my-mysql
```

---

## Run New Container With Same Volume
```bash
docker run -d \
  --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=admin \
  -e MYSQL_DATABASE=testdb \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  mysql:latest
```
Connect again:
```bash
docker exec -it my-mysql mysql -u root -p
```
Password: admin
```bash
USE testdb;
```
```bash
SELECT * FROM users;
```
![task](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%202.3.jpg)



✅ Data persisted successfully.

---

# 🔍 Verify Volume

docker volume inspect mysql-data

Confirmed:
- Mountpoint
- Volume driver
- Volume location

---

# 🎯 Key Learnings

- Containers are ephemeral by default
- Removing a container deletes its writable layer
- Named volumes persist data independently of containers
- Databases must always use volumes in production
- Volumes are stored under /var/lib/docker/volumes/

---

# 🚀 Why This Matters for DevOps

Without volumes:
- Databases lose data on container removal
- Production systems become unreliable

With volumes:
- Data survives container restarts
- Containers become replaceable
- Infrastructure becomes more resilient

This experiment demonstrated real-world data persistence in Docker.

---
![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%202.1.jpg)

---
# Task 3 – Bind Mounts

Bind mounts allow a container to use a directory directly from the host machine.

---

## Step 1: Create Folder on Host
```bash
mkdir my-website
echo "<h1>Bind Mount Successful</h1>" > my-website/index.html
```
---

## Step 2: Run Nginx with Bind Mount
```bash
docker run -d \
  --name bind-nginx \
  -p 8082:80 \
  -v $(pwd):/usr/share/nginx/html \
  nginx
```
![index](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%203.JPG)

---

## Step 3: Access in Browser

Access and check
```bash
http://localhost:8082
```
![access](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%203.1.JPG)

Verified the custom HTML page is displayed.

---

## Step 4: Edit index.html on Host
Edit the index page
```bash
echo "<h1>Bind Mount Successful Updated Content! </h1>" > index.html
```
![update index](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%203.2.JPG)

Refreshed browser → Changes reflected immediately.

![update](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%203.3.JPG)

---

## Named Volume vs Bind Mount

| Named Volume | Bind Mount |
|--------------|------------|
| Managed by Docker | Managed by Host |
| Stored in Docker directory | Any host directory |
| Portable across environments | Tied to specific host path |
| Ideal for databases | Ideal for development |
| More secure | Less isolated |
| -v myvolume:/data |-v $(pwd):/data |

---
## Key Difference 

### Bind Mount

- Directly links a specific host directory to a container.
- You control exactly where the files live.
- Great for development.

### Named Volume

- Docker creates and manages the storage location.
- Safer and cleaner for production environments.
- Not tied to a specific host folder path.

---
# 🌐 Task 4 – Docker Networking Basics
## List Networks
List all Docker networks on your machine
```bash
docker network ls
```
Default networks:
- bridge
- host
- none
## Inspect Default Bridge
Inspect the default bridge network
```bash
docker network inspect bridge
```
![network](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%204.JPG)


## Run Two Containers on Default Bridge
Run first container
```bash
docker run -d --name container1 nginx
```
Run second container
```bash
docker run -d --name container2 nginx
```

connect container
```bash
docker exec -it container1 bash
```
install util in container 
```bash
apt update
apt install -y iputils-ping
```
exit from the container

![check](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%204.JPG)

## Check Connectivity
it will not ping using by name
```bash
docker exec -it container1 ping container2
```
Testing using ip
Get the ip of container
```bash
docker inspect container2 | grep IPAddress
```
Then ping using ip
```bash
docker exec -it container1 ping <container2-ip>
```
✅ Worked

![image](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%204.2.jpg)

---

## Conclusion
Containers on the default bridge network cannot resolve each other by name, but they can communicate using IP addresses. This is because the default bridge network does not include an embedded DNS server for name resolution. To enable name-based communication, you would need to create a user-defined bridge network.

Default bridge does not support automatic DNS resolution by container name.

---

# 🔗 Task 5 – Custom Network
## Create Custom Network
```bash
docker network create my-app-net
```
Verify:
```bash
docker network ls
```
![custom network](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%205.JPG)

### Run Two Containers on my-network
```bash
docker run -dit --name container1 --network my-app-net ubuntu
docker run -dit --name container2 --network my-app-net ubuntu
```

Install ping inside container1:
```bash
docker exec -it container1 bash
apt update  
apt install -y iputils-ping
```
exit from container1
## Check Connectivity using container name
```bash
docker exec -it container1 ping container2
```
✅ Successfully pinged by name.
## Check Connectivity using container ip
Get the ip of container2
```bash
docker inspect container2 | grep IPAddress
```
Then ping using ip
```bash
docker exec -it container1 ping <container2-ip>
```
✅ Worked
## Inspect Network
```bash
docker network inspect my-app-net
```
![connect](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%205.1.JPG)

Shows both containers connected to the custom network.
## Conclusion
Containers on a user-defined bridge network can resolve each other by name because Docker provides an embedded DNS server for that network. This allows for easier communication between containers without needing to know their IP addresses.

## Why Custom Networks Allow Name-Based Communication
User-defined bridge networks include an embedded DNS server that automatically resolves container names to their IP addresses. This allows containers to communicate using names instead of IPs, making it easier to manage and scale applications. In contrast, the default bridge network does not have this feature, so containers cannot resolve each other by name.

Custom bridge networks have built-in DNS.
Docker automatically resolves container names to IP addresses.

Default bridge does not support automatic name resolution.

![image](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%205.2.JPG)

---

# 🧩 Task 6 – Putting It All Together
## Create a custom network
```bash
docker network create app-network
```
## Run Database with Volume + Network
```bash
docker run -d \
  --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=admin \
  -e MYSQL_DATABASE=testdb \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  --network app-network \
  mysql:latest
```
## Run Application Container on Same Network
```bash
docker run -itd \
  --name my-app \
  --network app-network \
  ubuntu
```
## Verify both app in the same network
```bash
docker network inspect app-network
```
![image](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%206.JPG)

![image net](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%206.1.JPG)

## Verify the app container can reach the database by container name
Exec into the my-app container:
```bash
docker exec -it my-app bash
```
Install mysql-client in my-app container
```bash
apt update && apt install -y mysql-client
```
Test connection to MySQL using the container name:
```bash
mysql -h my-mysql -u root -p
```
Enter password: admin

If it connects, your network setup works correctly.

![image1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%206.2.JPG)

![image2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/fad745167bba0a8e404cd77f2d07ee8807a28ebe/2026/day-32/images/task%206.3.JPG)

You can also ping the database container by name:
but then need to install util in my-app container
```bash
apt install -y iputils-ping
```
then check ping
```bash
ping my-mysql
```
If you receive responses, it confirms that the containers can communicate using their names.