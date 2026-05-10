# Minio data backup / restore

## Minio is an open source self-host `s3 buket` project


**Backup**
### `1`- Add backup route into docker compose yaml file
**In `services` part  into `volumes` section add below line to add backup route**
```bash
./backup:/backup
```

---

### `2`- Restart docker container
```bash
docker compose restart
```

---

### `3`- Run below command in docker compose route
**It's recommended to down key cloak**
```bash
docker run --rm -v minio-data:/data -v $(pwd)/backup:/backup alpine tar czf [backup_dir]/minio-full-backup-$(date +%F-%H%M).tar.gz -C /data .
```

### `4`- One line command
```bash
docker compose down && docker run --rm -v minio-data:/data -v $(pwd)/backup:/backup alpine tar czf {{ backup_dir }}/minio-full-backup-$(date +%F-%H%M).tar.gz -C /data . && docker compose up -d
```

**You can see our ansible [here](/minio/ansible/)**

### Note: You can run ansible with `ansible-playbook -i inventory.yml playbook.yml`

### Note: Recommended when you are trying to backup compose down your docker

---

**Restore**
### `5`-Remove and remake minio-data volume
```bash
docker volume rm minio-data
docker volume create minio-data
```

### `6`- Restore backup
```bash
docker run --rm -v minio-data:/data -v $(pwd):/backup alpine tar xzf [backup_dir]/[backup_file_name] -C /data
```

---

### `7`- Restart docker compose file
```bash
docker compose restart
```

---

### `8`- One line command
```bash
docker compose down && docker volume rm minio-data && docker volume create minio-data && docker run --rm -v minio-data:/data -v $(pwd):/backup alpine tar xzf [backup_dir]/[backup_file_name] -C /data && docker compose up -d
```