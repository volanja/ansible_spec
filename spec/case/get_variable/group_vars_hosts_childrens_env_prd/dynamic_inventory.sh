#!/bin/bash
cat << EOS
{
  "database-servers": {
    "hosts": [
      "10.0.0.4"
    ]
  },
  "application-servers": {
    "hosts": [
      "10.0.0.2",
      "10.0.0.3"
    ]
  },
  "web-servers": {
    "hosts": [
      "10.0.0.1"
    ]
  },
  "production-database-servers": {
    "children": [
      "database-servers"
    ]
  },
  "production-application-servers": {
    "children": [
      "application-servers"
    ]
  },
  "production-web-servers": {
    "children": [
      "web-servers"
    ]
  },
  "production": {
    "children": [
      "production-web-servers",
      "production-application-servers",
      "production-database-servers"
    ]
  }
}
EOS
