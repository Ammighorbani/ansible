# Key cloak database backup / restore

## Key cloak is an open source self-host`sso` project


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
docker run --rm --network [network-name] -e PGPASSWORD=[db-password] -v $(pwd)/backup:/backup postgres:16 pg_dump -h keycloak_db -U [db-user] [db-name] > backup/keycloak_backup.sql
```

### `4`- One line command
```bash
docker compose down && docker run --rm --network [network-name] -e PGPASSWORD=[db-password] -v $(pwd)/backup:/backup postgres:16 pg_dump -h keycloak_db -U [db-user] [db-name] > backup/keycloak_backup.sql && docker compose up -d
```

**You can see our ansible [here](/keycloak/ansible/)**

### Note: You can run ansible with `ansible-playbook -i inventory.yml playbook.yml`

---

**Restore**
### `5`- One time run key cloak for first time
**You need to one time up key cloak to it make keycloak databse and tables automaticlly**
```bash
docker compose up -d
```

---

### `6`- Restore backup
```bash
docker exec -i keycloak_db psql -U [db-user] -d [db-name] < ./backup/keycloak_backup.sql
```

---

### `7`- Restart docker compose file
```bash
docker compose restart
```

---

### `8`- One line command
```bash
docker compose down && docker exec -i keycloak_db psql -U [db-user] -d [db-name] < ./backup/keycloak_backup.sql && docker compose up -d
```