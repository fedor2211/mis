# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* Run docker compose in production
RAILS_MASTER_KEY=$(cat config/master.key) MIS_DATABASE_PASSWORD=postgres docker compose up -d --build
