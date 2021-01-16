# Job search management
This project can use [dbmate](https://github.com/amacneil/dbmate) to
manage schema migrations.

# Getting started
```
cp .env.example .env
mkdir data
touch data/jobs.sqlite3
dbmate up # using migrations
sqlite3 data/jobs.sqlite3 < db/schema.sql # normal sqlite3 utility
```
